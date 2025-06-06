import Foundation

protocol StopActivityUseCase {
    func execute(distance: Int, duration: TimeInterval, startTime: TimeInterval) async throws
}
