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
} 
