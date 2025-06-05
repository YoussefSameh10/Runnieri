import Testing
import Foundation
import Combine
@testable import Runnieri

@MainActor
final class ActivityListViewModelTests {
    private var sut: ActivityListViewModel
    private var activitiesRepo: MockActivitiesRepo
    private var cancellables: Set<AnyCancellable>
    private let mapper = ActivityMapper()
    
    init() {
        activitiesRepo = MockActivitiesRepo()
        cancellables = []
        sut = ActivityListViewModel(activitiesRepo: activitiesRepo)
    }
    
    // MARK: - Initial State Tests
    @Test("Initial state should be empty")
    func testInitialState() {
        #expect(sut.activities.isEmpty)
    }
    
    // MARK: - Sorting Tests
    @Test("Activities should be sorted by date in descending order")
    func testActivitiesAreSortedByDateDescending() {
        // Given
        let now = Date()
        let oneDayAgo = now.addingTimeInterval(-TimeInterval.oneDay)
        let oneWeekAgo = now.addingTimeInterval(-TimeInterval.oneWeek)
        
        let oldestActivity = Activity(distanceInMeters: 1000, durationInSeconds: TimeInterval.oneMinute * 10, date: oneWeekAgo)
        let middleActivity = Activity(distanceInMeters: 2000, durationInSeconds: TimeInterval.oneMinute * 20, date: oneDayAgo)
        let newestActivity = Activity(distanceInMeters: 3000, durationInSeconds: TimeInterval.oneMinute * 30, date: now)
        
        // When
        activitiesRepo.activities = [oldestActivity, newestActivity, middleActivity]
        
        // Then
        let expectedActivities = [newestActivity, middleActivity, oldestActivity].map { mapper.uiModel(from: $0) }
        #expect(sut.activities == expectedActivities)
    }
} 
