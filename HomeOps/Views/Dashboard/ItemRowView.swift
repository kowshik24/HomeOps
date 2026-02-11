import SwiftUI

struct ItemRowView: View {
    let item: Item
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Thumbnail or Category Icon
            thumbnail
            
            // Content
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                // Header: Name + Badge
                HStack {
                    Text(item.name)
                        .font(AppTypography.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    StatusBadge(daysRemaining: item.daysRemaining)
                }
                
                // Category
                Text(item.category)
                    .font(AppTypography.caption)
                    .foregroundColor(.secondary)
                
                // Warranty Progress
                WarrantyProgressIndicator(item: item)
                    .padding(.top, AppSpacing.xs)
                
                // Footer: Expiration Date
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text("Expires \(item.warrantyExpirationDate, style: .date)")
                        .font(AppTypography.caption2)
                    Spacer()
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(AppSpacing.md)
        .cardStyle(elevation: .low)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(borderColor, lineWidth: 2)
                .opacity(0.3)
        )
    }
    
    // MARK: - Thumbnail
    @ViewBuilder
    private var thumbnail: some View {
        ZStack {
            if let imageData = item.receiptImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
            } else {
                RoundedRectangle(cornerRadius: AppRadius.sm)
                    .fill(categoryGradient)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: categoryIcon(for: item.category))
                            .font(.title2)
                            .foregroundColor(.white)
                    )
            }
        }
        .shadow(color: AppShadow.small.color, radius: AppShadow.small.radius, x: AppShadow.small.x, y: AppShadow.small.y)
    }
    
    // MARK: - Helpers
    private var borderColor: Color {
        if item.daysRemaining <= 7 {
            return AppColors.statusExpiring
        } else if item.daysRemaining <= 30 {
            return AppColors.statusWarning
        } else {
            return .clear
        }
    }
    
    private var categoryGradient: LinearGradient {
        switch item.category {
        case "Electronics":
            return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "Appliances":
            return LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "Furniture":
            return LinearGradient(colors: [.brown, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "Clothing":
            return LinearGradient(colors: [.pink, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [.gray, .secondary], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    private func categoryIcon(for category: String) -> String {
        switch category {
        case "Electronics":
            return "desktopcomputer"
        case "Appliances":
            return "refrigerator.fill"
        case "Furniture":
            return "chair.lounge.fill"
        case "Clothing":
            return "tshirt.fill"
        default:
            return "cube.box.fill"
        }
    }
}

// MARK: - Warranty Progress Indicator (Enhanced)
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
            return AppColors.statusExpiring
        } else if item.daysRemaining <= 90 {
            return AppColors.statusWarning
        } else {
            return AppColors.statusActive
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .frame(width: geometry.size.width, height: 6)
                        .foregroundColor(Color(.systemGray5))
                    
                    // Progress
                    Capsule()
                        .frame(width: geometry.size.width * CGFloat(warrantyProgress), height: 6)
                        .foregroundColor(progressColor)
                }
            }
            .frame(height: 6)
        }
    }
}
