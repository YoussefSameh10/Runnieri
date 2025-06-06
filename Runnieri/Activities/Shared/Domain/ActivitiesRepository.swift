import Foundation

protocol ActivitiesRepository {
    var activitiesPublisher: AsyncStream<[Activity]> { get async }
    var caloriesPublisher: AsyncStream<Double> { get async }
    
    func addActivity(distanceInMeters: Int, startDate: Date, durationInSeconds: TimeInterval) async throws
    func startLiveCalorieTracking() async throws
    func stopLiveCalorieTracking() async throws
}
