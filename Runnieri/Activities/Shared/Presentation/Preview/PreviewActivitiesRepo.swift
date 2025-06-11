import Foundation
import Combine

class PreviewActivitiesRepo: ActivitiesRepository, ObservableObject {
    var activitiesPublisher = CurrentValueSubject<[Activity], Never>([]).eraseToAnyPublisher()
    var caloriesPublisher = CurrentValueSubject<Double, Never>(0.0).eraseToAnyPublisher()
    
    func addActivity(distanceInMeters: Int, startTime: TimeInterval, durationInSeconds: TimeInterval) { }
    func requestHealthKitAuthorization() throws -> Bool { return true }
    func startLiveCalorieTracking() { }
    func stopLiveCalorieTracking() { }
}
