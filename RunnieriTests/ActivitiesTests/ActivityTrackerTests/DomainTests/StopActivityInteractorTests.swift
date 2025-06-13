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
        sut = StopActivityInteractor(activitiesRepository: activitiesRepo, locationService: locationService)
    }
    
    // MARK: - Execute Tests
    
    @Test("Execute should stop location updates")
    func testExecuteStopsLocationUpdates() async throws {
        // Given
        let startTime = Date().timeIntervalSince1970
        
        // When
        try await sut.execute(
            Activity(
                distanceInMeters: 1000,
                durationInSeconds: .oneHour,
                date: startTime.absoluteDate,
                caloriesBurned: 100
            )
        )
        
        // Then
        let expectedOperations = [MockLocationService.Operation.stop]
        #expect(locationService.operations == expectedOperations, "Stop operation should be executed")
    }
    
    @Test("Execute should add activity when distance and duration are positive")
    func testExecuteAddsActivityWhenDistanceAndDurationArePositive() async throws {
        // Given
        let expectedDistance = 1000
        let expectedDuration = TimeInterval.oneHour
        let expectedCalories = 100
        let expectedDate = Date()
        
        // When
        try await sut.execute(
            Activity(
                distanceInMeters: expectedDistance,
                durationInSeconds: expectedDuration,
                date: expectedDate,
                caloriesBurned: expectedCalories
            )
        )
        
        // Then
        let expectedActivityCount = 1
        #expect(activitiesRepo.activities.count == expectedActivityCount)
        #expect(activitiesRepo.activities.first?.distanceInMeters == expectedDistance)
        #expect(activitiesRepo.activities.first?.durationInSeconds == expectedDuration)
        #expect(activitiesRepo.activities.first?.caloriesBurned == expectedCalories)
        #expect(activitiesRepo.activities.first?.date == expectedDate)
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
    ) async throws {
        // When
        try await sut.execute(
            Activity(
                distanceInMeters: distance,
                durationInSeconds: duration,
                date: Date(),
                caloriesBurned: 100
            )
        )
        
        // Then
        let actualIsActivityAdded = !activitiesRepo.activities.isEmpty
        #expect(
            actualIsActivityAdded == expectedIsActivityAdded,
            "Activity should \(expectedIsActivityAdded ? "be added" : "not be added") for \(description)"
        )
    }
    
    @Test("Execute should throw error when repository fails")
    func testExecuteThrowsErrorWhenRepositoryFails() async {
        // Given
        activitiesRepo.shouldThrowError = true
        
        // When
        do {
            try await sut.execute(
                Activity(
                    distanceInMeters: 1000,
                    durationInSeconds: .oneHour,
                    date: Date(),
                    caloriesBurned: 100
                )
            )
            Issue.record("Expected error to be thrown")
        } catch {
            // Then
            let error = error as NSError
            #expect(error.domain == "MockError", "Error should be from mock repository")
            #expect(error.code == -1, "Error should have mock error code")
            #expect(locationService.operations.contains(.stop), "Location service should be stopped when error occurs")
        }
    }
} 
