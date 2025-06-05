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
                    date: Date(timeIntervalSince1970: 0)
                ),
                activity2: Activity(
                    distanceInMeters: 1500,
                    durationInSeconds: TimeInterval.oneHour,
                    date: Date(timeIntervalSince1970: 0)
                ),
                expectedAreSameProperties: true,
                description: "same properties"
            ),
            (
                activity1: Activity(
                    distanceInMeters: -1500,
                    durationInSeconds: -TimeInterval.oneHour,
                    date: Date(timeIntervalSince1970: 0)
                ),
                activity2: Activity(
                    distanceInMeters: -1500,
                    durationInSeconds: -TimeInterval.oneHour,
                    date: Date(timeIntervalSince1970: 0)
                ),
                expectedAreSameProperties: true,
                description: "negative values"
            ),
            (
                activity1: Activity(
                    distanceInMeters: 0,
                    durationInSeconds: 0,
                    date: Date(timeIntervalSince1970: 0)
                ),
                activity2: Activity(
                    distanceInMeters: 0,
                    durationInSeconds: 0,
                    date: Date(timeIntervalSince1970: 0)
                ),
                expectedAreSameProperties: true,
                description: "zero values"
            ),
            (
                activity1: Activity(
                    distanceInMeters: 1500,
                    durationInSeconds: TimeInterval.oneHour,
                    date: Date(timeIntervalSince1970: 0)
                ),
                activity2: Activity(
                    distanceInMeters: 2500,
                    durationInSeconds: TimeInterval.oneHour,
                    date: Date(timeIntervalSince1970: 0)
                ),
                expectedAreSameProperties: false,
                description: "different distance"
            ),
            (
                activity1: Activity(
                    distanceInMeters: 1500,
                    durationInSeconds: TimeInterval.oneHour,
                    date: Date(timeIntervalSince1970: 0)
                ),
                activity2: Activity(
                    distanceInMeters: 1500,
                    durationInSeconds: TimeInterval.oneHour,
                    date: Date(timeIntervalSince1970: TimeInterval.oneDay)
                ),
                expectedAreSameProperties: false,
                description: "different date"
            )
        ]
    )
    func testActivityIsSameProperties(activity1: Activity, activity2: Activity, expectedAreSameProperties: Bool, description: String) {
        // When
        // Then
        #expect(activity1.isSameProperties(as: activity2) == expectedAreSameProperties, "Should return \(expectedAreSameProperties) for \(description)")
    }
} 