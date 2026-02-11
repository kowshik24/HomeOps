import Foundation
import Combine

class ScannerViewModel: ObservableObject {
    /// A publisher that announces when the scanned text changes.
    @Published var scannedText: String = ""
    
    /// A simple mechanism to find a potential product name from scanned text.
    /// This is a basic implementation and can be improved with more advanced regex or NLP.
    var productName: String? {
        // A simple heuristic: find the first line that looks like a product (not a date, price, or generic term).
        scannedText.split(separator: "\n")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { line in
                // Filter out lines that are likely not product names
                !line.isEmpty &&
                !line.lowercased().contains("total") &&
                !line.lowercased().contains("subtotal") &&
                !line.lowercased().contains("tax") &&
                !line.lowercased().contains("cash") &&
                !line.lowercased().contains("credit") &&
                !line.contains { "$€£".contains($0) } && // Not a price
                line.range(of: "\\d{1,2}/\\d{1,2}/\\d{2,4}", options: .regularExpression) == nil && // Not a date
                line.count > 2 // Not a short abbreviation
            }
    }
    
    /// A simple mechanism to find a date from scanned text.
    var purchaseDate: Date? {
        // Look for a string matching M/D/YY, MM/DD/YY, M/D/YYYY, or MM/DD/YYYY
        guard let dateString = scannedText.matches(for: "\\d{1,2}/\\d{1,2}/\\d{2,4}").first else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy" // Adjust based on common receipt formats
        
        // Attempt to parse with different formats if needed
        if let date = formatter.date(from: dateString) {
            return date
        } else {
            formatter.dateFormat = "MM/dd/yyyy"
            return formatter.date(from: dateString)
        }
    }
}

// Helper extension to find regex matches
extension String {
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch {
            print("Invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
