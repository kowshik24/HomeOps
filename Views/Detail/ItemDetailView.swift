import SwiftUI

struct ItemDetailView: View {
    let item: Item
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: - Header Image or Icon
                if let imageData = item.receiptImageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipped()
                } else {
                    // Placeholder if no image is available
                    Image(systemName: categoryIcon(for: item.category))
                        .font(.system(size: 80))
                        .foregroundColor(.secondary)
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                }
                
                // MARK: - Main Content
                VStack(alignment: .leading, spacing: 15) {
                    Text(item.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(item.category)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    // MARK: - Warranty Status
                    VStack(alignment: .leading) {
                        Text("Warranty Status")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        WarrantyProgressView(item: item)
                            .padding(.top, 5)
                    }
                    
                    Divider()
                    
                    // MARK: - Key Dates
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Purchase Date")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(item.purchaseDate, style: .date)
                                .fontWeight(.medium)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Warranty Expires")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(item.warrantyExpirationDate, style: .date)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
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

// A dedicated view for the warranty progress ring
struct WarrantyProgressView: View {
    let item: Item
    
    private var warrantyProgress: Double {
        let totalDuration = item.warrantyExpirationDate.timeIntervalSince(item.purchaseDate)
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
        HStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.1)
                    .foregroundColor(progressColor)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(warrantyProgress))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .foregroundColor(progressColor)
                    .rotationEffect(Angle(degrees: 270.0))
            }
            .frame(width: 80, height: 80)
            
            VStack(alignment: .leading) {
                Text("\(item.daysRemaining) days")
                    .font(.title)
                    .fontWeight(.bold)
                Text("remaining")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    let sampleItem = Item(name: "Sample Laptop", purchaseDate: .now.addingTimeInterval(-100 * 24 * 3600), warrantyMonths: 12, category: "Electronics")
    return NavigationView {
        ItemDetailView(item: sampleItem)
    }
}
