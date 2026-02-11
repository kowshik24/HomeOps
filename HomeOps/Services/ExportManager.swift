//
//  ExportManager.swift
//  HomeOps
//
//  Export functionality for PDF and CSV
//

import SwiftUI
import PDFKit
import Combine

class ExportManager {
    static let shared = ExportManager()
    
    // MARK: - PDF Export
    
    func generateItemPDF(for item: Item) -> Data? {
        let pageSize = CGRect(x: 0, y: 0, width: 612, height: 792) // Letter size
        let renderer = UIGraphicsPDFRenderer(bounds: pageSize)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = 50
            
            // Title
            drawText("Warranty Information", at: CGPoint(x: 50, y: yPosition), fontSize: 24, bold: true)
            yPosition += 40
            
            // Item Details
            drawText("Product Details", at: CGPoint(x: 50, y: yPosition), fontSize: 18, bold: true)
            yPosition += 30
            
            drawText("Name: \(item.name)", at: CGPoint(x: 50, y: yPosition), fontSize: 14)
            yPosition += 25
            
            drawText("Category: \(item.category)", at: CGPoint(x: 50, y: yPosition), fontSize: 14)
            yPosition += 25
            
            if let _ = item.purchasePrice {
                drawText("Purchase Price: \(item.formattedPrice)", at: CGPoint(x: 50, y: yPosition), fontSize: 14)
                yPosition += 25
            }
            
            if let store = item.storeName {
                drawText("Store: \(store)", at: CGPoint(x: 50, y: yPosition), fontSize: 14)
                yPosition += 25
            }
            
            if let location = item.location {
                drawText("Location: \(location)", at: CGPoint(x: 50, y: yPosition), fontSize: 14)
                yPosition += 25
            }
            
            yPosition += 10
            drawText("Purchase Date: \(item.purchaseDate.formatted(date: .long, time: .omitted))", at: CGPoint(x: 50, y: yPosition), fontSize: 14)
            yPosition += 25
            
            drawText("Warranty Duration: \(item.warrantyDurationMonths) months", at: CGPoint(x: 50, y: yPosition), fontSize: 14)
            yPosition += 25
            
            drawText("Warranty Expires: \(item.warrantyExpirationDate.formatted(date: .long, time: .omitted))", at: CGPoint(x: 50, y: yPosition), fontSize: 14)
            yPosition += 25
            
            drawText("Days Remaining: \(item.daysRemaining) days", at: CGPoint(x: 50, y: yPosition), fontSize: 14)
            yPosition += 35
            
            // Tags
            if !item.displayTags.isEmpty {
                drawText("Tags: \(item.displayTags.joined(separator: ", "))", at: CGPoint(x: 50, y: yPosition), fontSize: 14)
                yPosition += 35
            }
            
            // Notes
            if let notes = item.notes, !notes.isEmpty {
                drawText("Notes:", at: CGPoint(x: 50, y: yPosition), fontSize: 18, bold: true)
                yPosition += 25
                drawText(notes, at: CGPoint(x: 50, y: yPosition), fontSize: 12, maxWidth: 500)
                yPosition += 50
            }
            
            // Receipt Image
            if let imageData = item.receiptImageData, let image = UIImage(data: imageData) {
                yPosition += 20
                drawText("Receipt Image:", at: CGPoint(x: 50, y: yPosition), fontSize: 18, bold: true)
                yPosition += 30
                
                let imageRect = CGRect(x: 50, y: yPosition, width: 300, height: 200)
                image.draw(in: imageRect)
            }
        }
        
