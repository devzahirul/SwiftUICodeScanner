# BarcodeScanner

A modern, customizable, and SwiftUI-friendly barcode scanner library for iOS, built with AVFoundation and async/await. Easily integrate barcode scanning into your SwiftUI apps with minimal setup and maximum flexibility.

---

## Features

- 📷 **Live Camera Preview**: Always-on camera preview using AVFoundation.
- 🏷️ **Barcode Formats**: Supports QR, EAN-8, EAN-13, PDF417, Code128, Code39, Code93, UPC-E, and more.
- 🧑‍💻 **SwiftUI Support**: Designed for SwiftUI-first development.
- 🔄 **Async/Await API**: Modern async/await for scanning and permissions.
- 🛠️ **Customizable Preview**: Easily swap in your own camera preview UI.
- 🔁 **Scan Again**: Tap to scan barcodes repeatedly.
- 🛡️ **Safe Actor-based State**: Uses Swift actors for safe concurrency.
- 🚦 **Camera Permission Handling**: Built-in permission checks and error handling.

---

## Getting Started

### 1. Add BCSScanner to Your Project

#### Swift Package Manager (Recommended)

1. In Xcode, go to **File > Add Packages...**
2. Enter the repo URL:
   ```
   https://github.com/yourusername/BCSScanner.git
   ```
3. Select the latest version and add the `BCSScanner` package to your app target.

#### Info.plist
Add the following key to your `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan barcodes.</string>
```

---

## Step-by-Step SwiftUI Example

### 1. Import and Setup

```swift
import SwiftUI
import BCSScanner
```

### 2. Create Your ContentView

```swift
struct ContentView: View {
    @State private var scannedCode: String?
    @State private var showScanner = false
    @StateObject private var viewModel = BarcodeScannerViewModel()

    var body: some View {
        VStack(spacing: 24) {
            if let code = scannedCode {
                Text("Scanned Code: \(code)")
                    .font(.title2)
                    .padding()
            } else {
                Text("No code scanned yet")
                    .foregroundColor(.secondary)
            }
            Button("Scan Barcode") {
                showScanner = true
            }
            .buttonStyle(.borderedProminent)
        }
        .sheet(isPresented: $showScanner) {
            BarcodeScannerView(viewModel: viewModel) { code in
                scannedCode = code
                showScanner = false
            }
        }
    }
}
```

### 3. Run Your App
- Tap **Scan Barcode** to open the scanner.
- Tap the camera preview to start scanning.
- Scan a barcode. The result will appear in your view.
- Tap the preview again to scan another barcode.

---

## Customization

- **Custom Camera Preview**: You can provide your own preview provider by conforming to `BarcodeScannerPreviewProvider`.
- **Scan on Tap**: The camera preview is always visible; scanning starts when you tap the preview.
- **Scan Again**: Tap the preview again to scan another barcode.

---

## API Reference: Main Classes

### `BarcodeScanner`
- Core class that manages the AVFoundation session and barcode detection.
- **Key Methods:**
  - `startScanning() async throws -> String`: Starts scanning and returns the scanned code.
  - `stopScanning()`: Stops the camera session.
- **Usage:** Used internally by the view model, but can be used directly for advanced use cases.

### `BarcodeScannerViewModel`
- ObservableObject for managing scanning state in SwiftUI.
- **Properties:**
  - `@Published var scannedCode: String?`: The last scanned code.
  - `@Published var error: BarcodeScannerError?`: Any error encountered.
  - `@Published var isScanning: Bool`: Whether scanning is in progress.
  - `var session: AVCaptureSession`: The camera session for preview.
- **Methods:**
  - `startScanning()`: Begins scanning for a barcode.
  - `stopScanning()`: Stops scanning.
  - `resetScan()`: Clears the last scanned code.
  - `resetError()`: Clears the last error.

### `BarcodeScannerView`
- SwiftUI view that displays the camera preview and handles user interaction.
- **Usage:**
  - Pass a `BarcodeScannerViewModel` and a preview provider.
  - Handles tap-to-scan and displays errors.

### `BarcodeScannerError`
- Enum for error handling (e.g., camera permission denied, unknown error).
- **Usage:** Used by the view model and view to display user-friendly error messages.
---

## Advanced: Custom Camera Preview

You can create your own camera preview by conforming to `BarcodeScannerPreviewProvider`:

```swift
struct MyCustomPreview: BarcodeScannerPreviewProvider {
    func makePreviewView(session: AVCaptureSession) -> some View {
        // Your custom SwiftUI view here
        CameraPreviewSwiftUIV2(session: session)
            .overlay(Text("Custom Overlay").foregroundColor(.white))
    }
}
```

Then use it in your scanner view:
```swift
BarcodeScannerView(viewModel: viewModel) { code in
    // handle code
}
```

---

## Error Handling

- Handles camera permission errors and unknown errors gracefully.
- Presents user-friendly error messages in the UI.

---

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

---

## License

MIT License. See [LICENSE](LICENSE) for details. 
