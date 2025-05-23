import SwiftUI
import AVFoundation

@MainActor
public struct BarcodeScannerCoordinator {
    private let viewModel: BarcodeScannerViewModel
    private let previewProvider: BarcodeScannerPreviewProvider
    private let completion: (String) -> Void

    public init(viewModel: BarcodeScannerViewModel, previewProvider: BarcodeScannerPreviewProvider, completion: @escaping (String) -> Void) {
        self.viewModel = viewModel
        self.previewProvider = previewProvider
        self.completion = completion
    }

    public func makeScannerView() -> some View {
        BarcodeScannerView(viewModel: viewModel, previewProvider: previewProvider, completion: completion)
    }
}

// MARK: - Scanner Environment

public final class ScannerEnvironment: ObservableObject {
    let completion: (String) -> Void
    
    init(completion: @escaping (String) -> Void) {
        self.completion = completion
    }
}

// MARK: - View Extension

public extension View {
    func barcodeScanner(
        isPresented: Binding<Bool>,
        previewProvider: BarcodeScannerPreviewProvider = DefaultBarcodeScannerPreview(),
        completion: @escaping (String) -> Void
    ) -> some View {
        let viewModel = BarcodeScannerViewModel()
        let coordinator = BarcodeScannerCoordinator(viewModel: viewModel, previewProvider: previewProvider, completion: completion)
        return sheet(isPresented: isPresented) {
            coordinator.makeScannerView()
        }
    }
    
    // Convenience method for SwiftUI views
    func barcodeScanner<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder previewContent: @escaping (AVCaptureSession) -> Content,
        completion: @escaping (String) -> Void
    ) -> some View {
        let provider = SwiftUIPreviewProvider(content: previewContent)
        return barcodeScanner(isPresented: isPresented, previewProvider: provider, completion: completion)
    }
} 
