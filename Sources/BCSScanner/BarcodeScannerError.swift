import Foundation

public enum BarcodeScannerError: LocalizedError {
    case cameraUnavailable
    case cameraAccessDenied
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .cameraUnavailable:
            return "Camera is not available"
        case .cameraAccessDenied:
            return "Camera access is required to scan barcodes. Please enable it in Settings."
        case .unknown:
            return "An unknown error occurred."
        }
    }
} 