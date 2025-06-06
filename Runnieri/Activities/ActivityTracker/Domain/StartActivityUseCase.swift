import Foundation

enum StartActivityError: Error {
    case notAuthorized
    case trackingError(Error)
}

protocol StartActivityUseCase {
    func execute() async throws
} 
