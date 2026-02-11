import SwiftUI

struct ItemRowView: View {
    let item: Item
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: categoryIcon(for: item.category))
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 40, height: 40)
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                WarrantyProgressIndicator(item: item)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func categoryIcon(for category: String) -> String {
        switch category {
        case "Electronics":
            return "desktopcomputer"
        case "Appliances":
            return "refrigerator"
        case "Furniture":
            return "chair.lounge"
        case "Clothing":
            return "tshirt"
        default:
            return "cube.box"
        }
    }
}

// A dedicated view for the warranty progress bar
struct WarrantyProgressIndicator: View {
    let item: Item
    
    private var warrantyProgress: Double {
        let totalDuration = item.warrantyExpirationDate.timeIntervalSince(item.purchaseDate)
        if totalDuration <= 0 { return 1.0 }
        let elapsed = Date().timeIntervalSince(item.purchaseDate)
        return min(max(elapsed / totalDuration, 0), 1)
    }
    
    private var progressColor: Color {
        if item.daysRemaining <= 30 {
            return .red
        } else if item.daysRemaining <= 90 {
            return .orange
        } else {
            return .green
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .frame(width: geometry.size.width, height: 6)
                        .foregroundColor(Color(.systemGray5))
                    
                    Capsule()
                        .frame(width: geometry.size.width * CGFloat(warrantyProgress), height: 6)
                        .foregroundColor(progressColor)
                }
            }
            .frame(height: 6)
            
            Text("\(item.daysRemaining) days remaining")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    let sampleItem = Item(name: "Wireless Headphones", purchaseDate: .now.addingTimeInterval(-60 * 24 * 3600), warrantyMonths: 12, category: "Electronics")
    return ItemRowView(item: sampleItem)
        .padding()
}
