import Foundation
@testable import Runnieri

final class MockRequestPermissionInteractor: RequestPermissionUseCase {
    var lastRequestedPermission: PermissionType?
    var shouldThrowError = false
    
    func execute(for type: PermissionType) async throws {
        lastRequestedPermission = type
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
    }
}
