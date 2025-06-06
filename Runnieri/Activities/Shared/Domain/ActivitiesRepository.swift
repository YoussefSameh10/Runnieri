import Foundation
import Combine

protocol ActivitiesRepository {
    var activitiesPublisher: AnyPublisher<[Activity], Never> { get async }
    var caloriesPublisher: AnyPublisher<Double, Never> { get async }
    
    func addActivity(distanceInMeters: Int, startDate: Date, durationInSeconds: TimeInterval) async
    func startLiveCalorieTracking() async
    func stopLiveCalorieTracking() async
}
