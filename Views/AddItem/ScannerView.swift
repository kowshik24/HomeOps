import SwiftUI
import VisionKit

struct ScannerView: UIViewControllerRepresentable {
    @Binding var scannedText: String
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        // Configure to look for Text and Barcodes
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text(), .barcode()],
            qualityLevel: .balanced,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        try? scanner.startScanning()
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: ScannerView
        
        init(_ parent: ScannerView) {
            self.parent = parent
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                parent.scannedText = text.transcript
            case .barcode(let code):
                parent.scannedText = code.payloadStringValue ?? ""
            default: break
            }
        }
    }
}
