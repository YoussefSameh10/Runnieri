import Foundation
import SwiftData
import Combine
import HealthKit

@DataAccessActor
final class ActivitiesRepoImpl: ActivitiesRepository {
    private let _activitiesPublisher = CurrentValueSubject<[Activity], Never>([])
    var activitiesPublisher: AnyPublisher<[Activity], Never> {
        _activitiesPublisher.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    private let localDataSource: any DataSource
    private let mapper: ActivityDataMapper
    private let taskProvider: TaskProvider
    private let healthKitService: HealthKitService
    
    init(
        localDataSource: any DataSource = SwiftDataWrapper.getInstance(),
        taskProvider: TaskProvider = RealTaskProvider(),
        healthKitService: HealthKitService = HealthKitService()
    ) {
        self.localDataSource = localDataSource
        self.taskProvider = taskProvider
        self.mapper = ActivityDataMapper()
        self.healthKitService = healthKitService
        
        taskProvider.run { [weak self] in
            await self?.loadActivities()
        }
    }
    
    func addActivity(distanceInMeters: Int, startDate: Date, durationInSeconds: TimeInterval) async {
        let endDate = startDate.addingTimeInterval(durationInSeconds)
        
        healthKitService.requestAuthorization { [weak self] result in
            switch result {
            case .success(true):
                self?.healthKitService.fetchActiveEnergyBurned(from: startDate, to: endDate) { [weak self] result in
                    switch result {
                    case .success(let caloriesBurned):
                        let activity = Activity(
                            distanceInMeters: distanceInMeters,
                            durationInSeconds: durationInSeconds,
                            date: endDate,
                            caloriesBurned: Int(round(caloriesBurned))
                        )
                        let dataModel = self?.mapper.dataModel(from: activity)
                        
                        if let dataModel = dataModel {
                            self?.taskProvider.run { [weak self] in
                                do {
                                    try await self?.localDataSource.save(dataModel)
                                    await self?.loadActivities()
                                } catch {
                                    print("Error saving activity: \(error)")
                                }
                            }
                        }
                        
                    case .failure(let error):
                        print("Error fetching calories from HealthKit: \(error)")
                        self?.saveActivityWithDefaultCalories(distanceInMeters: distanceInMeters, durationInSeconds: durationInSeconds, endDate: endDate)
                    }
                }
            case .success(false):
                print("HealthKit authorization denied.")
                self?.saveActivityWithDefaultCalories(distanceInMeters: distanceInMeters, durationInSeconds: durationInSeconds, endDate: endDate)
            case .failure(let error):
                print("Error requesting HealthKit authorization: \(error)")
                self?.saveActivityWithDefaultCalories(distanceInMeters: distanceInMeters, durationInSeconds: durationInSeconds, endDate: endDate)
            }
        }
    }
    
    private func saveActivityWithDefaultCalories(distanceInMeters: Int, durationInSeconds: TimeInterval, endDate: Date) {
        let activity = Activity(
            distanceInMeters: distanceInMeters,
            durationInSeconds: durationInSeconds,
            date: endDate,
            caloriesBurned: 0
        )
        let dataModel = mapper.dataModel(from: activity)
        
        taskProvider.run { [weak self] in
            do {
                try await self?.localDataSource.save(dataModel)
                await self?.loadActivities()
            } catch {
                print("Error saving activity with default calories: \(error)")
            }
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
