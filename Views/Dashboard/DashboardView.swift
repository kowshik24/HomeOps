import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.purchaseDate, order: .reverse) private var items: [Item]
    
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
        }
    }
    
    private var itemList: some View {
        List {
            ForEach(items) { item in
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
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: Item.self, inMemory: true)
}
