import Foundation

final class StopActivityInteractor: StopActivityUseCase {
    private let activitiesRepo: ActivitiesRepository
    private let locationService: LocationService
    
    init(activitiesRepo: ActivitiesRepository, locationService: LocationService) {
        self.activitiesRepo = activitiesRepo
        self.locationService = locationService
    }
    
    func execute(distance: Int, duration: TimeInterval, startTime: TimeInterval) async {
        locationService.stopUpdating()
//        if distance > 0 && duration > 0 {
            let date = Date(timeIntervalSince1970: startTime)
            await activitiesRepo.addActivity(distanceInMeters: distance, startDate: date, durationInSeconds: duration)
//        }
    }
} 
