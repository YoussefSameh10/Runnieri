import Testing
import Foundation
@testable import Runnieri

struct ActivityPropertiesComparisonTests {
    @Test(
        "Activity isSameProperties should handle all comparison cases correctly",
        arguments: [
            (
                activity1: Activity(
                    distanceInMeters: 1500,
                    durationInSeconds: TimeInterval.oneHour,
                    date: 0.absoluteDate,
                    caloriesBurned: 100
                ),
                activity2: Activity(
                    distanceInMeters: 1500,
                    durationInSeconds: TimeInterval.oneHour,
                    date: 0.absoluteDate,
                    caloriesBurned: 100
                ),
                expectedAreSameProperties: true,
                description: "same properties"
            ),
            (
                activity1: Activity(
                    distanceInMeters: -1500,
                    durationInSeconds: -TimeInterval.oneHour,
                    date: 0.absoluteDate,
                    caloriesBurned: -100
                ),
                activity2: Activity(
                    distanceInMeters: -1500,
                    durationInSeconds: -TimeInterval.oneHour,
                    date: 0.absoluteDate,
                    caloriesBurned: -100
                ),
                expectedAreSameProperties: true,
                description: "negative values"
            ),
            (
                activity1: Activity(
                    distanceInMeters: 0,
                    durationInSeconds: 0,
                    date: 0.absoluteDate,
                    caloriesBurned: 0
                ),
                activity2: Activity(
                    distanceInMeters: 0,
                    durationInSeconds: 0,
                    date: 0.absoluteDate,
                    caloriesBurned: 0
                ),
                expectedAreSameProperties: true,
                description: "zero values"
            ),
            (
                activity1: Activity(
                    distanceInMeters: 1500,
                    durationInSeconds: TimeInterval.oneHour,
                    date: 0.absoluteDate,
                    caloriesBurned: 100
                ),
                activity2: Activity(
                    distanceInMeters: 2500,
                    durationInSeconds: TimeInterval.oneHour,
                    date: 0.absoluteDate,
                    caloriesBurned: 100
                ),
                expectedAreSameProperties: false,
                description: "different distance"
            ),
            (
                activity1: Activity(
                    distanceInMeters: 1500,
                    durationInSeconds: TimeInterval.oneHour,
                    date: 0.absoluteDate,
                    caloriesBurned: 100
                ),
                activity2: Activity(
                    distanceInMeters: 1500,
                    durationInSeconds: TimeInterval.oneHour,
                    date: TimeInterval.oneDay.absoluteDate,
                    caloriesBurned: 100
                ),
                expectedAreSameProperties: false,
                description: "different date"
            ),
            (
                activity1: Activity(
                    distanceInMeters: 1500,
                    durationInSeconds: TimeInterval.oneHour,
                    date: 0.absoluteDate,
                    caloriesBurned: 100
                ),
                activity2: Activity(
                    distanceInMeters: 1500,
                    durationInSeconds: TimeInterval.oneHour,
                    date: 0.absoluteDate,
                    caloriesBurned: 200
                ),
                expectedAreSameProperties: false,
                description: "different calories"
            )
        ]
    )
    func testActivityIsSameProperties(
        activity1: Activity,
        activity2: Activity,
        expectedAreSameProperties: Bool,
        description: String
    ) {
        // When
        let actualIsSameProperties = activity1.isSameProperties(as: activity2)
        
        // Then
        #expect(actualIsSameProperties == expectedAreSameProperties, "Should return \(expectedAreSameProperties) for \(description)")
    }
} 
