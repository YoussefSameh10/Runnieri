import Testing
import Foundation
@testable import Runnieri

struct CompleteOnboardingInteractorTests {
    private var sut: CompleteOnboardingInteractor
    private var onboardingRepository: MockOnboardingRepository
    
    init() {
        onboardingRepository = MockOnboardingRepository()
        sut = CompleteOnboardingInteractor(onboardingRepository: onboardingRepository)
    }
    
    // MARK: - Execute Tests
    @Test("Execute should call repository to complete onboarding")
    func testExecuteCallsRepositoryToCompleteOnboarding() async throws {
        // When
        try await sut.execute()
        
        // Then
        #expect(onboardingRepository.isOnboardingCompleted)
    }
    
    @Test("Execute should throw error when repository fails")
    func testExecuteThrowsErrorWhenRepositoryFails() async {
        // Given
        onboardingRepository.shouldThrowError = true
        
        // When
        do {
            try await sut.execute()
            Issue.record("Expected error to be thrown")
        } catch {
            // Then
            let error = error as NSError
            #expect(error.domain == "MockError", "Error should be from mock repository")
            #expect(error.code == -1, "Error should have mock error code")
        }
    }
}
