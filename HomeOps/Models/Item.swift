//
//  Item.swift
//  HomeOps
//
//  Created by Kowshik on 11/2/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var id: UUID
    var name: String
    var purchaseDate: Date
    var warrantyDurationMonths: Int
    var serialNumber: String?
    var category: String
    var purchasePrice: Double?
    var storeName: String?
    var notes: String?
    var tags: [String]?
    var location: String?
    var isFavorite: Bool
    @Attribute(.externalStorage) var receiptImageData: Data?
    
    var warrantyExpirationDate: Date {
        Calendar.current.date(byAdding: .month, value: warrantyDurationMonths, to: purchaseDate) ?? purchaseDate
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: warrantyExpirationDate)
        return components.day ?? 0
    }
    
    var formattedPrice: String {
        guard let price = purchasePrice else { return "N/A" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: price)) ?? "N/A"
    }
    
    var displayTags: [String] {
        tags ?? []
    }
    
    init(name: String, purchaseDate: Date, warrantyMonths: Int, category: String) {
        self.id = UUID()
        self.name = name
        self.purchaseDate = purchaseDate
        self.warrantyDurationMonths = warrantyMonths
        self.category = category
        self.isFavorite = false
    }
}
