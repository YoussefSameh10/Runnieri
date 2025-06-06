import Foundation
import CoreLocation

class CoreLocationService: NSObject, ObservableObject, LocationService {
    @Published var distance: Int = 0 // in meters
    @Published var authorizationStatus: LocationAuthState = .notDetermined
    
    var distancePublisher: Published<Int>.Publisher { $distance }
    var authorizationStatusPublisher: Published<LocationAuthState>.Publisher { $authorizationStatus }
    
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
        DispatchQueue.main.async {
            self.authorizationStatus = status.toDomainModel()
        }
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
