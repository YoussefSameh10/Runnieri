import Foundation

protocol ActivitiesRepository {
    var activitiesStream: AsyncStream<[Activity]> { get async }
    var caloriesStream: AsyncStream<Double> { get async }
    
    func addActivity(distanceInMeters: Int, startDate: Date, durationInSeconds: TimeInterval) async throws
    func startLiveCalorieTracking() async throws
    func stopLiveCalorieTracking() async throws
}
