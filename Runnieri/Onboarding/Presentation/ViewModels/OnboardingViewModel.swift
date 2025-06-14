import Foundation
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var showPermissionAlert = false
    @Published var permissionAlertMessage = ""
    
    private let completeOnboardingUseCase: CompleteOnboardingUseCase
    private let locationService: LocationService
    private let healthDataSource: HealthDataSource
    private var cancellables = Set<AnyCancellable>()
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to Runnieri",
            description: "Track your walking activities and monitor your progress with ease.",
            imageName: "figure.walk"
        ),
        OnboardingPage(
            title: "Location Access",
            description: "We need your location to track your walking distance accurately.",
            imageName: "location.fill",
            permissionType: .location
        ),
        OnboardingPage(
            title: "Health Data",
            description: "Access to your health data helps us calculate calories burned during your activities.",
            imageName: "heart.fill",
            permissionType: .healthKit
        ),
        OnboardingPage(
            title: "You're All Set!",
            description: "Start tracking your walking activities and achieve your fitness goals.",
            imageName: "checkmark.circle.fill"
        )
    ]
    
    init(
        completeOnboardingUseCase: CompleteOnboardingUseCase,
        locationService: LocationService,
        healthDataSource: HealthDataSource
    ) {
        self.completeOnboardingUseCase = completeOnboardingUseCase
        self.locationService = locationService
        self.healthDataSource = healthDataSource
    }
    
    var isLastPage: Bool {
        currentPage == pages.count - 1
    }
    
    func nextPage() {
        guard currentPage < pages.count - 1 else { return }
        currentPage += 1
    }
    
    func previousPage() {
        guard currentPage > 0 else { return }
        currentPage -= 1
    }
    
    func requestPermission() async {
        let page = pages[currentPage]
        
        switch page.permissionType {
        case .location:
            locationService.requestAuthorization()
        case .healthKit:
            do {
                _ = try await healthDataSource.requestAuthorization()
            } catch {
                showPermissionAlert = true
                permissionAlertMessage = "Please enable Health access in Settings to track your calories."
            }
        case .none:
            break
        }
    }
    
    func completeOnboarding() async {
        do {
            try await completeOnboardingUseCase.execute()
        } catch {
            // Handle error if needed
            print("Error completing onboarding: \(error.localizedDescription)")
        }
    }
} 
