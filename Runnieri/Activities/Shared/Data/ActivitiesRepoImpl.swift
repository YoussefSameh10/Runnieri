import Foundation
import SwiftData
import Combine
import HealthKit

@DataAccessActor
final class ActivitiesRepoImpl: ActivitiesRepository {
    private let _activitiesPublisher = CurrentValueSubject<[Activity], Never>([])
    var activitiesPublisher: AnyPublisher<[Activity], Never> {
        _activitiesPublisher.eraseToAnyPublisher()
    }
    
    var caloriesPublisher: AnyPublisher<Double, Never> {
        healthKitDataSource.caloriesPublisher
    }
    
    private let localDataSource: any DataSource
    private let mapper: ActivityDataMapper
    private let taskProvider: TaskProvider
    private let healthKitDataSource: HealthDataSource
    
    init(
        localDataSource: any DataSource = SwiftDataWrapper.getInstance(),
        taskProvider: TaskProvider = RealTaskProvider(),
        healthKitDataSource: HealthDataSource = HealthKitService()
    ) {
        self.localDataSource = localDataSource
        self.taskProvider = taskProvider
        self.mapper = ActivityDataMapper()
        self.healthKitDataSource = healthKitDataSource
        
        taskProvider.run { [weak self] in
            await self?.loadActivities()
        }
    }
    
    func startLiveCalorieTracking() async throws {
        try await healthKitDataSource.startLiveCalorieTracking()
    }
    
    func stopLiveCalorieTracking() async throws {
        try await healthKitDataSource.stopLiveCalorieTracking()
    }
    
    func addActivity(distanceInMeters: Int, startDate: Date, durationInSeconds: TimeInterval) async throws {
        let endDate = startDate.addingTimeInterval(durationInSeconds)
        
        do {
            let caloriesBurned = try await healthKitDataSource.fetchActiveEnergyBurned(from: startDate, to: endDate)
            let activity = Activity(
                distanceInMeters: distanceInMeters,
                durationInSeconds: durationInSeconds,
                date: endDate,
                caloriesBurned: Int(round(caloriesBurned))
            )
            let dataModel = mapper.dataModel(from: activity)
            
            try await localDataSource.save(dataModel)
            await loadActivities()
        } catch let error as ActivityError {
            throw error
        } catch {
            throw ActivityError.unknown(error)
        }
    }
    
    private func loadActivities() async {
        do {
            let dataModels = try await localDataSource.fetch(ActivityDataModel.self, predicate: nil, sortBy: [])
            _activitiesPublisher.send(dataModels.map { mapper.domainModel(from: $0) })
        } catch {
            print("Error loading activities: \(error)")
            _activitiesPublisher.send([])
        }
    }
} 
