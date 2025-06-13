import Testing
import Foundation
@testable import Runnieri

struct ActivityMapperTests {
    private var sut: ActivityMapper
    
    init() {
        sut = ActivityMapper(locale: Locale(identifier: "en_US"))
    }
    
    // MARK: - UI Model From Domain Model Tests
    
    @Test(
        "Map from domain model should correctly format various distances",
        arguments: [
            (meters: 0, expectedDistance: "0.00 km"),
            (meters: 1, expectedDistance: "0.00 km"),
            (meters: 999, expectedDistance: "1.00 km"),
            (meters: 1000, expectedDistance: "1.00 km"),
            (meters: 1500, expectedDistance: "1.50 km"),
            (meters: 9999, expectedDistance: "10.00 km"),
            (meters: 10000, expectedDistance: "10.00 km"),
            (meters: 100000, expectedDistance: "100.00 km"),
            (meters: 999999, expectedDistance: "1000.00 km"),
            (meters: 1000000, expectedDistance: "1000.00 km")
        ]
    )
    func testMapFromDomainModelFormatsVariousDistances(meters: Int, expectedDistance: String) {
        // Given
        let activity = Activity(
            distanceInMeters: meters,
            durationInSeconds: TimeInterval.oneHour,
            date: Date(),
            caloriesBurned: 100
        )
        
        // When
        // Then
        #expect(sut.uiModel(from: activity).distance == expectedDistance)
    }
        
    @Test(
        "Map from domain model should correctly format various durations",
        arguments: [
            (seconds: 0.0, expectedDuration: "00:00:00"),
            (seconds: TimeInterval.oneSecond, expectedDuration: "00:00:01"),
            (seconds: TimeInterval.oneMinute - TimeInterval.oneSecond, expectedDuration: "00:00:59"),
            (seconds: TimeInterval.oneMinute, expectedDuration: "00:01:00"),
            (seconds: TimeInterval.oneMinute + TimeInterval.oneSecond, expectedDuration: "00:01:01"),
            (seconds: TimeInterval.oneHour - TimeInterval.oneSecond, expectedDuration: "00:59:59"),
            (seconds: TimeInterval.oneHour, expectedDuration: "01:00:00"),
            (seconds: TimeInterval.oneHour + TimeInterval.oneMinute + TimeInterval.oneSecond, expectedDuration: "01:01:01"),
            (seconds: TimeInterval.oneDay - TimeInterval.oneSecond, expectedDuration: "23:59:59"),
            (seconds: TimeInterval.oneDay, expectedDuration: "24:00:00"),
            (seconds: TimeInterval.oneDay + TimeInterval.oneHour, expectedDuration: "25:00:00")
        ]
    )
    func testMapFromDomainModelFormatsVariousDurations(seconds: TimeInterval, expectedDuration: String) {
        // Given
        let activity = Activity(
            distanceInMeters: 1000,
            durationInSeconds: seconds,
            date: Date(),
            caloriesBurned: 100
        )
        
        // When
        // Then
        #expect(sut.uiModel(from: activity).duration == expectedDuration)
    }
        
    @Test(
        "Map from domain model should correctly format various dates",
        arguments: [
            (date: TimeInterval.zero.absoluteDate, expectedDate: "Jan 1, 1970"),
            (date: TimeInterval.oneDay.absoluteDate, expectedDate: "Jan 2, 1970"),
            (date: (TimeInterval.oneDay * 31).absoluteDate, expectedDate: "Feb 1, 1970")
        ]
    )
    func testMapFromDomainModelFormatsVariousDates(date: Date, expectedDate: String) {
        // Given
        let activity = Activity(
            distanceInMeters: 1000,
            durationInSeconds: TimeInterval.oneHour,
            date: date,
            caloriesBurned: 100
        )
        
        // When
        // Then
        #expect(sut.uiModel(from: activity).date == expectedDate)
    }
        
    @Test(
        "Map from domain model should correctly format various calories",
        arguments: [
            (calories: 0, expectedCalories: "0 kcal"),
            (calories: 1, expectedCalories: "1 kcal"),
            (calories: 10000, expectedCalories: "10000 kcal"),
            (calories: -100, expectedCalories: "-100 kcal")
        ]
    )
    func testMapFromDomainModelFormatsVariousCalories(calories: Int, expectedCalories: String) {
        // Given
        let activity = Activity(
            distanceInMeters: 1000,
            durationInSeconds: TimeInterval.oneHour,
            date: Date(),
            caloriesBurned: calories
        )
        
        // When
        // Then
        #expect(sut.uiModel(from: activity).calories == expectedCalories)
    }
    
