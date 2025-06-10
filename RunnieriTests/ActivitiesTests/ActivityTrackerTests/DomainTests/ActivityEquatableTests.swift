import Testing
import Foundation
@testable import Runnieri

struct ActivityEquatableTests {
    @Test(
        "Activity Equatable should handle equality correctly",
        arguments: [
            (
                activity1: Activity(
                    id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
                    distanceInMeters: 1500,
                    durationInSeconds: TimeInterval.oneHour,
                    date: Date(timeIntervalSince1970: 0),
                    caloriesBurned: 100
                ),
                activity2: Activity(
                    id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
                    distanceInMeters: 1500,
                    durationInSeconds: TimeInterval.oneHour,
                    date: Date(timeIntervalSince1970: 0),
                    caloriesBurned: 100
                ),
                expectedIsEqual: true,
                description: "same ID and properties"
            ),
            (
                activity1: Activity(
                    id: UUID(),
                    distanceInMeters: 1500,
                    durationInSeconds: TimeInterval.oneHour,
                    date: Date(timeIntervalSince1970: 0),
                    caloriesBurned: 100
                ),
                activity2: Activity(
                    id: UUID(),
                    distanceInMeters: 1500,
                    durationInSeconds: TimeInterval.oneHour,
                    date: Date(timeIntervalSince1970: 0),
                    caloriesBurned: 100
                ),
                expectedIsEqual: false,
                description: "different IDs"
            )
        ]
    )
    func testActivityEquatable(activity1: Activity, activity2: Activity, expectedIsEqual: Bool, description: String) {
        // When
        let actualIsEqual = activity1 == activity2
        
        // Then
        #expect(actualIsEqual == expectedIsEqual, "Should return \(expectedIsEqual) for \(description)")
    }
} 