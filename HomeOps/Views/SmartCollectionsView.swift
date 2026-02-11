//
//  SmartCollectionsView.swift
//  HomeOps
//
//  Smart Collections - Auto-generated item groups
//

import SwiftUI
import SwiftData

struct SmartCollectionsView: View {
    @Query private var items: [Item]
    
    var body: some View {
        let _ = print("📦 CollectionsView body evaluated - Total items: \(items.count)")
        
        return NavigationStack {
            List {
                // Favorites
                if !favoriteItems.isEmpty {
                    NavigationLink(destination: CollectionDetailView(title: "Favorites", items: favoriteItems, icon: "star.fill", color: .yellow)) {
                        CollectionRow(title: "Favorites", count: favoriteItems.count, icon: "star.fill", color: .yellow)
                    }
                }
                
                // Recently Added
                NavigationLink(destination: CollectionDetailView(title: "Recently Added", items: recentlyAddedItems, icon: "clock.fill", color: .blue)) {
                    CollectionRow(title: "Recently Added", count: recentlyAddedItems.count, icon: "clock.fill", color: .blue)
                }
                
                // High Value
                if !highValueItems.isEmpty {
                    NavigationLink(destination: CollectionDetailView(title: "High Value", items: highValueItems, icon: "dollarsign.circle.fill", color: .green)) {
                        CollectionRow(title: "High Value", count: highValueItems.count, icon: "dollarsign.circle.fill", color: .green)
                    }
                }
                
                // Categories
                Section(header: Text("By Category")) {
                    ForEach(categoriesWithItems, id: \.0) { category, categoryItems in
                        NavigationLink(destination: CollectionDetailView(title: category, items: categoryItems, icon: "tag.fill", color: .purple)) {
                            CollectionRow(title: category, count: categoryItems.count, icon: "tag.fill", color: .purple)
                        }
                    }
                }
                
                // Locations
                if !locationsWithItems.isEmpty {
                    Section(header: Text("By Location")) {
                        ForEach(locationsWithItems, id: \.0) { location, locationItems in
                            NavigationLink(destination: CollectionDetailView(title: location, items: locationItems, icon: "location.fill", color: .orange)) {
                                CollectionRow(title: location, count: locationItems.count, icon: "location.fill", color: .orange)
                            }
                        }
                    }
                }
                
                // Tags
                if !tagsWithItems.isEmpty {
                    Section(header: Text("By Tag")) {
                        ForEach(tagsWithItems, id: \.0) { tag, taggedItems in
                            NavigationLink(destination: CollectionDetailView(title: tag, items: taggedItems, icon: "tag.fill", color: .pink)) {
                                CollectionRow(title: tag, count: taggedItems.count, icon: "tag.fill", color: .pink)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Collections")
        }
    }
    
    // MARK: - Computed Collections
    
    private var favoriteItems: [Item] {
        items.filter { $0.isFavorite }
    }
    
    private var recentlyAddedItems: [Item] {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return items.filter { $0.purchaseDate >= thirtyDaysAgo }
            .sorted { $0.purchaseDate > $1.purchaseDate }
    }
    
    private var highValueItems: [Item] {
        items.filter { ($0.purchasePrice ?? 0) >= 500 }
            .sorted { ($0.purchasePrice ?? 0) > ($1.purchasePrice ?? 0) }
    }
    
    private var categoriesWithItems: [(String, [Item])] {
        let grouped = Dictionary(grouping: items) { $0.category }
        return grouped.map { ($0.key, $0.value) }
            .sorted { $0.0 < $1.0 }
    }
    
    private var locationsWithItems: [(String, [Item])] {
        let itemsWithLocation = items.filter { $0.location != nil }
        let grouped = Dictionary(grouping: itemsWithLocation) { $0.location! }
        return grouped.map { ($0.key, $0.value) }
            .sorted { $0.0 < $1.0 }
    }
    
    private var tagsWithItems: [(String, [Item])] {
        var tagDict: [String: [Item]] = [:]
        for item in items {
            for tag in item.displayTags {
                tagDict[tag, default: []].append(item)
            }
        }
        return tagDict.map { ($0.key, $0.value) }
            .sorted { $0.0 < $1.0 }
    }
}

// MARK: - Collection Row
struct CollectionRow: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.callout)
                    .fontWeight(.medium)
                Text("\(count) item\(count == 1 ? "" : "s")")
                    .font(AppTypography.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

// MARK: - Collection Detail View
struct CollectionDetailView: View {
    let title: String
    let items: [Item]
    let icon: String
    let color: Color
    
    var body: some View {
        List {
            ForEach(items) { item in
                NavigationLink(destination: ItemDetailView(item: item)) {
                    ItemRowView(item: item)
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                    Text(title)
                        .font(AppTypography.headline)
                }
            }
        }
    }
}

#Preview {
    SmartCollectionsView()
        .modelContainer(for: Item.self, inMemory: true)
}
