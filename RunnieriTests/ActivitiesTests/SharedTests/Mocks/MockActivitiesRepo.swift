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
    private(set) var isTrackingActive = false
    
    func addActivity(_ activity: Activity) async throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        
        activities.insert(activity, at: 0)
    }
    
    func startLiveCalorieTracking() async throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error in startLiveCalorieTracking"])
        }
        isTrackingActive = true
    }
    
    func stopLiveCalorieTracking() async throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock error in stopLiveCalorieTracking"])
        }
        isTrackingActive = false
    }
} 
