import Foundation

protocol OnboardingRepository {
    var isOnboardingCompleted: Bool { get }
    func completeOnboarding() async throws
} 
