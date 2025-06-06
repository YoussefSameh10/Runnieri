import Foundation
import Combine
@testable import Runnieri

class MockActivitiesRepo: ActivitiesRepository {
    @Published var activities: [Activity] = []
    var activitiesPublisher: AnyPublisher<[Activity], Never> {
        $activities.eraseToAnyPublisher()
    }
    
    var caloriesPublisher = CurrentValueSubject<Double, Never>(0.0).eraseToAnyPublisher()
    
    func addActivity(distanceInMeters: Int, durationInSeconds: TimeInterval) {
        let activity = Activity(distanceInMeters: distanceInMeters, durationInSeconds: durationInSeconds, date: Date())
        activities.insert(activity, at: 0)
    }
    
    func requestHealthKitAuthorization() async throws -> Bool { return true }
    func startLiveCalorieTracking() async { }
    func stopLiveCalorieTracking() async { }
} 
