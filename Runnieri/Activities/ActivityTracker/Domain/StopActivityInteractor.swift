import Foundation

final class StopActivityInteractor: StopActivityUseCase {
    private let activitiesRepository: ActivitiesRepository
    private let locationService: LocationService
    
    init(activitiesRepository: ActivitiesRepository, locationService: LocationService) {
        self.activitiesRepository = activitiesRepository
        self.locationService = locationService
    }
    
    func execute(_ activity: Activity) async throws {
        // Stop all tracking services
        locationService.stopUpdating()
        try await activitiesRepository.stopLiveCalorieTracking()
        
        guard activity.distanceInMeters > 0 && activity.durationInSeconds > 0 else { return }
        
        // Save the activity
        try await activitiesRepository.addActivity(activity)
    }
} 
