import Foundation
@testable import Runnieri

final class MockStartActivityInteractor: StartActivityUseCase {
    var wasExecuted = false
    
    func execute() {
        wasExecuted = true
    }
}
