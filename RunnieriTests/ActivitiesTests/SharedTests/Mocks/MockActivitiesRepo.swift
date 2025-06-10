import Foundation
import Combine
@testable import Runnieri

class MockActivitiesRepo: ActivitiesRepository {
    @Published var activities: [Activity] = []
    var activitiesPublisher: AnyPublisher<[Activity], Never> {
        $activities.eraseToAnyPublisher()
    }
    
    @Published var calories = 0.0
    var caloriesPublisher: AnyPublisher<Double, Never> {
        $calories.eraseToAnyPublisher()
    }
    var shouldThrowError = false
    
    func addActivity(distanceInMeters: Int, startDate: Date, durationInSeconds: TimeInterval) async throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        
        let activity = Activity(
            distanceInMeters: distanceInMeters,
            durationInSeconds: durationInSeconds,
            date: startDate.addingTimeInterval(durationInSeconds),
            caloriesBurned: Int(round(calories))
        )
        activities.insert(activity, at: 0)
    }
    
    func startLiveCalorieTracking() async throws { }
    func stopLiveCalorieTracking() async throws { }
} 
