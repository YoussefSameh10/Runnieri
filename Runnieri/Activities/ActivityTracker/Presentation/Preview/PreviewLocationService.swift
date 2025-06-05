import Foundation
import Combine

class PreviewLocationService: LocationService {
    @Published private(set) var distance: Int = 1234
    @Published private(set) var authorizationStatus: LocationAuthState = .authorizedWhenInUse
    
    var distancePublisher: Published<Int>.Publisher { $distance }
    var authorizationStatusPublisher: Published<LocationAuthState>.Publisher { $authorizationStatus }

    func requestAuthorization() {}
    func startUpdating() {}
    func stopUpdating() {}
    func reset() {}
} 
