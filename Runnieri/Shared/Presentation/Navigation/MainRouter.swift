import SwiftUI
import Combine

enum Route: Hashable {
    case onboarding
    case main
    case settings
    case profile
    case workout
    case workoutDetail(id: String)
}

@MainActor
final class MainRouter: ObservableObject {
    @Published private(set) var currentRoute: Route
    private var navigationStack = [Route]()
    
    private let onboardingRepository: OnboardingRepository
    private let activitiesRepository: ActivitiesRepository
    private let locationService: LocationService
    private let healthDataSource: HealthDataSource
    private let timeProvider: TimeProvider
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.onboardingRepository = OnboardingRepositoryImpl()
        self.activitiesRepository = ActivitiesRepoImpl()
        self.locationService = CoreLocationService()
        self.healthDataSource = HealthKitService()
        self.timeProvider = RealTimeProvider()
        
        self.currentRoute = onboardingRepository.isOnboardingCompleted ? .main : .onboarding
        self.navigationStack = [currentRoute]
    }
    
    func makeOnboardingView() -> some View {
        let completeOnboardingUseCase = CompleteOnboardingInteractor(
            onboardingRepository: onboardingRepository
        )
        
        let viewModel = OnboardingViewModel(
            completeOnboardingUseCase: completeOnboardingUseCase,
            locationService: locationService,
            healthDataSource: healthDataSource
        )
        
        viewModel.$isOnboardingCompleted
            .filter { $0 }
            .sink { [weak self] _ in
                self?.navigate(to: .main)
            }
            .store(in: &cancellables)
        
        return OnboardingView(viewModel: viewModel)
    }
    
    func makeMainView() -> some View {
        TabView {
            makeActivityListView()
                .tabItem {
                    Label("Activities", systemImage: "list.bullet")
                }
            
            makeActivityTrackerView()
                .tabItem {
                    Label("Track", systemImage: "figure.walk")
                }
        }
    }
    
    private func makeActivityListView() -> some View {
        ActivityListView(viewModel: ActivityListViewModel(activitiesRepo: self.activitiesRepository))
    }
    
    private func makeActivityTrackerView() -> some View {
        let startUseCase = StartActivityInteractor(
            activitiesRepository: activitiesRepository,
            locationService: locationService
        )
        
        let stopUseCase = StopActivityInteractor(
            activitiesRepository: activitiesRepository,
            locationService: locationService
        )
        
        return ActivityTrackerView(viewModel: ActivityTrackerViewModel(
            startActivityUseCase: startUseCase,
            stopActivityUseCase: stopUseCase,
            locationService: self.locationService,
            activitiesRepository: self.activitiesRepository,
            timeProvider: self.timeProvider
        ))
    }
    
    private func navigate(to route: Route) {
        currentRoute = route
        navigationStack.append(route)
    }
}

extension Route {
    @ViewBuilder
    @MainActor
    func view(router: MainRouter) -> some View {
        switch self {
        case .onboarding:
            router.makeOnboardingView()
        case .main:
            router.makeMainView()
        case .settings:
            Text("Settings View")
        case .profile:
            Text("Profile View")
        case .workout:
            Text("Workout View")
        case .workoutDetail(let id):
            Text("Workout Detail View: \(id)")
        }
    }
} 
