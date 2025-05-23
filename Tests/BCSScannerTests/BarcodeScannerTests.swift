import XCTest
import AVFoundation
import SwiftUI
@testable import BCSScanner

final class BarcodeScannerTests: XCTestCase {
    var viewModel: BarcodeScannerViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = BarcodeScannerViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - ViewModel Tests
    
    func testInitialState() {
        XCTAssertNil(viewModel.scannedCode)
        XCTAssertNil(viewModel.error)
        XCTAssertFalse(viewModel.showCameraAlert)
    }
    
    func testResetScan() {
        // Given
        viewModel.scannedCode = "test123"
        
        // When
        viewModel.resetScan()
        
        // Then
        XCTAssertNil(viewModel.scannedCode)
    }
    
    func testResetError() {
        // Given
        viewModel.error = BarcodeScannerError.unknown
        
        // When
        viewModel.resetError()
        
        // Then
        XCTAssertNil(viewModel.error)
    }
    
    // MARK: - Preview Provider Tests
    
    func testDefaultPreviewProvider() {
        // Given
        let provider = DefaultBarcodeScannerPreview()
        
        // When
        let view = provider.makePreviewView(session: AVCaptureSession())
        
        // Then
        XCTAssertNotNil(view)
    }
    
    func testSwiftUIPreviewProvider() {
        // Given
        let provider = SwiftUIPreviewProvider { session in
            Text("Test Preview")
        }
        
        // When
        let view = provider.makePreviewView(session: AVCaptureSession())
        
        // Then
        XCTAssertNotNil(view)
    }
    
    // MARK: - Coordinator Tests
    
    func testCoordinatorInitialization() {
        // Given
        let expectation = expectation(description: "Completion called")
        
        // When
        let coordinator = BarcodeScannerCoordinator { result in
            expectation.fulfill()
        }
        
        // Then
        XCTAssertNotNil(coordinator)
        waitForExpectations(timeout: 1)
    }
    
    func testCoordinatorWithCustomPreview() {
        // Given
        let expectation = expectation(description: "Completion called")
        let customProvider = SwiftUIPreviewProvider { session in
            Text("Custom Preview")
        }
        
        // When
        let coordinator = BarcodeScannerCoordinator(
            previewProvider: customProvider
        ) { result in
            expectation.fulfill()
        }
        
        // Then
        XCTAssertNotNil(coordinator)
        waitForExpectations(timeout: 1)
    }
    
    // MARK: - Error Tests
    
    func testBarcodeScannerErrorMessages() {
        // Given
        let cameraAccessDenied = BarcodeScannerError.cameraAccessDenied
        let unknown = BarcodeScannerError.unknown
        
        // Then
        XCTAssertNotNil(cameraAccessDenied.errorDescription)
        XCTAssertNotNil(unknown.errorDescription)
        XCTAssertFalse(cameraAccessDenied.errorDescription?.isEmpty ?? true)
        XCTAssertFalse(unknown.errorDescription?.isEmpty ?? true)
    }
}

// MARK: - Mock Objects

private class MockAVCaptureSession: AVCaptureSession {
    var isRunning: Bool = false
    
    override func startRunning() {
        isRunning = true
    }
    
    override func stopRunning() {
        isRunning = false
    }
}

private class MockAVCaptureDeviceInput: AVCaptureDeviceInput {
    override var device: AVCaptureDevice {
        MockAVCaptureDevice()
    }
}

private class MockAVCaptureDevice: AVCaptureDevice {
    override var hasTorch: Bool { true }
    override var isTorchAvailable: Bool { true }
    override var torchMode: AVCaptureDevice.TorchMode {
        get { .off }
        set { }
    }
}

// MARK: - Test Helpers

extension BarcodeScannerTests {
    func createMockSession() -> AVCaptureSession {
        let session = MockAVCaptureSession()
        return session
    }
    
    func createMockDeviceInput() throws -> AVCaptureDeviceInput {
        return MockAVCaptureDeviceInput(device: MockAVCaptureDevice())
    }
} 