import Foundation
@testable import Runnieri

final class MockOnboardingRepository: OnboardingRepository {
    var shouldThrowError = false
    private(set) var isOnboardingCompleted = false
    
    func completeOnboarding() async throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        isOnboardingCompleted = true
    }
}