    // MARK: - ID Preservation Tests
    
    @Test("Map from domain model should preserve activity ID")
    func testMapFromDomainModelPreservesActivityId() {
        // Given
        let activity = Activity(
            distanceInMeters: 1000,
            durationInSeconds: TimeInterval.oneHour,
            date: Date(),
            caloriesBurned: 100
        )
        
        // When
        // Then
        #expect(sut.uiModel(from: activity).id == activity.id)
    }
    
    // MARK: - Edge Cases Tests
    
    @Test(
        "Map from domain model should handle edge cases correctly",
        arguments: [
            (
                activity: Activity(
                    distanceInMeters: -1000,
                    durationInSeconds: -TimeInterval.oneHour,
                    date: Date(),
                    caloriesBurned: -100
                ),
                expectedDistance: "-1.00 km",
                expectedDuration: "-1:00:00",
                expectedCalories: "-100 kcal"
            )
        ]
    )
    func testMapFromDomainModelHandlesEdgeCases(activity: Activity, expectedDistance: String, expectedDuration: String, expectedCalories: String) {
        // When
        let actualUIModel = sut.uiModel(from: activity)
        
        // Then
        #expect(actualUIModel.distance == expectedDistance)
        #expect(actualUIModel.duration == expectedDuration)
        #expect(actualUIModel.calories == expectedCalories)
    }
    
    // MARK: - UI Model From UI Live Model Tests
    
    @Test(
        "Map from ui live model should correctly format various distances",
        arguments: [
            (meters: 0, expectedDistance: "0.00 km"),
            (meters: 1, expectedDistance: "0.00 km"),
            (meters: 999, expectedDistance: "1.00 km"),
            (meters: 1000, expectedDistance: "1.00 km"),
            (meters: 1500, expectedDistance: "1.50 km"),
            (meters: 9999, expectedDistance: "10.00 km"),
            (meters: 10000, expectedDistance: "10.00 km"),
            (meters: 100000, expectedDistance: "100.00 km"),
            (meters: 999999, expectedDistance: "1000.00 km"),
            (meters: 1000000, expectedDistance: "1000.00 km")
        ]
    )
    func testMapFromUILiveModelFormatsVariousDistances(meters: Int, expectedDistance: String) {
        // Given
        let activity = LiveActivityUIModel(
            id: UUID(),
            distance: meters,
            duration: TimeInterval.oneHour,
            startTime: Date().timeIntervalSince1970,
            calories: 100
        )
        
        // When
        // Then
        #expect(sut.uiModel(from: activity).distance == expectedDistance)
    }
        
    @Test(
        "Map from ui live model should correctly format various durations",
        arguments: [
            (seconds: 0.0, expectedDuration: "00:00:00"),
            (seconds: TimeInterval.oneSecond, expectedDuration: "00:00:01"),
            (seconds: TimeInterval.oneMinute - TimeInterval.oneSecond, expectedDuration: "00:00:59"),
            (seconds: TimeInterval.oneMinute, expectedDuration: "00:01:00"),
            (seconds: TimeInterval.oneMinute + TimeInterval.oneSecond, expectedDuration: "00:01:01"),
            (seconds: TimeInterval.oneHour - TimeInterval.oneSecond, expectedDuration: "00:59:59"),
            (seconds: TimeInterval.oneHour, expectedDuration: "01:00:00"),
            (seconds: TimeInterval.oneHour + TimeInterval.oneMinute + TimeInterval.oneSecond, expectedDuration: "01:01:01"),
            (seconds: TimeInterval.oneDay - TimeInterval.oneSecond, expectedDuration: "23:59:59"),
            (seconds: TimeInterval.oneDay, expectedDuration: "24:00:00"),
            (seconds: TimeInterval.oneDay + TimeInterval.oneHour, expectedDuration: "25:00:00")
        ]
    )
    func testMapFromUILiveModelFormatsVariousDurations(seconds: TimeInterval, expectedDuration: String) {
        // Given
        let activity = LiveActivityUIModel(
            id: UUID(),
            distance: 1000,
            duration: seconds,
            startTime: Date().timeIntervalSince1970,
            calories: 100
        )
        
        // When
        // Then
        #expect(sut.uiModel(from: activity).duration == expectedDuration)
    }
        
