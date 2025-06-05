import HealthKit
import Combine

class HealthKitService {
    private let healthStore = HKHealthStore()
    private var liveCaloriesQuery: HKStatisticsCollectionQuery?
    private let _caloriesPublisher: CurrentValueSubject<Double, Never>
    private var activityStartDate: Date?
    private var isAuthorized = false
    
    var caloriesPublisher: AnyPublisher<Double, Never> {
        _caloriesPublisher.eraseToAnyPublisher()
    }
    
    init() {
        _caloriesPublisher = CurrentValueSubject<Double, Never>(0.0)
        requestAuthorization { [weak self] result in
            switch result {
            case .success(let authorized):
                self?.isAuthorized = authorized
            case .failure:
                self?.isAuthorized = false
            }
        }
    }
    
    func requestAuthorization(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(.failure(NSError(domain: "com.yourapp.healthkit", code: 101, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device."])))
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                completion(.success(true))
            } else if let error = error {
                completion(.failure(error))
            } else {
                // Should not happen, but handle it defensively
                completion(.success(false))
            }
        }
    }
    
    func startLiveCalorieTracking() {
        guard isAuthorized,
              let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        activityStartDate = Date()
        guard let startDate = activityStartDate else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: energyType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startDate,
            intervalComponents: DateComponents(second: 1)
        )
        
        query.initialResultsHandler = { [weak self] _, results, error in
            if let error = error {
                print("Error starting live calorie tracking: \(error)")
                return
            }
            
            self?.processCalorieResults(results)
        }
        
        query.statisticsUpdateHandler = { [weak self] _, statistics, _, error in
            if let error = error {
                print("Error updating live calories: \(error)")
                return
            }
            
            if let sum = statistics?.sumQuantity() {
                let calories = sum.doubleValue(for: HKUnit.kilocalorie())
                self?._caloriesPublisher.send(calories)
            }
        }
        
        healthStore.execute(query)
        liveCaloriesQuery = query
    }
    
    func stopLiveCalorieTracking() {
        if let query = liveCaloriesQuery {
            healthStore.stop(query)
            liveCaloriesQuery = nil
        }
        activityStartDate = nil
        _caloriesPublisher.send(0.0)
    }
    
    private func processCalorieResults(_ results: HKStatisticsCollection?) {
        guard let results = results,
              let startDate = activityStartDate else { return }
        
        let now = Date()
        results.enumerateStatistics(from: startDate, to: now) { [weak self] statistics, _ in
            if let sum = statistics.sumQuantity() {
                let calories = sum.doubleValue(for: HKUnit.kilocalorie())
                self?._caloriesPublisher.send(calories)
            }
        }
    }
    
    func fetchActiveEnergyBurned(from startDate: Date, to endDate: Date, completion: @escaping (Result<Double, Error>) -> Void) {
        guard isAuthorized,
              let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(.failure(NSError(domain: "com.yourapp.healthkit", code: 102, userInfo: [NSLocalizedDescriptionKey: "Active Energy Burned type is not available."])))
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let sumQuantity = result?.sumQuantity() else {
                completion(.success(0.0))
                return
            }
            
            let kilocalories = sumQuantity.doubleValue(for: HKUnit.kilocalorie())
            completion(.success(kilocalories))
        }
        
        healthStore.execute(query)
    }
} 
