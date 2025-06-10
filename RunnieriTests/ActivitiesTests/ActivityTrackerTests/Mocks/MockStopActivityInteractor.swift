import Foundation
@testable import Runnieri

final class MockStopActivityInteractor: StopActivityUseCase {
    var wasExecuted = false
    var lastDistance: Int?
    var lastDuration: TimeInterval?
    var lastStartTime: TimeInterval?
    
    func execute(distance: Int, duration: TimeInterval, startTime: TimeInterval) async throws {
        wasExecuted = true
        lastDistance = distance
        lastDuration = duration
        lastStartTime = startTime
    }
} 
