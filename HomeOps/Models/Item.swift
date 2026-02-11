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
    @Attribute(.externalStorage) var receiptImageData: Data? // Save heavy images outside DB
    
    var warrantyExpirationDate: Date {
        Calendar.current.date(byAdding: .month, value: warrantyDurationMonths, to: purchaseDate) ?? purchaseDate
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: warrantyExpirationDate)
        return components.day ?? 0
    }
    
    init(name: String, purchaseDate: Date, warrantyMonths: Int, category: String) {
        self.id = UUID()
        self.name = name
        self.purchaseDate = purchaseDate
        self.warrantyDurationMonths = warrantyMonths
        self.category = category
    }
}
