import SwiftUI
import SwiftData

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.purchaseDate, order: .reverse) private var items: [Item]
    
    @State private var searchText = ""
    
    var filteredItems: [Item] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.category.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if items.isEmpty {
                    emptyStateView
                } else {
                    itemList
                }
            }
            .navigationTitle("My Inventory")
            .searchable(text: $searchText, prompt: "Search by name or category")
        }
    }
    
    private var itemList: some View {
        List {
            ForEach(filteredItems) { item in
                NavigationLink(destination: ItemDetailView(item: item)) {
                    ItemRowView(item: item)
                }
            }
            .onDelete(perform: deleteItems)
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Image(systemName: "archivebox.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No Items Yet")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top)
            Text("Tap the '+' tab to add your first item.")
                .foregroundColor(.secondary)
        }
        .padding()
        .multilineTextAlignment(.center)
    }
    
    private func deleteItems(offsets: IndexSet) {
        // Haptic feedback for a more satisfying delete action
        let haptic = UIImpactFeedbackGenerator(style: .medium)
        haptic.impactOccurred()
        
        withAnimation {
            for index in offsets {
                // Ensure we are deleting from the original source of truth
                if let itemToDelete = items.first(where: { $0.id == filteredItems[index].id }) {
                    modelContext.delete(itemToDelete)
                }
            }
        }
    }
}
