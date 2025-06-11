import Foundation
import Combine

@MainActor
class ActivityTrackerViewModel: ObservableObject {
    @Published var isTracking = false
    @Published var liveActivity: LiveActivityUIModel?
    @Published var showPermissionAlert = false
    
    private var timer: Timer?
    private let startActivityUseCase: StartActivityUseCase
    private let stopActivityUseCase: StopActivityUseCase
    private let locationService: LocationService
    private let timeProvider: TimeProvider
    private let activitiesRepository: ActivitiesRepository
    private nonisolated let taskProvider: TaskProvider
    private var timerProvider: Timer.Type
    private var cancellables = Set<AnyCancellable>()
    
    init(
        startActivityUseCase: StartActivityUseCase,
        stopActivityUseCase: StopActivityUseCase,
        locationService: LocationService,
        activitiesRepository: ActivitiesRepository,
        timeProvider: TimeProvider = RealTimeProvider(),
        taskProvider: TaskProvider = RealTaskProvider(),
        timerProvider: Timer.Type = Timer.self,
        scheduler: some Scheduler = DispatchQueue.main
    ) {
        self.startActivityUseCase = startActivityUseCase
        self.stopActivityUseCase = stopActivityUseCase
        self.locationService = locationService
        self.timeProvider = timeProvider
        self.taskProvider = taskProvider
        self.activitiesRepository = activitiesRepository
        self.timerProvider = timerProvider
        setupSubscriptions(on: scheduler)
    }
    
    var formattedActivity: ActivityUIModel {
        guard let liveActivity else {
            return ActivityUIModel(id: UUID(), distance: "---", duration: "---", date: "---", calories: "---")
        }
        
        return ActivityMapper().uiModel(from: liveActivity)
    }
    
    private func setupSubscriptions(on scheduler: some Scheduler) {
        locationService.distancePublisher
            .receive(on: scheduler)
            .sink { [weak self] newDistance in
                self?.updateDistance(newDistance)
            }
            .store(in: &cancellables)
            
        locationService.authorizationStatusPublisher
            .receive(on: scheduler)
            .sink { [weak self] status in
                if status == .denied || status == .restricted {
                    self?.showPermissionAlert = true
                    self?.stopTracking()
                }
            }
            .store(in: &cancellables)
            
        activitiesRepository.caloriesPublisher
            .receive(on: scheduler)
            .sink { [weak self] newCalories in
                self?.updateCalories(Int(newCalories))
            }
            .store(in: &cancellables)
    }
    
    func startTracking() {
        taskProvider.run { [weak self] in
            guard let self else { return }
            switch locationService.authorizationStatus {
            case .notDetermined:
                locationService.requestAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                do {
                    try await startActivityUseCase.execute()
                    liveActivity = LiveActivityUIModel(
                        id: UUID(),
                        distance: 0,
                        duration: 0,
                        startTime: timeProvider.currentTime,
                        calories: 0
                    )
                    isTracking = true
                    updateDuration()
                    timer = timerProvider.scheduledTimer(withTimeInterval: TimeInterval.oneSecond, repeats: true) { [weak self] _ in
                        self?.taskProvider.runOnMainActor { [weak self] in
                            self?.updateDuration()
                        }
                    }
                } catch {
                    print("Error: \(error.localizedDescription)")
                    showPermissionAlert = true
                }
            case .denied, .restricted:
                showPermissionAlert = true
            }
        }
    }
    
    private func updateDistance(_ newDistance: Int) {
        guard isTracking, let liveActivity else { return }
        self.liveActivity = LiveActivityUIModel(
            id: liveActivity.id,
            distance: newDistance,
            duration: liveActivity.duration,
            startTime: liveActivity.startTime,
            calories: liveActivity.calories
        )
    }
    
    private func updateCalories(_ newCalories: Int) {
        guard isTracking, let liveActivity else { return }
        self.liveActivity = LiveActivityUIModel(
            id: liveActivity.id,
            distance: liveActivity.distance,
            duration: liveActivity.duration,
            startTime: liveActivity.startTime,
            calories: newCalories
        )
    }
    
    private func updateDuration() {
        guard isTracking, let liveActivity else { return }
        self.liveActivity = LiveActivityUIModel(
            id: liveActivity.id,
            distance: liveActivity.distance,
            duration: timeProvider.currentTime - liveActivity.startTime,
            startTime: liveActivity.startTime,
            calories: liveActivity.calories
        )
    }
    
    func stopTracking() {
        guard isTracking else { return }
        isTracking = false
        timer?.invalidate()
        timer = nil
        
        taskProvider.run { [weak self] in
            guard let self, let liveActivity else { return }
            do {
                try await stopActivityUseCase.execute(distance: liveActivity.distance, duration: liveActivity.duration, startTime: liveActivity.startTime)
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
