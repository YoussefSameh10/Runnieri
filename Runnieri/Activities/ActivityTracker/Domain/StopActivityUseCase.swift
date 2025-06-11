import Foundation

protocol StopActivityUseCase {
    func execute(_ activity: Activity) async throws
}
