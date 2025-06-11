import Foundation
@testable import Runnieri

final class MockStopActivityInteractor: StopActivityUseCase {
    var activity: Activity?
    
    func execute(_ activity: Activity) async throws {
        self.activity = activity
    }
} 
