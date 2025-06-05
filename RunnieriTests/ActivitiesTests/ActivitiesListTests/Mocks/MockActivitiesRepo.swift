import Foundation
import Combine
@testable import Runnieri

class MockActivitiesRepo: ActivitiesRepository {
    @Published var activities: [Activity] = []
    var activitiesPublisher: AnyPublisher<[Activity], Never> {
        $activities.eraseToAnyPublisher()
    }
    
    func addActivity(distanceInMeters: Int, durationInSeconds: TimeInterval) {
        let activity = Activity(distanceInMeters: distanceInMeters, durationInSeconds: durationInSeconds, date: Date())
        activities.insert(activity, at: 0)
    }
} 
