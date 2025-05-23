import SwiftUI
import AVFoundation

public protocol BarcodeScannerPreviewProvider {
    associatedtype PreviewView: View
    @MainActor func makePreviewView(session: AVCaptureSession) -> PreviewView
}

public struct DefaultBarcodeScannerPreview: BarcodeScannerPreviewProvider {
    public init() {}
    
    @MainActor
    public func makePreviewView(session: AVCaptureSession) -> some View {
        CameraPreviewView(session: session)
    }
}

// SwiftUI View Builder Preview Provider
public struct SwiftUIPreviewProvider<Content: View>: BarcodeScannerPreviewProvider {
    private let content: (AVCaptureSession) -> Content
    
    public init(@ViewBuilder content: @escaping (AVCaptureSession) -> Content) {
        self.content = content
    }
    
    public func makePreviewView(session: AVCaptureSession) -> some View {
        content(session)
    }
}

// Default camera preview implementation
public struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    public init(session: AVCaptureSession) {
        self.session = session
    }
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {}
} 