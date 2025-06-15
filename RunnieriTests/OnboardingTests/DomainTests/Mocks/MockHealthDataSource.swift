import Foundation
import Combine
@testable import Runnieri

final class MockHealthDataSource: HealthDataSource {
    private let _caloriesPublisher = CurrentValueSubject<Double, Never>(0.0)
    var caloriesPublisher: AnyPublisher<Double, Never> {
        _caloriesPublisher.eraseToAnyPublisher()
    }
    
    var wasAuthorizationRequested = false
    var shouldThrowError = false
    
    func requestAuthorization() async throws -> Bool {
        wasAuthorizationRequested = true
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        return true
    }
    
    func startLiveCalorieTracking() async throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
    }
    
    func stopLiveCalorieTracking() async throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
    }
    
    func fetchActiveEnergyBurned(from startTime: TimeInterval, to endTime: TimeInterval) async throws -> Double {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: -1)
        }
        return 0.0
    }
}
