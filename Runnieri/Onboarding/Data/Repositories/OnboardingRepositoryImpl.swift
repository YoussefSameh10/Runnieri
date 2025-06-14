import Foundation

final class OnboardingRepositoryImpl: OnboardingRepository {
    private let userDefaults: UserDefaults
    private let onboardingCompletedKey = "onboarding_completed"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    var isOnboardingCompleted: Bool {
        userDefaults.set(false, forKey: onboardingCompletedKey)
        return userDefaults.bool(forKey: onboardingCompletedKey)
    }
    
    func completeOnboarding() async throws {
//        userDefaults.set(true, forKey: onboardingCompletedKey)
    }
} 