        return data
    }
    
    func generateInventoryPDF(for items: [Item]) -> Data? {
        let pageSize = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageSize)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = 50
            
            // Title
            drawText("Home Inventory Report", at: CGPoint(x: 50, y: yPosition), fontSize: 24, bold: true)
            yPosition += 30
            
            drawText("Generated: \(Date().formatted(date: .long, time: .shortened))", at: CGPoint(x: 50, y: yPosition), fontSize: 12)
            yPosition += 30
            
            // Summary
            drawText("Summary", at: CGPoint(x: 50, y: yPosition), fontSize: 18, bold: true)
            yPosition += 25
            
            drawText("Total Items: \(items.count)", at: CGPoint(x: 50, y: yPosition), fontSize: 14)
            yPosition += 20
            
            let totalValue = items.compactMap { $0.purchasePrice }.reduce(0, +)
            if totalValue > 0 {
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                let valueString = formatter.string(from: NSNumber(value: totalValue)) ?? "$0"
                drawText("Total Value: \(valueString)", at: CGPoint(x: 50, y: yPosition), fontSize: 14)
                yPosition += 20
            }
            
            let active = items.filter { $0.daysRemaining > 0 }.count
            drawText("Active Warranties: \(active)", at: CGPoint(x: 50, y: yPosition), fontSize: 14)
            yPosition += 40
            
            // Items List
            drawText("Items", at: CGPoint(x: 50, y: yPosition), fontSize: 18, bold: true)
            yPosition += 30
            
            for (index, item) in items.enumerated() {
                if yPosition > 700 {
                    context.beginPage()
                    yPosition = 50
                }
                
                drawText("\(index + 1). \(item.name)", at: CGPoint(x: 50, y: yPosition), fontSize: 14, bold: true)
                yPosition += 20
                
                drawText("   Category: \(item.category) | Expires: \(item.warrantyExpirationDate.formatted(date: .abbreviated, time: .omitted))", at: CGPoint(x: 50, y: yPosition), fontSize: 11)
                yPosition += 25
            }
        }
        
        return data
    }
    
    private func drawText(_ text: String, at point: CGPoint, fontSize: CGFloat, bold: Bool = false, maxWidth: CGFloat? = nil) {
        let font = bold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        
        if let maxWidth = maxWidth {
            let rect = CGRect(x: point.x, y: point.y, width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
            text.draw(in: rect, withAttributes: attributes)
        } else {
            text.draw(at: point, withAttributes: attributes)
        }
    }
    
    // MARK: - CSV Export
    
    func generateCSV(for items: [Item]) -> String {
        var csv = "Name,Category,Purchase Date,Purchase Price,Store,Location,Warranty (Months),Expiration Date,Days Remaining,Tags,Notes\n"
        
        for item in items {
            let name = escapeCSV(item.name)
            let category = escapeCSV(item.category)
            let purchaseDate = item.purchaseDate.formatted(date: .numeric, time: .omitted)
            let price = item.purchasePrice != nil ? String(describing: item.purchasePrice!) : ""
            let store = escapeCSV(item.storeName ?? "")
            let location = escapeCSV(item.location ?? "")
            let warranty = "\(item.warrantyDurationMonths)"
            let expiration = item.warrantyExpirationDate.formatted(date: .numeric, time: .omitted)
            let daysRemaining = "\(item.daysRemaining)"
            let tags = escapeCSV(item.displayTags.joined(separator: "; "))
            let notes = escapeCSV(item.notes ?? "")
            
            csv += "\(name),\(category),\(purchaseDate),\(price),\(store),\(location),\(warranty),\(expiration),\(daysRemaining),\(tags),\(notes)\n"
        }
        
        return csv
    }
    
    private func escapeCSV(_ text: String) -> String {
        let needsQuotes = text.contains(",") || text.contains("\"") || text.contains("\n")
        if needsQuotes {
            let escaped = text.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return text
    }
    
    // MARK: - Share/Save
    
    func shareData(_ data: Data, filename: String, from viewController: UIViewController) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: tempURL)
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let popoverController = activityVC.popoverPresentationController {
                popoverController.sourceView = viewController.view
                popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            viewController.present(activityVC, animated: true)
        } catch {
            print("Error sharing data: \(error)")
        }
    }
    
    func shareText(_ text: String, filename: String, from viewController: UIViewController) {
        guard let data = text.data(using: .utf8) else { return }
        shareData(data, filename: filename, from: viewController)
    }
}

// MARK: - SwiftUI Integration

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
