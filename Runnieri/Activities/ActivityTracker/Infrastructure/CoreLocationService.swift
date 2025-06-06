import Foundation
import CoreLocation

class CoreLocationService: NSObject, LocationService {
    @AsyncStreamed var authStatus: LocationAuthState = .notDetermined
    var authStatusPublisher: AsyncStream<LocationAuthState> { $authStatus }
    
    @AsyncStreamed var distance: Int = 0
    var distancePublisher: AsyncStream<Int> { $distance }
    
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 1
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        distance = 0
        lastLocation = nil
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
    
    func reset() {
        distance = 0
        lastLocation = nil
    }
}

extension CoreLocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authStatus = status.toDomainModel()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        if let last = lastLocation {
            let delta = newLocation.distance(from: last)
            if delta > 1 {
                self.distance += Int(delta)
            }
        }
        lastLocation = newLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}

extension CLAuthorizationStatus {
    func toDomainModel() -> LocationAuthState {
        switch self {
        case .notDetermined: .notDetermined
        case .restricted: .restricted
        case .denied: .denied
        case .authorizedAlways: .authorizedAlways
        case .authorizedWhenInUse: .authorizedWhenInUse
        @unknown default: .denied
        }
    }
}
