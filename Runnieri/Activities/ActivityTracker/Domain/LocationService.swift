import Foundation

protocol LocationService: AnyObject {
    var distance: Int { get }
    var authorizationStatus: LocationAuthState { get }
    var distancePublisher: Published<Int>.Publisher { get }
    var authorizationStatusPublisher: Published<LocationAuthState>.Publisher { get }
    func requestAuthorization()
    func startUpdating()
    func stopUpdating()
    func reset()
} 
