import Foundation

struct OnboardingUIModel: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let imageName: String
    let permissionType: PermissionType?
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        imageName: String,
        permissionType: PermissionType? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.imageName = imageName
        self.permissionType = permissionType
    }
}
