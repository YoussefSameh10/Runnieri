import Foundation
import Combine

class PreviewActivitiesRepo: ActivitiesRepository, ObservableObject {
    var activitiesPublisher = CurrentValueSubject<[Activity], Never>([]).eraseToAnyPublisher()
    var caloriesPublisher = CurrentValueSubject<Double, Never>(0.0).eraseToAnyPublisher()
    
    func addActivity(distanceInMeters: Int, startDate: Date, durationInSeconds: TimeInterval) async { }
    func requestHealthKitAuthorization() async throws -> Bool { return true }
    func startLiveCalorieTracking() async { }
    func stopLiveCalorieTracking() async { }
}
