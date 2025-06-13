import Foundation
import Combine
@testable import Runnieri

final class MockLocationService: LocationService {
    enum Operation: String {
        case reset
        case start
        case stop
        case requestAuthorization
    }
    
    @Published var distance: Int = 0
    @Published var authorizationStatus: LocationAuthState = .notDetermined
    
    var distancePublisher: Published<Int>.Publisher { $distance }
    var authorizationStatusPublisher: Published<LocationAuthState>.Publisher { $authorizationStatus }
    
    var operations: [Operation] = []
    
    func requestAuthorization() {
        operations.append(.requestAuthorization)
    }
    
    func startUpdating() {
        operations.append(.start)
    }
    
    func stopUpdating() {
        operations.append(.stop)
    }
    
    func reset() {
        distance = 0
        operations.append(.reset)
    }
} 
