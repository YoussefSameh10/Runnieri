import Foundation
import Combine

class PreviewActivitiesRepo: ActivitiesRepository, ObservableObject {
    var activitiesPublisher = CurrentValueSubject<[Activity], Never>([]).eraseToAnyPublisher()
    var caloriesPublisher = CurrentValueSubject<Double, Never>(0.0).eraseToAnyPublisher()
    
    func addActivity(_ activity: Activity) { }
    func requestHealthKitAuthorization() throws -> Bool { return true }
    func startLiveCalorieTracking() { }
    func stopLiveCalorieTracking() { }
}
