import Foundation

final class StopActivityInteractor: StopActivityUseCase {
    private let activitiesRepository: ActivitiesRepository
    private let locationService: LocationService
    
    init(activitiesRepository: ActivitiesRepository, locationService: LocationService) {
        self.activitiesRepository = activitiesRepository
        self.locationService = locationService
    }
    
    func execute(distance: Int, duration: TimeInterval, startTime: TimeInterval) async {
        // Stop all tracking services
        locationService.stopUpdating()
        await activitiesRepository.stopLiveCalorieTracking()
        
        // Save the activity
        let date = Date(timeIntervalSince1970: startTime)
        await activitiesRepository.addActivity(distanceInMeters: distance, startDate: date, durationInSeconds: duration)
    }
} 
