import Foundation
@testable import Runnieri

final class MockCompleteOnboardingInteractor: CompleteOnboardingUseCase {
    var wasExecuted = false
    var shouldThrowError = false
    
    func execute() async throws {
        wasExecuted = true
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
    }
}
