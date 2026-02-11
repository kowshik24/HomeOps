import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.purchaseDate, order: .reverse) private var items: [Item]
    
    @State private var searchText = ""
    @State private var isRefreshing = false
    @State private var selectedCategory: String = "All"
    @State private var sortOption: SortOption = .dateNewest
    @State private var showingFilters = false
    
    enum SortOption: String, CaseIterable {
        case dateNewest = "Date (Newest)"
        case dateOldest = "Date (Oldest)"
        case nameAZ = "Name (A-Z)"
        case nameZA = "Name (Z-A)"
        case warrantyExpiring = "Warranty (Expiring Soon)"
        case priceHighest = "Price (Highest)"
        case priceLowest = "Price (Lowest)"
    }
    
    var filteredItems: [Item] {
        var result = items
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) || 
                $0.category.localizedCaseInsensitiveContains(searchText) 
            }
        }
        
        // Apply category filter
        if selectedCategory != "All" {
            result = result.filter { $0.category == selectedCategory }
        }
        
        // Apply sorting
        switch sortOption {
        case .dateNewest:
            result.sort { $0.purchaseDate > $1.purchaseDate }
        case .dateOldest:
            result.sort { $0.purchaseDate < $1.purchaseDate }
        case .nameAZ:
            result.sort { $0.name < $1.name }
        case .nameZA:
            result.sort { $0.name > $1.name }
        case .warrantyExpiring:
            result.sort { $0.daysRemaining < $1.daysRemaining }
        case .priceHighest:
            result.sort { ($0.purchasePrice ?? 0) > ($1.purchasePrice ?? 0) }
        case .priceLowest:
            result.sort { ($0.purchasePrice ?? 0) < ($1.purchasePrice ?? 0) }
        }
        
        return result
    }
    
    var availableCategories: [String] {
        ["All"] + Array(Set(items.map { $0.category })).sorted()
    }
    
    // Computed stats
    var expiringSoonCount: Int {
        items.filter { $0.daysRemaining <= 30 && $0.daysRemaining > 0 }.count
    }
    
    var expiredCount: Int {
        items.filter { $0.daysRemaining <= 0 }.count
    }
    
    var activeCount: Int {
        items.filter { $0.daysRemaining > 30 }.count
    }
    
    var totalWarrantyValue: Double {
        items.compactMap { $0.purchasePrice }.reduce(0, +)
    }
    
    var formattedTotalValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: totalWarrantyValue)) ?? "$0"
    }
    
    // Grouped items
    var expiringSoonItems: [Item] {
        filteredItems.filter { $0.daysRemaining <= 30 && $0.daysRemaining > 0 }
    }
    
    var activeItems: [Item] {
        filteredItems.filter { $0.daysRemaining > 30 }
    }
    
    var expiredItems: [Item] {
        filteredItems.filter { $0.daysRemaining <= 0 }
    }
    
    var body: some View {
        let _ = print("📱 DashboardView body evaluated - Total items: \(items.count)")
        let _ = print("   DashboardView ModelContext: \(modelContext)")
        
        return NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    if !items.isEmpty {
                        // Stats Header
                        statsHeader
                            .padding(.horizontal, AppSpacing.md)
                        
                        // Expiring Soon Section
                        if !expiringSoonItems.isEmpty {
                            itemSection(
                                title: "Expiring Soon",
                                icon: "exclamationmark.triangle.fill",
                                color: AppColors.statusWarning,
                                items: expiringSoonItems
                            )
                        }
                        
                        // Active Section
                        if !activeItems.isEmpty {
                            itemSection(
                                title: "Active Warranties",
                                icon: "checkmark.shield.fill",
                                color: AppColors.statusActive,
                                items: activeItems
                            )
                        }
                        
                        // Expired Section
                        if !expiredItems.isEmpty {
                            itemSection(
                                title: "Expired",
                                icon: "xmark.circle.fill",
                                color: AppColors.statusExpired,
                                items: expiredItems
                            )
                        }
                    } else {
                        emptyStateView
                    }
                }
                .padding(.vertical, AppSpacing.md)
            }
            .background(AppColors.background)
            .navigationTitle("My Inventory")
            .searchable(text: $searchText, prompt: "Search by name or category")
            .refreshable {
                await performRefresh()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(availableCategories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        
                        Divider()
                        
                        Picker("Sort By", selection: $sortOption) {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title3)
                    }
                }
            }
        }
    }
    
    // MARK: - Stats Header
    private var statsHeader: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                StatCard(
                    icon: "archivebox.fill",
                    title: "Total Items",
                    value: "\(items.count)",
                    color: AppColors.primary
                )
                
                StatCard(
                    icon: "clock.fill",
                    title: "Expiring Soon",
                    value: "\(expiringSoonCount)",
                    color: AppColors.statusWarning
                )
            }
            
            if totalWarrantyValue > 0 {
                StatCard(
                    icon: "dollarsign.circle.fill",
                    title: "Total Value Protected",
                    value: formattedTotalValue,
                    color: AppColors.success
                )
            }
            
            if expiredCount > 0 {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(AppColors.statusExpiring)
                    Text("\(expiredCount) item(s) have expired warranties")
                        .font(AppTypography.footnote)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(AppSpacing.sm)
                .background(AppColors.statusExpiring.opacity(0.1))
                .cornerRadius(AppRadius.sm)
            }
        }
    }
    
    // MARK: - Item Section
    private func itemSection(title: String, icon: String, color: Color, items: [Item]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(AppTypography.title3)
                    .fontWeight(.bold)
                Spacer()
                Text("\(items.count)")
                    .font(AppTypography.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, AppSpacing.md)
            
            ForEach(items) { item in
                NavigationLink(destination: ItemDetailView(item: item)) {
                    ItemRowView(item: item)
                        .padding(.horizontal, AppSpacing.md)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        EmptyStateView(
            icon: "archivebox.fill",
            title: "No Items Yet",
            message: "Start tracking your warranties by adding your first item. Tap the '+' button below to get started!",
            actionTitle: nil,
            action: nil
        )
        .padding(.top, 100)
    }
    
    // MARK: - Actions
    private func performRefresh() async {
        isRefreshing = true
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
        isRefreshing = false
    }
    
    private func deleteItems(offsets: IndexSet) {
        HapticManager.shared.impact(style: .medium)
        
        withAnimation(AppAnimation.spring) {
            for index in offsets {
                if let itemToDelete = items.first(where: { $0.id == filteredItems[index].id }) {
                    modelContext.delete(itemToDelete)
                }
            }
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: Item.self, inMemory: true)
}
