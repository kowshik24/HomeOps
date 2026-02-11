//
//  CategoryManager.swift
//  HomeOps
//
//  Category Management System
//

import SwiftUI
import Combine

struct CategoryInfo: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var isCustom: Bool
    
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
    
    init(id: UUID = UUID(), name: String, icon: String, colorHex: String, isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.isCustom = isCustom
    }
}

class CategoryManager: ObservableObject {
    static let shared = CategoryManager()
    
    @Published var customCategories: [CategoryInfo] = []
    
    private let customCategoriesKey = "customCategories"
    
    private init() {
        loadCustomCategories()
    }
    
    // Predefined categories with rich metadata
    let predefinedCategories: [CategoryInfo] = [
        CategoryInfo(name: "Electronics", icon: "desktopcomputer", colorHex: "007AFF"),
        CategoryInfo(name: "Appliances", icon: "refrigerator.fill", colorHex: "AF52DE"),
        CategoryInfo(name: "Furniture", icon: "chair.lounge.fill", colorHex: "FF9500"),
        CategoryInfo(name: "Clothing", icon: "tshirt.fill", colorHex: "FF2D55"),
        CategoryInfo(name: "Kitchen", icon: "fork.knife", colorHex: "FF3B30"),
        CategoryInfo(name: "Tools", icon: "wrench.and.screwdriver.fill", colorHex: "5856D6"),
        CategoryInfo(name: "Sports", icon: "figure.run", colorHex: "34C759"),
        CategoryInfo(name: "Garden", icon: "leaf.fill", colorHex: "32D74B"),
        CategoryInfo(name: "Automotive", icon: "car.fill", colorHex: "8E8E93"),
        CategoryInfo(name: "Home Decor", icon: "lamp.table.fill", colorHex: "FF9500"),
        CategoryInfo(name: "Office", icon: "keyboard", colorHex: "5AC8FA"),
        CategoryInfo(name: "Audio/Video", icon: "hifispeaker.fill", colorHex: "007AFF"),
        CategoryInfo(name: "Gaming", icon: "gamecontroller.fill", colorHex: "AF52DE"),
        CategoryInfo(name: "Baby & Kids", icon: "figure.and.child.holdinghands", colorHex: "FF2D55"),
        CategoryInfo(name: "Pet Supplies", icon: "pawprint.fill", colorHex: "FF9500"),
        CategoryInfo(name: "Other", icon: "cube.box.fill", colorHex: "8E8E93")
    ]
    
    var allCategories: [CategoryInfo] {
        predefinedCategories + customCategories
    }
    
    var allCategoryNames: [String] {
        allCategories.map { $0.name }
    }
    
    // MARK: - Category Operations
    
    func getCategoryInfo(for name: String) -> CategoryInfo? {
        allCategories.first { $0.name == name }
    }
    
    func addCustomCategory(_ category: CategoryInfo) {
        var newCategory = category
        newCategory.isCustom = true
        customCategories.append(newCategory)
        saveCustomCategories()
    }
    
    func updateCustomCategory(_ category: CategoryInfo) {
        if let index = customCategories.firstIndex(where: { $0.id == category.id }) {
            customCategories[index] = category
            saveCustomCategories()
        }
    }
    
    func deleteCustomCategory(_ category: CategoryInfo) {
        customCategories.removeAll { $0.id == category.id }
        saveCustomCategories()
    }
    
    // MARK: - Persistence
    
    private func saveCustomCategories() {
        if let encoded = try? JSONEncoder().encode(customCategories) {
            UserDefaults.standard.set(encoded, forKey: customCategoriesKey)
        }
    }
    
    private func loadCustomCategories() {
        if let data = UserDefaults.standard.data(forKey: customCategoriesKey),
           let decoded = try? JSONDecoder().decode([CategoryInfo].self, from: data) {
            customCategories = decoded
        }
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}
