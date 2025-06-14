import Foundation
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    // MARK: - Properties
    @Published var currentPage = 0
    @Published private(set) var pages: [OnboardingUIModel]
    @Published var showPermissionAlert = false
    @Published var permissionAlertMessage = ""
    @Published private(set) var isOnboardingCompleted = false
    
    private let completeOnboardingUseCase: CompleteOnboardingUseCase
    private let locationService: LocationService
    private let healthDataSource: HealthDataSource
    
    // MARK: - Initialization
    init(
        completeOnboardingUseCase: CompleteOnboardingUseCase,
        locationService: LocationService,
        healthDataSource: HealthDataSource
    ) {
        self.completeOnboardingUseCase = completeOnboardingUseCase
        self.locationService = locationService
        self.healthDataSource = healthDataSource
        
        self.pages = [
            OnboardingUIModel(
                title: "Welcome to Runnieri",
                description: "Your personal running companion. Track your runs, monitor your progress, and achieve your fitness goals.",
                imageName: "running"
            ),
            OnboardingUIModel(
                title: "Location Access",
                description: "We need your location to track your runs accurately. Your data is always private and secure.",
                imageName: "location",
                permissionType: .location
            ),
            OnboardingUIModel(
                title: "Health Integration",
                description: "Connect with Apple Health to track your fitness metrics and contribute to your health data.",
                imageName: "health",
                permissionType: .healthKit
            ),
            OnboardingUIModel(
                title: "You're All Set!",
                description: "Start your running journey with Runnieri. Let's hit the road!",
                imageName: "checkmark"
            )
        ]
    }
    
    // MARK: - Public Methods
    
    var isLastPage: Bool {
        currentPage == pages.count - 1
    }
    
    func nextPage() {
        if currentPage < pages.count - 1 {
            currentPage += 1
        } else {
            completeOnboarding()
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
    
    func requestPermissions() async {
        do {
            if pages[currentPage].permissionType == .location {
                locationService.requestAuthorization()
            } else if pages[currentPage].permissionType == .healthKit {
                _ = try await healthDataSource.requestAuthorization()
            }
        } catch {
            showPermissionAlert = true
            permissionAlertMessage = "Please enable Health access in Settings to track your calories."

        }
    }
    
    func completeOnboarding() {
        Task {
            do {
                try await completeOnboardingUseCase.execute()
                isOnboardingCompleted = true
            } catch {
                print(error.localizedDescription)
            }
        }
    }
} 
