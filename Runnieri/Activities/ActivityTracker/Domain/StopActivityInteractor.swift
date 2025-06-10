import Foundation

final class StopActivityInteractor: StopActivityUseCase {
    private let activitiesRepository: ActivitiesRepository
    private let locationService: LocationService
    
    init(activitiesRepository: ActivitiesRepository, locationService: LocationService) {
        self.activitiesRepository = activitiesRepository
        self.locationService = locationService
    }
    
    func execute(distance: Int, duration: TimeInterval, startTime: TimeInterval) async throws {
        // Stop all tracking services
        locationService.stopUpdating()
        try await activitiesRepository.stopLiveCalorieTracking()
        
        guard distance > 0 && duration > 0 else { return }
        
        // Save the activity
        let date = Date(timeIntervalSince1970: startTime)
        try await activitiesRepository.addActivity(distanceInMeters: distance, startDate: date, durationInSeconds: duration)
    }
} 
