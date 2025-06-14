import Foundation

protocol CompleteOnboardingUseCase {
    func execute() async throws
}

final class CompleteOnboardingInteractor: CompleteOnboardingUseCase {
    private let onboardingRepository: OnboardingRepository
    
    init(onboardingRepository: OnboardingRepository) {
        self.onboardingRepository = onboardingRepository
    }
    
    func execute() async throws {
        try await onboardingRepository.completeOnboarding()
    }
}
