import Testing
import Foundation
@testable import Runnieri

final class StopActivityInteractorTests {
    private var sut: StopActivityUseCase
    private var activitiesRepo: MockActivitiesRepo
    private var locationService: MockLocationService
    
    init() {
        activitiesRepo = MockActivitiesRepo()
        locationService = MockLocationService()
        sut = StopActivityInteractor(activitiesRepo: activitiesRepo, locationService: locationService)
    }
    
    // MARK: - Execute Tests
    
    @Test("Execute should stop location updates")
    func testExecuteStopsLocationUpdates() async {
        // When
        await sut.execute(distance: 1000, duration: TimeInterval.oneHour)
        
        // Then
        let expectedOperations = [MockLocationService.Operation.stop]
        #expect(locationService.operations == expectedOperations, "Stop operation should be executed")
    }
    
    @Test("Execute should add activity when distance and duration are positive")
    func testExecuteAddsActivityWhenDistanceAndDurationArePositive() async {
        // Given
        let expectedDistance = 1000
        let expectedDuration = TimeInterval.oneHour
        
        // When
        await sut.execute(distance: expectedDistance, duration: expectedDuration)
        
        // Then
        let expectedActivityCount = 1
        #expect(activitiesRepo.activities.count == expectedActivityCount)
        #expect(activitiesRepo.activities.first?.distanceInMeters == expectedDistance)
        #expect(activitiesRepo.activities.first?.durationInSeconds == expectedDuration)
    }
    
    @Test(
        "Execute should validate distance and duration values",
        arguments: [
            (
                distance: 0,
                duration: TimeInterval.oneHour,
                expectedIsActivityAdded: false,
                description: "zero distance"
            ),
            (
                distance: 1000,
                duration: 0,
                expectedIsActivityAdded: false,
                description: "zero duration"
            ),
            (
                distance: 0,
                duration: 0,
                expectedIsActivityAdded: false,
                description: "both zero"
            ),
            (
                distance: -1000,
                duration: TimeInterval.oneHour,
                expectedIsActivityAdded: false,
                description: "negative distance"
            ),
            (
                distance: 1000,
                duration: -TimeInterval.oneHour,
                expectedIsActivityAdded: false,
                description: "negative duration"
            )
        ]
    )
    func testExecuteValidatesDistanceAndDuration(
        distance: Int,
        duration: TimeInterval,
        expectedIsActivityAdded: Bool,
        description: String
    ) async {
        // When
        await sut.execute(distance: distance, duration: duration)
        
        // Then
        #expect((!activitiesRepo.activities.isEmpty) == expectedIsActivityAdded, "Activity should \(expectedIsActivityAdded ? "be added" : "not be added") for \(description)")
    }
} 
