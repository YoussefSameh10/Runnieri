import Foundation
import HealthKit
import Combine

final class HealthKitService: HealthDataSource {
    private let healthStore = HKHealthStore()
    private let _caloriesPublisher = CurrentValueSubject<Double, Never>(0.0)
    private var activityStartDate: Date?
    private var observerQuery: HKObserverQuery?
    private var backgroundDeliveryEnabled = false
    
    var caloriesPublisher: AnyPublisher<Double, Never> {
        _caloriesPublisher.eraseToAnyPublisher()
    }
    
    private func requestAuthorization() async throws -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw NSError(domain: "com.yourapp.healthkit", code: 101, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device."])
        }
        
        guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            throw NSError(domain: "com.yourapp.healthkit", code: 102, userInfo: [NSLocalizedDescriptionKey: "Active Energy Burned type is not available."])
        }
        
        let typesToRead: Set<HKObjectType> = [activeEnergyType]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            return true
        } catch {
            print("Error requesting HealthKit authorization: \(error)")
            return false
        }
    }
    
    func startLiveCalorieTracking() async throws {
        let authorized = try await requestAuthorization()
        guard authorized else {
            throw NSError(domain: "com.yourapp.healthkit", code: 103, userInfo: [NSLocalizedDescriptionKey: "HealthKit authorization denied."])
        }
        
        guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        activityStartDate = Date()
        
        // Enable background delivery if not already enabled
        if !backgroundDeliveryEnabled {
            do {
                try await healthStore.enableBackgroundDelivery(for: activeEnergyType, frequency: .immediate)
                backgroundDeliveryEnabled = true
            } catch {
                print("Error enabling background delivery: \(error)")
            }
        }
        
        // Create and execute the observer query
        let query = HKObserverQuery(sampleType: activeEnergyType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Error in observer query: \(error)")
                completionHandler()
                return
            }
            
            // Fetch the latest calories
            self?.fetchLatestCalories()
            completionHandler()
        }
        
        healthStore.execute(query)
        observerQuery = query
    }
    
    func stopLiveCalorieTracking() async {
        if let query = observerQuery {
            healthStore.stop(query)
            observerQuery = nil
        }
        
        if backgroundDeliveryEnabled,
           let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) {
            do {
                try await healthStore.disableBackgroundDelivery(for: activeEnergyType)
                backgroundDeliveryEnabled = false
            } catch {
                print("Error disabling background delivery: \(error)")
            }
        }
        
        activityStartDate = nil
        _caloriesPublisher.send(0.0)
    }
    
    private func fetchLatestCalories() {
        guard let startDate = activityStartDate,
              let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: activeEnergyType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            if let error = error {
                print("Error fetching latest calories: \(error)")
                return
            }
            
            if let sum = result?.sumQuantity() {
                let calories = sum.doubleValue(for: HKUnit.kilocalorie())
                self?._caloriesPublisher.send(calories)
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchActiveEnergyBurned(from startDate: Date, to endDate: Date) async throws -> Double {
        let authorized = try await requestAuthorization()
        guard authorized else {
            throw NSError(domain: "com.yourapp.healthkit", code: 103, userInfo: [NSLocalizedDescriptionKey: "HealthKit authorization denied."])
        }
        
        guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            throw NSError(domain: "com.yourapp.healthkit", code: 102, userInfo: [NSLocalizedDescriptionKey: "Active Energy Burned type is not available."])
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: activeEnergyType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let sumQuantity = result?.sumQuantity() else {
                    continuation.resume(returning: 0.0)
                    return
                }
                
                let kilocalories = sumQuantity.doubleValue(for: HKUnit.kilocalorie())
                continuation.resume(returning: kilocalories)
            }
            
            healthStore.execute(query)
        }
    }
} 