    @Test(
        "Map from ui live model should correctly format various dates",
        arguments: [
            (startTime: TimeInterval.zero, expectedDate: "Jan 1, 1970"),
            (startTime: TimeInterval.oneDay, expectedDate: "Jan 2, 1970"),
            (startTime: TimeInterval.oneDay * 31, expectedDate: "Feb 1, 1970")
        ]
    )
    func testMapFromUILiveModelFormatsVariousDates(startTime: TimeInterval, expectedDate: String) {
        // Given
        let activity = LiveActivityUIModel(
            id: UUID(),
            distance: 1000,
            duration: TimeInterval.oneHour,
            startTime: startTime,
            calories: 100
        )
        
        // When
        // Then
        #expect(sut.uiModel(from: activity).date == expectedDate)
    }
        
    @Test(
        "Map from ui live model should correctly format various calories",
        arguments: [
            (calories: 0, expectedCalories: "0 kcal"),
            (calories: 1, expectedCalories: "1 kcal"),
            (calories: 10000, expectedCalories: "10000 kcal"),
            (calories: -100, expectedCalories: "-100 kcal")
        ]
    )
    func testMapFromUILiveModelFormatsVariousCalories(calories: Int, expectedCalories: String) {
        // Given
        let activity = LiveActivityUIModel(
            id: UUID(),
            distance: 1000,
            duration: TimeInterval.oneHour,
            startTime: Date().timeIntervalSince1970,
            calories: calories
        )
        
        // When
        // Then
        #expect(sut.uiModel(from: activity).calories == expectedCalories)
    }
    
    // MARK: - ID Preservation Tests
    
    @Test("Map from ui live model should preserve activity ID")
    func testMapFromUILiveModelPreservesActivityId() {
        // Given
        let activity = LiveActivityUIModel(
            id: UUID(),
            distance: 1000,
            duration: TimeInterval.oneHour,
            startTime: Date().timeIntervalSince1970,
            calories: 100
        )
        
        // When
        // Then
        #expect(sut.uiModel(from: activity).id == activity.id)
    }
    
    // MARK: - Edge Cases Tests
    
    @Test(
        "Map from ui live model should handle edge cases correctly",
        arguments: [
            (
                activity: LiveActivityUIModel(
                    id: UUID(),
                    distance: -1000,
                    duration: -TimeInterval.oneHour,
                    startTime: Date().timeIntervalSince1970,
                    calories: -100
                ),
                expectedDistance: "-1.00 km",
                expectedDuration: "-1:00:00",
                expectedCalories: "-100 kcal"
            )
        ]
    )
    func testMapFromUILiveModelHandlesEdgeCases(activity: LiveActivityUIModel, expectedDistance: String, expectedDuration: String, expectedCalories: String) {
        // When
        let actualUIModel = sut.uiModel(from: activity)
        
        // Then
        #expect(actualUIModel.distance == expectedDistance)
        #expect(actualUIModel.duration == expectedDuration)
        #expect(actualUIModel.calories == expectedCalories)
    }
    
    // MARK: Domain Model from UI Live Model
    @Test(
        "Map from ui live model to domain model",
        arguments: [
            (
                liveActivity: LiveActivityUIModel(
                    id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
                    distance: 1000,
                    duration: TimeInterval.oneHour,
                    startTime: TimeInterval.zero,
                    calories: 100
                ),
                expectedDomainModel: Activity(
                    id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
                    distanceInMeters: 1000,
                    durationInSeconds: TimeInterval.oneHour,
                    date: TimeInterval.zero.absoluteDate,
                    caloriesBurned: 100
                )
            )
        ]
    )
    func testMapFromUILiveModelToDomainModelHandlesEdgeCases(liveActivity: LiveActivityUIModel, expectedDomainModel: Activity) {
        // When
        let actualDomainModel = sut.domainModel(from: liveActivity)
        
        // Then
        #expect(actualDomainModel != expectedDomainModel)
    }
}
