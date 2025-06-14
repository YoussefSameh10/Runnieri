import SwiftUI
import Combine

/// Protocol defining the main navigation routes in the app
@MainActor
protocol MainRouterProtocol: ObservableObject {
    /// The current active route
    var currentRoute: Route { get }
    
    /// Navigate to a specific route
    /// - Parameter route: The route to navigate to
    func navigate(to route: Route)
    
    /// Navigate back to the previous route
    func navigateBack()
    
    /// Navigate to the root route
    func navigateToRoot()
}

/// Main router implementation
@MainActor
final class MainRouter: MainRouterProtocol {
    /// The current active route
    @Published private(set) var currentRoute: Route
    
    /// The navigation stack
    @Published private(set) var navigationStack: [Route]
    
    /// The onboarding repository
    private let onboardingRepository: OnboardingRepository
    
    /// The activities repository
    private let activitiesRepository: ActivitiesRepository
    
    /// The location service
    private let locationService: LocationService
    
    /// The health data source
    private let healthDataSource: HealthDataSource
    
    /// The time provider
    private let timeProvider: TimeProvider
    
    /// Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Initializes the router with the initial route
    /// - Parameters:
    ///   - onboardingRepository: The onboarding repository
    ///   - activitiesRepository: The activities repository
    ///   - locationService: The location service
    ///   - healthDataSource: The health data source
    ///   - timeProvider: The time provider
    ///   - initialRoute: The initial route to start with
    init(
        onboardingRepository: OnboardingRepository,
        activitiesRepository: ActivitiesRepository,
        locationService: LocationService,
        healthDataSource: HealthDataSource,
        timeProvider: TimeProvider,
        initialRoute: Route = .onboarding
    ) {
        self.onboardingRepository = onboardingRepository
        self.activitiesRepository = activitiesRepository
        self.locationService = locationService
        self.healthDataSource = healthDataSource
        self.timeProvider = timeProvider
        self.currentRoute = initialRoute
        self.navigationStack = [initialRoute]
    }
    
    /// Navigate to a specific route
    /// - Parameter route: The route to navigate to
    func navigate(to route: Route) {
        currentRoute = route
        navigationStack.append(route)
    }
    
    /// Navigate back to the previous route
    func navigateBack() {
        guard navigationStack.count > 1 else { return }
        navigationStack.removeLast()
        currentRoute = navigationStack.last ?? .onboarding
    }
    
    /// Navigate to the root route
    func navigateToRoot() {
        navigationStack = [.onboarding]
        currentRoute = .onboarding
    }
    
    /// Creates the onboarding view with its dependencies
    func makeOnboardingView() -> some View {
        let completeOnboardingUseCase = CompleteOnboardingInteractor(
            onboardingRepository: onboardingRepository
        )
        
        let viewModel = OnboardingViewModel(
            completeOnboardingUseCase: completeOnboardingUseCase,
            locationService: locationService,
            healthDataSource: healthDataSource
        )
        
        // Subscribe to onboarding completion
        viewModel.$isOnboardingCompleted
            .filter { $0 }
            .sink { [weak self] _ in
                self?.navigate(to: .main)
            }
            .store(in: &cancellables)
        
        return OnboardingView(viewModel: viewModel)
    }
    
    /// Creates the main view with its dependencies
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
    
    /// Creates the activity list view with its dependencies
    private func makeActivityListView() -> some View {
        ActivityListView(viewModel: ActivityListViewModel(activitiesRepo: self.activitiesRepository))
    }
    
    /// Creates the activity tracker view with its dependencies
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
}

/// Represents the different routes in the app
enum Route: Hashable {
    case onboarding
    case main
    case settings
    case profile
    case workout
    case workoutDetail(id: String)
    
    /// The view associated with this route
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
