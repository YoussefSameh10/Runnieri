import Foundation

protocol RequestPermissionUseCase {
    func execute(for type: PermissionType) async throws
}

enum PermissionType {
    case location
    case healthKit
} 
