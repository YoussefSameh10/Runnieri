import Foundation

enum ActivityError: LocalizedError {
    case healthServiceNotAvailable
    case healthServiceNotAuthorized
    case healthDataUnavailable
    case healthServiceError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .healthServiceNotAvailable:
            return "Health service is not available on this device."
        case .healthServiceNotAuthorized:
            return "Health service authorization was denied."
        case .healthDataUnavailable:
            return "Required health data type is not available."
        case .healthServiceError(let error):
            return "Health service error: \(error.localizedDescription)"
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
} 
