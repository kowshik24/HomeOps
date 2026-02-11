import Foundation
import Combine

class ScannerViewModel: ObservableObject {
    /// A publisher that announces when the scanned text changes.
    @Published var scannedText: String = ""
    
    /// Extract product name from scanned text
    var productName: String? {
        scannedText.split(separator: "\n")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { line in
                !line.isEmpty &&
                !line.lowercased().contains("total") &&
                !line.lowercased().contains("subtotal") &&
                !line.lowercased().contains("tax") &&
                !line.lowercased().contains("cash") &&
                !line.lowercased().contains("credit") &&
                !line.lowercased().contains("receipt") &&
                !line.lowercased().contains("store") &&
                !line.contains { "$€£¥".contains($0) } &&
                line.range(of: "\\d{1,2}/\\d{1,2}/\\d{2,4}", options: .regularExpression) == nil &&
                line.count > 2 &&
                line.count < 100
            }
    }
    
    /// Extract purchase date from scanned text (multiple formats)
    var purchaseDate: Date? {
        let datePatterns = [
            "\\d{1,2}/\\d{1,2}/\\d{2,4}",  // MM/DD/YYYY or M/D/YY
            "\\d{1,2}-\\d{1,2}-\\d{2,4}",  // MM-DD-YYYY
            "\\d{4}/\\d{1,2}/\\d{1,2}",    // YYYY/MM/DD
            "\\d{4}-\\d{1,2}-\\d{1,2}"     // YYYY-MM-DD
        ]
        
        for pattern in datePatterns {
            if let dateString = scannedText.matches(for: pattern).first {
                if let date = parseDate(dateString) {
                    return date
                }
            }
        }
        
        return nil
    }
    
    /// Extract purchase price from scanned text
    var purchasePrice: Double? {
        // Look for patterns like $XX.XX, $XXX.XX, or TOTAL: $XX.XX
        let pricePatterns = [
            "(?:total|amount|price)[:\\s]*\\$?([0-9]+\\.[0-9]{2})",  // TOTAL: $XX.XX
            "\\$([0-9]+\\.[0-9]{2})",  // $XX.XX
            "([0-9]+\\.[0-9]{2})\\s*(?:USD|usd|dollars?)"  // XX.XX USD
        ]
        
        for pattern in pricePatterns {
            let matches = scannedText.matches(for: pattern)
            for match in matches {
                // Extract just the numeric part
                let numericString = match.components(separatedBy: CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ".")).inverted).joined()
                if let price = Double(numericString), price > 0 && price < 100000 {
                    return price
                }
            }
        }
        
        return nil
    }
    
    /// Extract store name from scanned text
    var storeName: String? {
        let lines = scannedText.split(separator: "\n").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // Common store indicators
        let storeKeywords = ["store", "shop", "market", "retail", "inc", "llc", "ltd", "co"]
        
        // Usually the store name is in the first few lines
        for line in lines.prefix(5) {
            let lowercased = line.lowercased()
            
            // Check if line contains store indicators
            if storeKeywords.contains(where: { lowercased.contains($0) }) {
                return line
            }
            
            // Check if line is all caps (common for store names)
            if line == line.uppercased() && line.count > 3 && line.count < 50 {
                return line
            }
        }
        
        // Fallback: return first non-empty line
        return lines.first(where: { !$0.isEmpty && $0.count > 2 && $0.count < 50 })
    }
    
    // MARK: - Helper Methods
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatters: [DateFormatter] = {
            let formats = ["MM/dd/yyyy", "MM/dd/yy", "M/d/yyyy", "M/d/yy", 
                          "yyyy/MM/dd", "yyyy-MM-dd", "MM-dd-yyyy", "M-d-yyyy"]
            return formats.map { format in
                let formatter = DateFormatter()
                formatter.dateFormat = format
                formatter.locale = Locale(identifier: "en_US_POSIX")
                return formatter
            }
        }()
        
        for formatter in formatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }
}

// Helper extension to find regex matches
extension String {
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [.caseInsensitive])
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
