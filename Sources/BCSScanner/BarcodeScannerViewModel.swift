import AVFoundation
import SwiftUI

@MainActor
public class BarcodeScannerViewModel: NSObject, ObservableObject {
    @Published public var scannedCode: String?
    @Published public var error: BarcodeScannerError?
    @Published public var isScanning = false
    @Published public var showCameraAlert = false

    private let scanner = BarcodeScanner()
    private var scanningTask: Task<Void, Never>?

    public var session: AVCaptureSession {
        return scanner.session
    }

    public override init() {
        super.init()
    }

    public func startScanning() {
        guard !isScanning else { return }
        isScanning = true
        scanningTask = Task {
            do {
                let code = try await scanner.startScanning()
                self.scannedCode = code
                self.isScanning = false
            } catch {
                self.error = error as? BarcodeScannerError
                self.isScanning = false
            }
        }
    }

    public func stopScanning() {
        scanningTask?.cancel()
        scanningTask = nil
        scanner.stopScanning()
        isScanning = false
    }

    public func resetScan() {
        scannedCode = nil
    }

    public func resetError() {
        error = nil
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension BarcodeScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    nonisolated public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else {
            return
        }
        
        Task { @MainActor in
            self.scannedCode = stringValue
            self.stopScanning()
        }
    }
}

// MARK: - BarcodeScannerError

public enum BarcodeScannerError: LocalizedError {
    case cameraAccessDenied
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .cameraAccessDenied:
            return "Camera access is required to scan barcodes. Please enable it in Settings."
        case .unknown:
            return "An unknown error occurred."
        }
    }
} 
