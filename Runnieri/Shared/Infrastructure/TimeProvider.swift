import Foundation

protocol TimeProvider {
    var currentTime: TimeInterval { get }
    func advance(by interval: TimeInterval)
}

final class RealTimeProvider: TimeProvider {
    var currentTime: TimeInterval {
        Date().timeIntervalSince1970
    }
    
    func advance(by interval: TimeInterval) {
        // No-op in real implementation
    }
}
