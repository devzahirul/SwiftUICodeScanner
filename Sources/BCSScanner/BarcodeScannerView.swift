import SwiftUI
import AVFoundation

@MainActor
public struct BarcodeScannerView: View {
    @ObservedObject private var viewModel: BarcodeScannerViewModel
    
    private let completion: (String) -> Void

    public init(viewModel: BarcodeScannerViewModel, completion: @escaping (String) -> Void) {
        self.viewModel = viewModel
        self.completion = completion
    }

    public var body: some View {
        ZStack {
            CameraPreviewSwiftUIV2(session: viewModel.session)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    viewModel.resetScan()
                    viewModel.startScanning()
                }

            if viewModel.isScanning {
                Rectangle()
                    .fill(Color.black.opacity(0.5))
                    .edgesIgnoringSafeArea(.all)
            }

            if let error = viewModel.error {
                VStack {
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                        .padding()
                    Button("Dismiss") {
                        viewModel.resetError()
                    }
                }
            }
        }
        .onAppear {
            viewModel.startScanning()
        }
        .onDisappear {
            viewModel.stopScanning()
        }
        .onChange(of: viewModel.scannedCode) { newValue in
            if let code = newValue {
                completion(code)
            }
        }
    }
}

// MARK: - CameraPreviewUIView

public class CameraPreviewUIView: UIView {
    private let session: AVCaptureSession

    public init(session: AVCaptureSession) {
        self.session = session
        super.init(frame: .zero)
        setupPreviewLayer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPreviewLayer() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = bounds
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if let previewLayer = layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = bounds
        }
    }
}


struct CameraPreviewSwiftUIV2: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> some UIView {
        return CameraPreviewUIView(session: session)
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}


// MARK: - Supporting Views

private struct ResultView: View {
    let code: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Scanned Code")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(code)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
            
            Button("Scan Again") {
                onDismiss()
            }
            .buttonStyle(.bordered)
            .tint(.white)
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(16)
    }
}

private struct ErrorView: View {
    let error: Error
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.red)
            
            Text("Error")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                onRetry()
            }
            .buttonStyle(.bordered)
            .tint(.white)
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(16)
    }
} 
