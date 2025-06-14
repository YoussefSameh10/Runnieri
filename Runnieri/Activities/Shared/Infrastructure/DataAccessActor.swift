import Foundation

/// A global actor that ensures all data access operations are performed in a thread-safe manner.
/// This helps prevent race conditions and provides a consistent threading model for data operations.
@globalActor
actor DataAccessActor {
    static let shared = DataAccessActor()
    
    private init() {}
} 
