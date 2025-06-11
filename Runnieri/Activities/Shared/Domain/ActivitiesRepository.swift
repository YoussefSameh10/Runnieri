import Foundation
import Combine

protocol ActivitiesRepository {
    var activitiesPublisher: AnyPublisher<[Activity], Never> { get }
    var caloriesPublisher: AnyPublisher<Double, Never> { get }
    
    func addActivity(distanceInMeters: Int, startTime: TimeInterval, durationInSeconds: TimeInterval) async throws
    func startLiveCalorieTracking() async throws
    func stopLiveCalorieTracking() async throws
}
