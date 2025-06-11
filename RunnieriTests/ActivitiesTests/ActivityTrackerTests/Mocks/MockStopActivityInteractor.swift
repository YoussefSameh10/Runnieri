import Foundation
@testable import Runnieri

final class MockStopActivityInteractor: StopActivityUseCase {
    var wasExecuted = false
    var lastDistance: Int?
    var lastDuration: TimeInterval?
    var lastStartTime: TimeInterval?
    
    func execute(_ activity: Activity) async throws {
        wasExecuted = true
        lastDistance = activity.distanceInMeters
        lastDuration = activity.durationInSeconds
        lastStartTime = activity.date.timeIntervalSince1970
    }
} 
