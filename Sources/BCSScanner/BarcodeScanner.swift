import AVFoundation
import UIKit

@MainActor
public class BarcodeScanner: NSObject {
    public let session = AVCaptureSession()
    private var metadataOutput: AVCaptureMetadataOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var scanningActor: ScanningActor?

    public override init() {
        super.init()
        setupCaptureSession()
    }

    private func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }

            let metadataOutput = AVCaptureMetadataOutput()
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
                metadataOutput.metadataObjectTypes = [
                    .qr,
                    .ean8,
                    .ean13,
                    .pdf417,
                    .code128,
                    .code39,
                    .code93,
                    .upce
                ]
                self.metadataOutput = metadataOutput
            }
        } catch {
            print("Error setting up capture session: \(error.localizedDescription)")
        }
    }

    public func startScanning() async throws -> String {
         DispatchQueue.global(qos: .userInitiated).async { [weak self] in
        self?.session.startRunning()
    }

        // Create a new scanning actor for this scan
        let scanningActor = ScanningActor()
        self.scanningActor = scanningActor

        // Wait for a barcode to be scanned
        return try await scanningActor.waitForBarcode()
    }

    public func stopScanning() {
        // Run session.stopRunning() on a background dispatch queue
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
        self?.session.stopRunning()
    }
               
               Task { @MainActor in
                   previewLayer?.removeFromSuperlayer()
                   previewLayer = nil
                   scanningActor = nil
               }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension BarcodeScanner: AVCaptureMetadataOutputObjectsDelegate {
    nonisolated public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else {
            return
        }

        Task { @MainActor in
            await scanningActor?.barcodeScanned(stringValue)
        }
    }
}

// MARK: - ScanningActor

private actor ScanningActor {
    private var continuation: CheckedContinuation<String, Error>?

    func waitForBarcode() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    func barcodeScanned(_ code: String) {
        continuation?.resume(returning: code)
        continuation = nil
    }
} 
