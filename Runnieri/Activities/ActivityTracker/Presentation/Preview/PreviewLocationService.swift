import Foundation

class PreviewLocationService: LocationService {
    @AsyncStreamed var authStatus: LocationAuthState = .authorizedWhenInUse
    var authStatusPublisher: AsyncStream<LocationAuthState> { $authStatus }
    
    @AsyncStreamed var distance: Int = 1234
    var distancePublisher: AsyncStream<Int> { $distance }

    func requestAuthorization() {}
    func startUpdating() {}
    func stopUpdating() {}
    func reset() {}
} 
