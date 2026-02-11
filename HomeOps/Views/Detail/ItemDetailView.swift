import SwiftUI

struct ItemDetailView: View {
    let item: Item
    @State private var isEditing = false
    @State private var showShareSheet = false
    @State private var showingClaimsAssistant = false
    @State private var shareItem: Any?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Hero Header
                heroHeader
                
                // MARK: - Content
                VStack(spacing: AppSpacing.lg) {
                    // Name and Category
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(item.name)
                            .font(AppTypography.hero)
                        
                        HStack {
                            Image(systemName: categoryIcon(for: item.category))
                            Text(item.category)
                        }
                        .font(AppTypography.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppSpacing.md)
                    
                    // Warranty Card
                    warrantyCard
                        .padding(.horizontal, AppSpacing.md)
                    
                    // Info Cards
                    infoCards
                        .padding(.horizontal, AppSpacing.md)
                    
                    // Quick Actions
                    quickActions
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, AppSpacing.xl)
                }
                .padding(.top, AppSpacing.lg)
            }
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isEditing = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            AddItemView(itemToEdit: item)
        }
        .sheet(isPresented: $showingClaimsAssistant) {
            WarrantyClaimView(item: item)
        }
        .sheet(isPresented: $showShareSheet) {
            if let item = shareItem {
                ActivityViewController(activityItems: [item])
            }
        }
    }
    
    // MARK: - Hero Header
    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageData = item.receiptImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)
                    .clipped()
            } else {
                LinearGradient(
                    colors: categoryGradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 300)
                .overlay(
                    Image(systemName: categoryIcon(for: item.category))
                        .font(.system(size: 100))
                        .foregroundColor(.white.opacity(0.3))
                )
            }
            
            // Gradient Overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Status Badge
            HStack {
                Spacer()
                StatusBadge(daysRemaining: item.daysRemaining)
                    .padding(AppSpacing.md)
            }
        }
        .frame(height: 300)
    }
    
    // MARK: - Warranty Card
    private var warrantyCard: some View {
        VStack(spacing: AppSpacing.md) {
            Text("Warranty Status")
                .font(AppTypography.title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: AppSpacing.lg) {
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(lineWidth: 12)
                        .opacity(0.1)
                        .foregroundColor(progressColor)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(warrantyProgress))
                        .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .foregroundColor(progressColor)
                        .rotationEffect(Angle(degrees: 270.0))
                    
                    VStack(spacing: 4) {
                        Text("\(item.daysRemaining)")
                            .font(AppTypography.title1)
                            .fontWeight(.bold)
                        Text("days")
                            .font(AppTypography.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 120, height: 120)
                
                // Details
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    InfoRow(icon: "calendar.badge.clock", label: "Purchased", value: item.purchaseDate.formatted(date: .abbreviated, time: .omitted))
                    InfoRow(icon: "calendar.badge.exclamationmark", label: "Expires", value: item.warrantyExpirationDate.formatted(date: .abbreviated, time: .omitted))
                    InfoRow(icon: "hourglass", label: "Duration", value: "\(item.warrantyDurationMonths) months")
                }
            }
        }
        .padding(AppSpacing.md)
        .cardStyle(elevation: .medium)
    }
    
    // MARK: - Info Cards
    private var infoCards: some View {
        VStack(spacing: AppSpacing.md) {
            Text("Details")
                .font(AppTypography.title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: AppSpacing.sm) {
                DetailInfoRow(label: "Category", value: item.category)
                
                if let _ = item.purchasePrice {
                    DetailInfoRow(label: "Purchase Price", value: item.formattedPrice)
                }
                
                if let store = item.storeName {
                    DetailInfoRow(label: "Store", value: store)
                }
                
                if let location = item.location {
                    DetailInfoRow(label: "Location", value: location)
                }
                
                DetailInfoRow(label: "Purchase Date", value: item.purchaseDate.formatted(date: .long, time: .omitted))
                DetailInfoRow(label: "Warranty Period", value: "\(item.warrantyDurationMonths) months")
                DetailInfoRow(label: "Status", value: statusText)
                
                if !item.displayTags.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Tags")
                            .font(AppTypography.callout)
                            .foregroundColor(.secondary)
                        FlowLayout(spacing: AppSpacing.xs) {
                            ForEach(item.displayTags, id: \.self) { tag in
                                TagChip(tag: tag, isSelected: false)
                            }
                        }
                    }
                    .padding(.top, AppSpacing.xs)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if let notes = item.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Notes")
                            .font(AppTypography.callout)
                            .foregroundColor(.secondary)
                        Text(notes)
                            .font(AppTypography.callout)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, AppSpacing.xs)
                }
            }
            .padding(AppSpacing.md)
            .cardStyle(elevation: .low)
        }
    }
    
    // MARK: - Quick Actions
    private var quickActions: some View {
        VStack(spacing: AppSpacing.md) {
            Text("Quick Actions")
                .font(AppTypography.title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: AppSpacing.sm) {
                // File Claim Button (prominent)
                Button(action: { showingClaimsAssistant = true }) {
                    HStack {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("File Warranty Claim")
                                .font(AppTypography.headline)
                            Text("Step-by-step assistance")
                                .font(AppTypography.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .padding(AppSpacing.md)
                    .background(
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(AppRadius.md)
                }
                .pressableButton()
                
                // Other Actions
                HStack(spacing: AppSpacing.md) {
                    ActionButton(icon: "square.and.arrow.up", title: "Share", color: .blue) {
                        shareItemText()
                    }
                    
                    ActionButton(icon: "doc.text", title: "Export PDF", color: .green) {
                        exportPDF()
                    }
                    
                    ActionButton(icon: "bell", title: "Remind", color: .orange) {
                        // Reminder action
                        NotificationManager.shared.scheduleWarrantyAlert(for: item)
                    }
                }
            }
        }
    }
    
    private func shareItemText() {
        let text = """
        \(item.name)
        Category: \(item.category)
        \(item.purchasePrice != nil ? "Price: \(item.formattedPrice)" : "")
        Purchase Date: \(item.purchaseDate.formatted(date: .long, time: .omitted))
        Warranty Expires: \(item.warrantyExpirationDate.formatted(date: .long, time: .omitted))
        Days Remaining: \(item.daysRemaining)
        """
        
        self.shareItem = text
        showShareSheet = true
    }
    
    private func exportPDF() {
        guard let pdfData = ExportManager.shared.generateItemPDF(for: item) else { return }
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(item.name)_Warranty.pdf")
        
        do {
            try pdfData.write(to: tempURL)
            self.shareItem = tempURL
            showShareSheet = true
        } catch {
            print("Error saving PDF: \(error)")
        }
    }
    
    // MARK: - Helpers
    private var categoryGradientColors: [Color] {
        switch item.category {
        case "Electronics": return [.blue, .cyan]
        case "Appliances": return [.purple, .pink]
        case "Furniture": return [.brown, .orange]
        case "Clothing": return [.pink, .red]
        default: return [.gray, .secondary]
        }
    }
    
    private func categoryIcon(for category: String) -> String {
        switch category {
        case "Electronics": return "desktopcomputer"
        case "Appliances": return "refrigerator.fill"
        case "Furniture": return "chair.lounge.fill"
        case "Clothing": return "tshirt.fill"
        default: return "cube.box.fill"
        }
    }
    
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
    
    private var statusText: String {
        if item.daysRemaining <= 0 { return "Expired" }
        else if item.daysRemaining <= 7 { return "Expiring Soon" }
        else if item.daysRemaining <= 30 { return "Expiring This Month" }
        else { return "Active" }
    }
}

// MARK: - Supporting Views

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            Text(label)
                .font(AppTypography.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(AppTypography.callout)
                .fontWeight(.medium)
        }
    }
}

struct DetailInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppTypography.callout)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(AppTypography.callout)
                .fontWeight(.medium)
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xs) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(AppTypography.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(AppRadius.md)
        }
        .pressableButton()
    }
}

// A dedicated view for the warranty progress ring
struct WarrantyProgressView: View {
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
