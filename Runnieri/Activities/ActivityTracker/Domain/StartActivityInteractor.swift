import Foundation

final class StartActivityInteractor: StartActivityUseCase {
    private let activitiesRepository: ActivitiesRepository
    private let locationService: LocationService
    
    init(activitiesRepository: ActivitiesRepository, locationService: LocationService) {
        self.activitiesRepository = activitiesRepository
        self.locationService = locationService
    }
    
    func execute() async throws {
        do {
            // Start location tracking first
            locationService.reset()
            locationService.startUpdating()
            
            // Then start calorie tracking
            await activitiesRepository.startLiveCalorieTracking()
        } catch {
            // If anything fails, stop location tracking
            locationService.stopUpdating()
            throw StartActivityError.trackingError(error)
        }
    }
} 
