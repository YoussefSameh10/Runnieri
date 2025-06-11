import Foundation
import Combine

protocol ActivitiesRepository {
    var activitiesPublisher: AnyPublisher<[Activity], Never> { get }
    var caloriesPublisher: AnyPublisher<Double, Never> { get }
    
    func addActivity(_ activity: Activity) async throws
    func startLiveCalorieTracking() async throws
    func stopLiveCalorieTracking() async throws
}
