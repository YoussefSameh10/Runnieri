import Foundation

final class StartActivityInteractor: StartActivityUseCase {
    private let activitiesRepo: ActivitiesRepository
    private let locationService: LocationService
    
    init(activitiesRepo: ActivitiesRepository, locationService: LocationService) {
        self.activitiesRepo = activitiesRepo
        self.locationService = locationService
    }
    
    func execute() {
        locationService.reset()
        locationService.startUpdating()
    }
} 
