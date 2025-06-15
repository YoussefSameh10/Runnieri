import Testing
import Foundation
@testable import Runnieri

struct RequestPermissionInteractorTests {
    private var sut: RequestPermissionInteractor
    private var locationService: MockLocationService
    private var healthDataSource: MockHealthDataSource
    
    init() {
        locationService = MockLocationService()
        healthDataSource = MockHealthDataSource()
        sut = RequestPermissionInteractor(
            locationService: locationService,
            healthDataSource: healthDataSource
        )
    }
    
    // MARK: - Execute Tests
    @Test("Execute should request location authorization when type is location")
    func testExecuteRequestsLocationAuthorization() async throws {
        // When
        try await sut.execute(for: .location)
        
        // Then
        #expect(locationService.operations.contains(.requestAuthorization))
    }
    
    @Test("Execute should request health authorization when type is healthKit")
    func testExecuteRequestsHealthAuthorization() async throws {
        // When
        try await sut.execute(for: .healthKit)
        
        // Then
        #expect(healthDataSource.wasAuthorizationRequested)
    }
    
    @Test("Execute should throw error when health authorization fails")
    func testExecuteThrowsErrorWhenHealthAuthorizationFails() async {
        // Given
        healthDataSource.shouldThrowError = true
        
        // When
        do {
            try await sut.execute(for: .healthKit)
            Issue.record("Expected error to be thrown")
        } catch {
            // Then
            let error = error as NSError
            #expect(error.domain == "MockError", "Error should be from mock health data source")
            #expect(error.code == -1, "Error should have mock error code")
        }
    }
}
