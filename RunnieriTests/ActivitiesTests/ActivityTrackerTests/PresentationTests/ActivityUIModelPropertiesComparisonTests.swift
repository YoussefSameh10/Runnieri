import Testing
import Foundation
@testable import Runnieri

struct ActivityUIModelPropertiesComparisonTests {
    @Test(
        "ActivityUIModel isSameProperties should handle all comparison cases correctly",
        arguments: [
            (
                model1: ActivityUIModel(
                    id: UUID(),
                    distance: "1.50 km",
                    duration: "01:01:01",
                    date: "1 Jan 1970"
                ),
                model2: ActivityUIModel(
                    id: UUID(),
                    distance: "1.50 km",
                    duration: "01:01:01",
                    date: "1 Jan 1970"
                ),
                expectedAreSameProperties: true,
                description: "same properties"
            ),
            (
                model1: ActivityUIModel(
                    id: UUID(),
                    distance: "-1.50 km",
                    duration: "-1:00:00",
                    date: "1 Jan 1970"
                ),
                model2: ActivityUIModel(
                    id: UUID(),
                    distance: "-1.50 km",
                    duration: "-1:00:00",
                    date: "1 Jan 1970"
                ),
                expectedAreSameProperties: true,
                description: "negative values"
            ),
            (
                model1: ActivityUIModel(
                    id: UUID(),
                    distance: "",
                    duration: "",
                    date: ""
                ),
                model2: ActivityUIModel(
                    id: UUID(),
                    distance: "",
                    duration: "",
                    date: ""
                ),
                expectedAreSameProperties: true,
                description: "empty strings"
            ),
            (
                model1: ActivityUIModel(
                    id: UUID(),
                    distance: "1.50 km",
                    duration: "01:01:01",
                    date: "1 Jan 1970"
                ),
                model2: ActivityUIModel(
                    id: UUID(),
                    distance: "2.50 km",
                    duration: "01:01:01",
                    date: "1 Jan 1970"
                ),
                expectedAreSameProperties: false,
                description: "different distance"
            ),
            (
                model1: ActivityUIModel(
                    id: UUID(),
                    distance: "1.50 km",
                    duration: "01:01:01",
                    date: "1 Jan 1970"
                ),
                model2: ActivityUIModel(
                    id: UUID(),
                    distance: "1.50 km",
                    duration: "01:01:01",
                    date: "2 Jan 1970"
                ),
                expectedAreSameProperties: false,
                description: "different date"
            )
        ]
    )
    func testActivityUIModelIsSameProperties(model1: ActivityUIModel, model2: ActivityUIModel, expectedAreSameProperties: Bool, description: String) {
        // When
        // Then
        #expect(model1.isSameProperties(as: model2) == expectedAreSameProperties, "Should return \(expectedAreSameProperties) for \(description)")
    }
} 