import Foundation

protocol LocationService: AnyObject {
    var authStatus: LocationAuthState { get }
    var distance: Int { get }
    var authStatusPublisher: AsyncStream<LocationAuthState> { get }
    var distancePublisher: AsyncStream<Int> { get }
    
    func requestAuthorization()
    func startUpdating()
    func stopUpdating()
    func reset()
} 
