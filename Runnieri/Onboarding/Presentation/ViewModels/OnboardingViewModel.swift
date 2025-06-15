import Foundation
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published private(set) var pages: [OnboardingUIModel]
    @Published var isPermissionAlertDisplayed = false
    @Published var permissionAlertMessage = ""
    @Published private(set) var isOnboardingCompleted = false
    
    private let completeOnboardingUseCase: CompleteOnboardingUseCase
    private let requestPermissionUseCase: RequestPermissionUseCase
    private nonisolated let taskProvider: TaskProvider
    
    init(
        completeOnboardingUseCase: CompleteOnboardingUseCase,
        requestPermissionUseCase: RequestPermissionUseCase,
        taskProvider: TaskProvider = RealTaskProvider()
    ) {
        self.completeOnboardingUseCase = completeOnboardingUseCase
        self.requestPermissionUseCase = requestPermissionUseCase
        self.taskProvider = taskProvider
        
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
    
    var isLastPage: Bool {
        currentPage == pages.count - 1
    }
    
    func onTapNext() {
        taskProvider.run { [weak self] in
            guard let self else { return }
            do {
                try await requestPermissions()
                nextPage()
            } catch {
                showPermissionAlert()
            }
        }
    }
    
    func onTapPrevious() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
    
    private func nextPage() {
        if currentPage < pages.count - 1 {
            currentPage += 1
        }
    }
    
    private func requestPermissions() async throws {
        if let permissionType = pages[currentPage].permissionType {
            try await requestPermissionUseCase.execute(for: permissionType)
        }
    }
    
    func completeOnboarding() {
        taskProvider.run { [weak self] in
            guard let self else { return }
            do {
                try await completeOnboardingUseCase.execute()
                isOnboardingCompleted = true
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func showPermissionAlert() {
        isPermissionAlertDisplayed = true
        permissionAlertMessage = "Please enable Health access in Settings to track your calories."
    }
}
