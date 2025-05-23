import XCTest
import SwiftUI
import ViewInspector
@testable import BCSScanner

extension BarcodeScannerView: Inspectable {}
extension ResultView: Inspectable {}
extension ErrorView: Inspectable {}

final class BarcodeScannerViewTests: XCTestCase {
    
    // MARK: - View Tests
    
    func testBarcodeScannerViewInitialization() throws {
        // Given
        let view = BarcodeScannerView()
        
        // Then
        XCTAssertNotNil(view)
    }
    
    func testResultViewContent() throws {
        // Given
        let code = "test123"
        let view = ResultView(code: code) {}
        
        // When
        let text = try view.inspect().find(text: code).string()
        
        // Then
        XCTAssertEqual(text, code)
    }
    
    func testErrorViewContent() throws {
        // Given
        let error = BarcodeScannerError.cameraAccessDenied
        let view = ErrorView(error: error) {}
        
        // When
        let errorText = try view.inspect().find(text: error.localizedDescription).string()
        
        // Then
        XCTAssertEqual(errorText, error.localizedDescription)
    }
    
    // MARK: - View Modifier Tests
    
    func testBarcodeScannerViewModifier() throws {
        // Given
        let expectation = expectation(description: "Completion called")
        let isPresented = Binding.constant(true)
        
        // When
        let view = EmptyView()
            .barcodeScanner(isPresented: isPresented) { _ in
                expectation.fulfill()
            }
        
        // Then
        XCTAssertNotNil(view)
        waitForExpectations(timeout: 1)
    }
    
    func testBarcodeScannerViewModifierWithCustomPreview() throws {
        // Given
        let expectation = expectation(description: "Completion called")
        let isPresented = Binding.constant(true)
        
        // When
        let view = EmptyView()
            .barcodeScanner(
                isPresented: isPresented,
                previewContent: { _ in
                    Text("Custom Preview")
                }
            ) { _ in
                expectation.fulfill()
            }
        
        // Then
        XCTAssertNotNil(view)
        waitForExpectations(timeout: 1)
    }
    
    // MARK: - Preview Provider Tests
    
    func testDefaultPreviewProviderView() throws {
        // Given
        let provider = DefaultBarcodeScannerPreview()
        let session = AVCaptureSession()
        
        // When
        let view = provider.makePreviewView(session: session)
        
        // Then
        XCTAssertNotNil(view)
    }
    
    func testSwiftUIPreviewProviderView() throws {
        // Given
        let provider = SwiftUIPreviewProvider { session in
            Text("Test Preview")
        }
        let session = AVCaptureSession()
        
        // When
        let view = provider.makePreviewView(session: session)
        
        // Then
        XCTAssertNotNil(view)
    }
}

// MARK: - Test Helpers

extension BarcodeScannerViewTests {
    func createTestSession() -> AVCaptureSession {
        return AVCaptureSession()
    }
} 