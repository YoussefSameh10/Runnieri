import Foundation
import Combine

@MainActor
class PreviewActivitiesRepo: ActivitiesRepository {
    var activitiesStream = AsyncStream<[Activity]>.makeStream().stream
    var caloriesStream = AsyncStream<Double>.makeStream().stream
    
    func addActivity(distanceInMeters: Int, startDate: Date, durationInSeconds: TimeInterval) async { }
    func requestHealthKitAuthorization() async throws -> Bool { return true }
    func startLiveCalorieTracking() async { }
    func stopLiveCalorieTracking() async { }
}
