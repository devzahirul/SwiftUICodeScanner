import UIKit

public protocol BarcodeScannerViewControllerDelegate: AnyObject {
    func barcodeScanner(_ scanner: BarcodeScannerViewController, didScanCode code: String)
    func barcodeScanner(_ scanner: BarcodeScannerViewController, didFailWithError error: Error)
}

@MainActor
public class BarcodeScannerViewController: UIViewController {
    public weak var delegate: BarcodeScannerViewControllerDelegate?
    private let scanner = BarcodeScanner()
    private let previewView = UIView()
    private let resultLabel = UILabel()
    private var scanningTask: Task<Void, Never>?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startScanning()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Setup preview view
        previewView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewView)
        
        // Setup result label
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.textColor = .white
        resultLabel.textAlignment = .center
        resultLabel.numberOfLines = 0
        resultLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        resultLabel.layer.cornerRadius = 8
        resultLabel.clipsToBounds = true
        view.addSubview(resultLabel)
        
        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resultLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func startScanning() {
        scanningTask = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let code = try await scanner.startScanning()
                await MainActor.run {
                    self.resultLabel.text = "Scanned: \(code)"
                    self.delegate?.barcodeScanner(self, didScanCode: code)
                }
            } catch {
                await MainActor.run {
                    self.resultLabel.text = "Error: \(error.localizedDescription)"
                    self.delegate?.barcodeScanner(self, didFailWithError: error)
                }
            }
        }
    }
    
    private func stopScanning() {
        scanningTask?.cancel()
        scanningTask = nil
        scanner.stopScanning()
    }
} 
