import Foundation
import Combine

@MainActor
class ActivityTrackerViewModel: ObservableObject {
    @Published var isTracking = false
    @Published var duration: TimeInterval = 0.0
    @Published var showPermissionAlert = false
    @Published var distance: Int = 0
    @Published var calories: Double = 0.0
    
    private var timer: Timer?
    private let startActivityUseCase: StartActivityUseCase
    private let stopActivityUseCase: StopActivityUseCase
    private let locationService: LocationService
    private let timeProvider: TimeProvider
    private let activitiesRepository: ActivitiesRepository
    private nonisolated let taskProvider: TaskProvider
    private var timerProvider: Timer.Type
    private var startTime: TimeInterval?
    private var cancellables = Set<AnyCancellable>()
    
    init(
        startActivityUseCase: StartActivityUseCase,
        stopActivityUseCase: StopActivityUseCase,
        locationService: LocationService,
        activitiesRepository: ActivitiesRepository,
        timeProvider: TimeProvider = RealTimeProvider(),
        taskProvider: TaskProvider = RealTaskProvider(),
        timerProvider: Timer.Type = Timer.self
    ) {
        self.startActivityUseCase = startActivityUseCase
        self.stopActivityUseCase = stopActivityUseCase
        self.locationService = locationService
        self.timeProvider = timeProvider
        self.taskProvider = taskProvider
        self.activitiesRepository = activitiesRepository
        self.distance = locationService.distance
        self.timerProvider = timerProvider
        
        taskProvider.run { [weak self] in
            await self?.setupSubscriptions()
        }
    }
    
    private func setupSubscriptions() async {
        locationService.distancePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newDistance in
                self?.distance = newDistance
            }
            .store(in: &cancellables)
            
        locationService.authorizationStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                if status == .denied || status == .restricted {
                    self?.showPermissionAlert = true
                    self?.stopTracking()
                }
            }
            .store(in: &cancellables)
            
        await activitiesRepository.caloriesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newCalories in
                self?.calories = newCalories
            }
            .store(in: &cancellables)
    }
    
    func startTracking() {
        switch locationService.authorizationStatus {
        case .notDetermined:
            locationService.requestAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            Task {
                do {
                    try await startActivityUseCase.execute()
                    isTracking = true
                    duration = 0.0
                    calories = 0.0
                    startTime = timeProvider.currentTime
                    updateDuration()
                    timer = timerProvider.scheduledTimer(withTimeInterval: TimeInterval.oneSecond, repeats: true) { [weak self] _ in
                        self?.taskProvider.runOnMainActor { [weak self] in
                            self?.updateDuration()
                        }
                    }
                } catch StartActivityError.notAuthorized {
                    showPermissionAlert = true
                } catch {
                    print("Error starting activity: \(error)")
                    showPermissionAlert = true
                }
            }
        default:
            showPermissionAlert = true
        }
    }
    
    private func updateDuration() {
        guard let startTime = startTime else { return }
        duration = timeProvider.currentTime - startTime
    }
    
    func stopTracking() {
        isTracking = false
        timer?.invalidate()
        timer = nil
        
        taskProvider.run { [weak self] in
            guard let self else { return }
            guard let startTime = self.startTime else { return }
            await stopActivityUseCase.execute(distance: distance, duration: duration, startTime: startTime)
            self.startTime = nil
        }
    }
    
    func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / Int(TimeInterval.oneHour)
        let minutes = (Int(interval) % Int(TimeInterval.oneHour)) / Int(TimeInterval.oneMinute)
        let seconds = Int(interval) % Int(TimeInterval.oneMinute)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func formatCalories(_ calories: Double) -> String {
        String(format: "%.0f kcal", calories)
    }
}
