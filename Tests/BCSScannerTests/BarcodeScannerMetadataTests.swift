import XCTest
import AVFoundation
@testable import BCSScanner

final class BarcodeScannerMetadataTests: XCTestCase {
    var viewModel: BarcodeScannerViewModel!
    var mockMetadataOutput: MockAVCaptureMetadataOutput!
    
    override func setUp() {
        super.setUp()
        viewModel = BarcodeScannerViewModel()
        mockMetadataOutput = MockAVCaptureMetadataOutput()
    }
    
    override func tearDown() {
        viewModel = nil
        mockMetadataOutput = nil
        super.tearDown()
    }
    
    // MARK: - Metadata Output Tests
    
    func testMetadataOutputWithValidCode() {
        // Given
        let expectedCode = "test123"
        let metadataObject = MockAVMetadataMachineReadableCodeObject(stringValue: expectedCode)
        
        // When
        viewModel.metadataOutput(
            mockMetadataOutput,
            didOutput: [metadataObject],
            from: AVCaptureConnection()
        )
        
        // Then
        XCTAssertEqual(viewModel.scannedCode, expectedCode)
    }
    
    func testMetadataOutputWithInvalidCode() {
        // Given
        let metadataObject = MockAVMetadataMachineReadableCodeObject(stringValue: nil)
        
        // When
        viewModel.metadataOutput(
            mockMetadataOutput,
            didOutput: [metadataObject],
            from: AVCaptureConnection()
        )
        
        // Then
        XCTAssertNil(viewModel.scannedCode)
    }
    
    func testMetadataOutputWithEmptyArray() {
        // When
        viewModel.metadataOutput(
            mockMetadataOutput,
            didOutput: [],
            from: AVCaptureConnection()
        )
        
        // Then
        XCTAssertNil(viewModel.scannedCode)
    }
    
    func testMetadataOutputStopsScanning() {
        // Given
        let mockSession = MockAVCaptureSession()
        viewModel.session = mockSession
        mockSession.isRunning = true
        
        let metadataObject = MockAVMetadataMachineReadableCodeObject(stringValue: "test123")
        
        // When
        viewModel.metadataOutput(
            mockMetadataOutput,
            didOutput: [metadataObject],
            from: AVCaptureConnection()
        )
        
        // Then
        XCTAssertFalse(mockSession.isRunning)
    }
}

// MARK: - Mock Objects

private class MockAVCaptureMetadataOutput: AVCaptureMetadataOutput {
    override var metadataObjectTypes: [AVMetadataObject.ObjectType] {
        get { return [.qr, .ean8, .ean13] }
        set { }
    }
}

private class MockAVMetadataMachineReadableCodeObject: AVMetadataMachineReadableCodeObject {
    private let mockStringValue: String?
    
    init(stringValue: String?) {
        self.mockStringValue = stringValue
        super.init()
    }
    
    override var stringValue: String? {
        return mockStringValue
    }
} 