import Foundation
import Combine

final class RequestPermissionInteractor: RequestPermissionUseCase {
    private let locationService: LocationService
    private let healthDataSource: HealthDataSource
    
    init(
        locationService: LocationService,
        healthDataSource: HealthDataSource
    ) {
        self.locationService = locationService
        self.healthDataSource = healthDataSource
    }
    
    func execute(for type: PermissionType) async throws {
        switch type {
        case .location:
            locationService.requestAuthorization()
        case .healthKit:
            try await healthDataSource.requestAuthorization()
        }
    }
}
