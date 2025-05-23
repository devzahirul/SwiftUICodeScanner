import XCTest
import BCSScanner
import ViewInspector

final class ExampleAppUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Clean up after each test
    }

    // MARK: - UI Tests
    func testBarcodeScannerPresentation() throws {
        let app = XCUIApplication()
        app.launch()

        // Tap a button that presents the barcode scanner
        let scanButton = app.buttons["Scan Barcode"]
        XCTAssertTrue(scanButton.exists, "Scan button should exist")
        scanButton.tap()

        // Verify that the scanner view is presented
        let scannerView = app.otherElements["BarcodeScannerView"]
        XCTAssertTrue(scannerView.exists, "Barcode scanner view should be presented")

        // Simulate a barcode scan by calling the completion handler
        // Note: In a real UI test, you would simulate camera input or mock the scanner's output
        // For demonstration, we'll assume a mock barcode is returned
        let mockBarcode = "123456789"
        // In a real test, you would trigger the scanner's completion handler with this barcode
        // For example, by mocking the camera input or using a test-specific API

        // Verify that the app responds to the scanned barcode
        // This could be checking a label that displays the scanned code
        let resultLabel = app.staticTexts["Scanned: \(mockBarcode)"]
        XCTAssertTrue(resultLabel.exists, "Result label should display the scanned barcode")
    }

    // MARK: - ViewModel Tests
    func testViewModelInitialState() throws {
        let viewModel = BarcodeScannerViewModel()
        XCTAssertNil(viewModel.scannedCode)
        XCTAssertNil(viewModel.error)
        XCTAssertFalse(viewModel.isScanning)
    }

    func testViewModelResetScan() throws {
        let viewModel = BarcodeScannerViewModel()
        viewModel.scannedCode = "123456789"
        viewModel.resetScan()
        XCTAssertNil(viewModel.scannedCode)
    }

    func testViewModelResetError() throws {
        let viewModel = BarcodeScannerViewModel()
        viewModel.error = .cameraPermissionDenied
        viewModel.resetError()
        XCTAssertNil(viewModel.error)
    }

    // MARK: - Preview Provider Tests
    func testDefaultPreviewProvider() throws {
        let provider = DefaultPreviewProvider()
        let view = provider.makePreviewView()
        XCTAssertNotNil(view)
    }

    func testSwiftUIPreviewProvider() throws {
        let provider = SwiftUIPreviewProvider()
        let view = provider.makePreviewView()
        XCTAssertNotNil(view)
    }

    // MARK: - Coordinator Tests
    func testCoordinatorInitialization() throws {
        let coordinator = BarcodeScannerCoordinator { _ in }
        XCTAssertNotNil(coordinator)
    }

    func testCoordinatorWithCustomPreview() throws {
        let coordinator = BarcodeScannerCoordinator<SwiftUIPreviewProvider> { _ in }
        XCTAssertNotNil(coordinator)
    }

    // MARK: - Error Tests
    func testErrorMessages() throws {
        XCTAssertEqual(BarcodeScannerError.cameraPermissionDenied.localizedDescription, "Camera access is required to scan barcodes")
        XCTAssertEqual(BarcodeScannerError.cameraUnavailable.localizedDescription, "Camera is not available")
        XCTAssertEqual(BarcodeScannerError.invalidInput.localizedDescription, "Invalid camera input")
        XCTAssertEqual(BarcodeScannerError.invalidOutput.localizedDescription, "Invalid camera output")
    }

    // MARK: - Metadata Output Tests
    func testMetadataOutputWithValidCode() throws {
        let viewModel = BarcodeScannerViewModel()
        let mockOutput = MockAVCaptureMetadataOutput()
        let mockObject = MockAVMetadataMachineReadableCodeObject(stringValue: "123456789")
        viewModel.metadataOutput(mockOutput, didOutput: [mockObject], from: AVCaptureConnection())
        XCTAssertEqual(viewModel.scannedCode, "123456789")
    }

    func testMetadataOutputWithInvalidCode() throws {
        let viewModel = BarcodeScannerViewModel()
        let mockOutput = MockAVCaptureMetadataOutput()
        let mockObject = MockAVMetadataMachineReadableCodeObject(stringValue: nil)
        viewModel.metadataOutput(mockOutput, didOutput: [mockObject], from: AVCaptureConnection())
        XCTAssertNil(viewModel.scannedCode)
    }

    func testMetadataOutputWithEmptyArray() throws {
        let viewModel = BarcodeScannerViewModel()
        let mockOutput = MockAVCaptureMetadataOutput()
        viewModel.metadataOutput(mockOutput, didOutput: [], from: AVCaptureConnection())
        XCTAssertNil(viewModel.scannedCode)
    }

    func testMetadataOutputStopsScanning() throws {
        let viewModel = BarcodeScannerViewModel()
        let mockOutput = MockAVCaptureMetadataOutput()
        let mockObject = MockAVMetadataMachineReadableCodeObject(stringValue: "123456789")
        viewModel.metadataOutput(mockOutput, didOutput: [mockObject], from: AVCaptureConnection())
        XCTAssertFalse(viewModel.isScanning)
    }
}

// MARK: - Mock Classes
private class MockAVCaptureMetadataOutput: AVCaptureMetadataOutput {
    override var metadataObjectTypes: [AVMetadataObject.ObjectType] {
        return [.qr, .ean8, .ean13, .pdf417, .code128, .code39, .code93, .upce]
    }
}

private class MockAVMetadataMachineReadableCodeObject: AVMetadataMachineReadableCodeObject {
    private let _stringValue: String?

    init(stringValue: String?) {
        self._stringValue = stringValue
        super.init()
    }

    override var stringValue: String? {
        return _stringValue
    }
}

// MARK: - Preview Providers
private struct DefaultPreviewProvider: BarcodeScannerPreviewProvider {
    func makePreviewView() -> some View {
        CameraPreviewView()
    }
}

private struct SwiftUIPreviewProvider: BarcodeScannerPreviewProvider {
    func makePreviewView() -> some View {
        Text("Custom Preview")
    }
} 