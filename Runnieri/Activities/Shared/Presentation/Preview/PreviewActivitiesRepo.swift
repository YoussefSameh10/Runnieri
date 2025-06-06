import Foundation

@MainActor
class PreviewActivitiesRepo: ActivitiesRepository {
    var activitiesPublisher = AsyncStream<[Activity]>.makeStream().stream
    var caloriesPublisher = AsyncStream<Double>.makeStream().stream
    
    func addActivity(distanceInMeters: Int, startDate: Date, durationInSeconds: TimeInterval) async { }
    func requestHealthKitAuthorization() async throws -> Bool { return true }
    func startLiveCalorieTracking() async { }
    func stopLiveCalorieTracking() async { }
}
