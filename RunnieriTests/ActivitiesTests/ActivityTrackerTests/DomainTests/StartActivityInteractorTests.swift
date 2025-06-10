import Testing
import Foundation
@testable import Runnieri

final class StartActivityInteractorTests {
    private var sut: StartActivityUseCase
    private var activitiesRepo: MockActivitiesRepo
    private var locationService: MockLocationService
    
    init() {
        activitiesRepo = MockActivitiesRepo()
        locationService = MockLocationService()
        sut = StartActivityInteractor(activitiesRepository: activitiesRepo, locationService: locationService)
    }
    
    // MARK: - Execute Tests
    
    @Test("Execute should reset and start location service in correct order")
    func testExecuteResetsAndStartsLocationMServiceInOrder() async throws {
        // When
        try await sut.execute()
        
        // Then
        let expectedOperations = [MockLocationService.Operation.reset, .start]
        #expect(locationService.operations == expectedOperations, "Reset must happen before start to ensure clean state")
    }
    
    @Test("Execute should stop location service and throw error when repository fails")
    func testExecuteStopsLocationServiceAndThrowsErrorWhenRepositoryFails() async {
        // Given
        activitiesRepo.shouldThrowError = true
        
        // When
        do {
            try await sut.execute()
            Issue.record("Expected error to be thrown")
        } catch {
            // Then
            let activityError = error as? ActivityError
            #expect(activityError != nil, "Error should be of type ActivityError")
            #expect(locationService.operations.contains(.stop), "Location service should be stopped when error occurs")
        }
    }
} 
