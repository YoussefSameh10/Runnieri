import Testing
import Foundation
@testable import Runnieri

struct ActivityUIModelEquatableTests {
    @Test(
        "ActivityUIModel Equatable should handle equality correctly",
        arguments: [
            (
                model1: ActivityUIModel(
                    id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
                    distance: "1.50 km",
                    duration: "01:01:01",
                    date: "1 Jan 1970",
                    calories: "100 kcal"
                ),
                model2: ActivityUIModel(
                    id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
                    distance: "1.50 km",
                    duration: "01:01:01",
                    date: "1 Jan 1970",
                    calories: "100 kcal"
                ),
                expectedIsEqual: true,
                description: "same ID and properties"
            ),
            (
                model1: ActivityUIModel(
                    id: UUID(),
                    distance: "1.50 km",
                    duration: "01:01:01",
                    date: "1 Jan 1970",
                    calories: "100 kcal"
                ),
                model2: ActivityUIModel(
                    id: UUID(),
                    distance: "1.50 km",
                    duration: "01:01:01",
                    date: "1 Jan 1970",
                    calories: "100 kcal"
                ),
                expectedIsEqual: false,
                description: "different IDs"
            )
        ]
    )
    func testActivityUIModelEquatable(model1: ActivityUIModel, model2: ActivityUIModel, expectedIsEqual: Bool, description: String) {
        // When
        let actualIsEqual = model1 == model2
        
        // Then
        #expect(actualIsEqual == expectedIsEqual, "Should return \(expectedIsEqual) for \(description)")
    }
}
