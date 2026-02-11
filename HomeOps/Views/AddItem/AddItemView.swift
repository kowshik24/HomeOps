import SwiftUI
import SwiftData
import PhotosUI

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var itemToEdit: Item?
    
    @StateObject private var scannerViewModel = ScannerViewModel()
    @StateObject private var categoryManager = CategoryManager.shared
    
    @State private var name: String = ""
    @State private var category: String = "Electronics"
    @State private var purchaseDate: Date = .now
    @State private var warrantyDurationMonths: Int = 12
    @State private var purchasePrice: String = ""
    @State private var storeName: String = ""
    @State private var notes: String = ""
    @State private var selectedTags: Set<String> = []
    @State private var location: String = ""
    @State private var isFavorite: Bool = false
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    @State private var isShowingScanner = false
    @State private var showingTagPicker = false
    
    let commonLocations = ["Living Room", "Bedroom", "Kitchen", "Garage", "Office", "Basement", "Attic", "Storage"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // MARK: - Receipt Image Picker
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        ZStack {
                            if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 220)
                                    .clipped()
                                    .overlay(
                                        LinearGradient(
                                            colors: [.clear, .black.opacity(0.3)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .overlay(
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Image(systemName: "photo.badge.plus")
                                                    .font(.caption)
                                                Text("Tap to change")
                                                    .font(AppTypography.caption)
                                            }
                                            .foregroundColor(.white)
                                            .padding(AppSpacing.sm)
                                            .background(.ultraThinMaterial)
                                            .cornerRadius(AppRadius.sm)
                                            .padding(AppSpacing.md)
                                        }
                                    )
                            } else {
                                Rectangle()
                                    .fill(AppColors.surfaceVariant)
                                    .frame(height: 220)
                                    .overlay(
                                        VStack(spacing: AppSpacing.md) {
                                            Image(systemName: "photo.on.rectangle.angled")
                                                .font(.system(size: 60))
                                                .foregroundColor(AppColors.primary.opacity(0.5))
                                            Text("Tap to add a receipt photo")
                                                .font(AppTypography.headline)
                                                .foregroundColor(.secondary)
                                        }
                                    )
                            }
                        }
                        .cornerRadius(AppRadius.lg)
                    }
                    .padding(.horizontal, AppSpacing.md)
                    
                    // MARK: - Form Fields
                    VStack(spacing: AppSpacing.md) {
                        // Basic Info
                        HStack {
                            StyledTextField(icon: "square.and.pencil", placeholder: "Product Name", text: $name)
                            
                            Button(action: { isFavorite.toggle() }) {
                                Image(systemName: isFavorite ? "star.fill" : "star")
                                    .font(.title3)
                                    .foregroundColor(isFavorite ? .yellow : .secondary)
                                    .padding(AppSpacing.md)
                                    .background(AppColors.surface)
                                    .cornerRadius(AppRadius.md)
                            }
                            .pressableButton()
                        }
                        
                        StyledPicker(icon: "tag.fill", selection: $category, categories: categoryManager.allCategoryNames)
                        
                        // Financial Info
                        StyledTextField(icon: "dollarsign.circle", placeholder: "Purchase Price (Optional)", text: $purchasePrice, keyboardType: .decimalPad)
                        
                        StyledTextField(icon: "building.2", placeholder: "Store Name (Optional)", text: $storeName)
                        
                        // Date & Warranty
                        StyledDatePicker(icon: "calendar", selection: $purchaseDate)
                        
                        StyledSlider(icon: "hourglass", value: $warrantyDurationMonths, range: 1...60, label: "Warranty")
                        
                        // Location
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            HStack(spacing: AppSpacing.md) {
                                Image(systemName: "location.fill")
                                    .foregroundColor(AppColors.primary)
                                    .frame(width: 24)
                                Text("Location (Optional)")
                                    .font(AppTypography.callout)
                                    .foregroundColor(.secondary)
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppSpacing.xs) {
                                    ForEach(commonLocations, id: \.self) { loc in
                                        Button(action: { location = loc }) {
                                            Text(loc)
                                                .font(AppTypography.footnote)
                                                .padding(.horizontal, AppSpacing.sm)
                                                .padding(.vertical, AppSpacing.xs)
                                                .background(location == loc ? AppColors.primary : AppColors.surfaceVariant)
                                                .foregroundColor(location == loc ? .white : .primary)
                                                .cornerRadius(AppRadius.sm)
                                        }
                                        .pressableButton()
                                    }
                                }
                            }
                            
                            TextField("Or enter custom location", text: $location)
                                .font(AppTypography.body)
                                .padding(AppSpacing.sm)
                                .background(Color(.systemBackground))
                                .cornerRadius(AppRadius.sm)
                        }
                        .padding(AppSpacing.md)
                        .cardStyle(elevation: .low)
                        
                        // Tags
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            HStack(spacing: AppSpacing.md) {
                                Image(systemName: "tag.fill")
                                    .foregroundColor(AppColors.primary)
                                    .frame(width: 24)
                                Text("Tags (Optional)")
                                    .font(AppTypography.callout)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button(action: { showingTagPicker.toggle() }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(AppColors.primary)
                                }
                            }
                            
                            if !selectedTags.isEmpty {
                                FlowLayout(spacing: AppSpacing.xs) {
                                    ForEach(Array(selectedTags), id: \.self) { tag in
                                        TagChip(tag: tag, isSelected: true) {
                                            selectedTags.remove(tag)
                                        }
                                    }
                                }
                            } else {
                                Text("No tags added")
                                    .font(AppTypography.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, AppSpacing.xs)
                            }
                        }
                        .padding(AppSpacing.md)
                        .cardStyle(elevation: .low)
                        
                        // Notes field
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            HStack(spacing: AppSpacing.md) {
                                Image(systemName: "note.text")
                                    .foregroundColor(AppColors.primary)
                                    .frame(width: 24)
                                Text("Notes (Optional)")
                                    .font(AppTypography.callout)
                                    .foregroundColor(.secondary)
                            }
                            
                            TextEditor(text: $notes)
                                .frame(height: 80)
                                .font(AppTypography.body)
                                .padding(AppSpacing.xs)
                                .background(Color(.systemBackground))
                                .cornerRadius(AppRadius.sm)
                        }
                        .padding(AppSpacing.md)
                        .cardStyle(elevation: .low)
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, AppSpacing.xl)
                }
            }
            .background(AppColors.background)
            .navigationTitle(itemToEdit == nil ? "Add New Item" : "Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save", action: saveItem)
                        .disabled(name.isEmpty)
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        isShowingScanner = true
                    } label: {
                        Label("Scan Receipt", systemImage: "doc.text.viewfinder")
                    }
                    .font(.headline)
                }
            }
            .sheet(isPresented: $isShowingScanner) {
                ScannerView(scannedText: $scannerViewModel.scannedText)
            }
            .sheet(isPresented: $showingTagPicker) {
                TagPickerSheet(selectedTags: $selectedTags)
            }
            .onAppear(perform: setupView)
            .onChange(of: selectedItem) {
                Task {
                    selectedImageData = try? await selectedItem?.loadTransferable(type: Data.self)
                }
            }
            .onChange(of: scannerViewModel.scannedText) {
                if !scannerViewModel.scannedText.isEmpty {
                    // Extract and populate all available data
                    if let productName = scannerViewModel.productName { 
                        name = productName 
                    }
                    if let date = scannerViewModel.purchaseDate { 
                        purchaseDate = date 
                    }
                    if let price = scannerViewModel.purchasePrice {
                        purchasePrice = String(describing: price)
                    }
                    if let store = scannerViewModel.storeName {
                        storeName = store
                    }
                    isShowingScanner = false
                }
            }
        }
    }
    
    private func setupView() {
        if let item = itemToEdit {
            name = item.name
            category = item.category
            purchaseDate = item.purchaseDate
            warrantyDurationMonths = item.warrantyDurationMonths
            selectedImageData = item.receiptImageData
            
            if let price = item.purchasePrice {
                purchasePrice = String(describing: price)
            }
            storeName = item.storeName ?? ""
            notes = item.notes ?? ""
            location = item.location ?? ""
            isFavorite = item.isFavorite
            selectedTags = Set(item.displayTags)
        }
    }
    
    private func saveItem() {
        // Haptic feedback for a satisfying save action
        HapticManager.shared.impact(style: .medium)
        
        print("💾 SAVE FUNCTION CALLED")
        print("   Name: '\(name)'")
        print("   Category: '\(category)'")
        print("   ModelContext: \(modelContext)")
        
        // Ensure we're on the main actor
        Task { @MainActor in
            if let item = itemToEdit {
                // Edit existing item
                print("📝 Editing existing item: \(item.id)")
                item.name = name
                item.purchaseDate = purchaseDate
                item.warrantyDurationMonths = warrantyDurationMonths
                item.category = category
                item.receiptImageData = selectedImageData
                item.purchasePrice = Double(purchasePrice)
                item.storeName = storeName.isEmpty ? nil : storeName
                item.notes = notes.isEmpty ? nil : notes
                item.location = location.isEmpty ? nil : location
                item.tags = selectedTags.isEmpty ? nil : Array(selectedTags)
                item.isFavorite = isFavorite
            } else {
                // Create new item
                print("➕ Creating new item")
                let newItem = Item(
                    name: name,
                    purchaseDate: purchaseDate,
                    warrantyMonths: warrantyDurationMonths,
                    category: category
                )
                newItem.receiptImageData = selectedImageData
                newItem.purchasePrice = Double(purchasePrice)
                newItem.storeName = storeName.isEmpty ? nil : storeName
                newItem.notes = notes.isEmpty ? nil : notes
                newItem.location = location.isEmpty ? nil : location
                newItem.tags = selectedTags.isEmpty ? nil : Array(selectedTags)
                newItem.isFavorite = isFavorite
                
                print("   Created item with ID: \(newItem.id)")
                print("   Name: \(newItem.name)")
                print("   Category: \(newItem.category)")
                
                // Insert into context
                modelContext.insert(newItem)
                print("   ✓ Inserted into modelContext")
                
                // Verify item is in context
                let descriptor = FetchDescriptor<Item>()
                if let allItems = try? modelContext.fetch(descriptor) {
                    print("   📊 Items in context after insert: \(allItems.count)")
                    print("   📊 Last item: \(allItems.last?.name ?? "none")")
                }
                
                // Schedule notification
                NotificationManager.shared.scheduleWarrantyAlert(for: newItem)
            }
            
            // Explicitly save the context
            do {
                try modelContext.save()
                print("✅ Item saved successfully!")
                
                // Verify save by fetching all items
                let descriptor = FetchDescriptor<Item>()
                if let allItems = try? modelContext.fetch(descriptor) {
                    print("   📊 Total items after save: \(allItems.count)")
                    for (index, item) in allItems.enumerated() {
                        print("      \(index + 1). \(item.name) (\(item.category))")
                    }
                }
            } catch {
                print("❌ Error saving item: \(error.localizedDescription)")
                print("   Full error: \(error)")
            }
            
            // Dismiss sheet
            print("👋 Dismissing sheet")
            dismiss()
        }
    }
}

