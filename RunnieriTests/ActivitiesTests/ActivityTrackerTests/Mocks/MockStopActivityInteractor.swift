import Foundation
@testable import Runnieri

final class MockStopActivityInteractor: StopActivityUseCase {
    var wasExecuted = false
    var lastDistance: Int?
    var lastDuration: TimeInterval?
    var lastStartDate: Date?
    
    func execute(distance: Int, duration: TimeInterval, startDate: Date) async {
        wasExecuted = true
        lastDistance = distance
        lastDuration = duration
        lastStartDate = startDate
    }
} 