// MARK: - Styled Form Components

struct StyledTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primary)
                .frame(width: 24)
            TextField(placeholder, text: $text)
                .font(AppTypography.body)
                .keyboardType(keyboardType)
        }
        .padding(AppSpacing.md)
        .cardStyle(elevation: .low)
    }
}

struct StyledPicker: View {
    let icon: String
    @Binding var selection: String
    let categories: [String]
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primary)
                .frame(width: 24)
            Picker("Category", selection: $selection) {
                ForEach(categories, id: \.self) { 
                    Text($0)
                        .font(AppTypography.body)
                }
            }
            .pickerStyle(.menu)
            Spacer()
        }
        .padding(AppSpacing.md)
        .cardStyle(elevation: .low)
    }
}

struct StyledDatePicker: View {
    let icon: String
    @Binding var selection: Date
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primary)
                .frame(width: 24)
            DatePicker("Purchase Date", selection: $selection, displayedComponents: .date)
                .font(AppTypography.body)
            Spacer()
        }
        .padding(AppSpacing.md)
        .cardStyle(elevation: .low)
    }
}

struct StyledSlider: View {
    let icon: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let label: String
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .foregroundColor(AppColors.primary)
                    .frame(width: 24)
                Text("\(label): \(value) months")
                    .font(AppTypography.body)
                Spacer()
            }
            
            Slider(value: Binding(
                get: { Double(value) },
                set: { value = Int($0) }
            ), in: Double(range.lowerBound)...Double(range.upperBound), step: 1)
            .tint(AppColors.primary)
        }
        .padding(AppSpacing.md)
        .cardStyle(elevation: .low)
    }
}
