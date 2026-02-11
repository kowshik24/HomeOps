import SwiftUI
import SwiftData
import PhotosUI

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var itemToEdit: Item?
    
    @StateObject private var scannerViewModel = ScannerViewModel()
    
    @State private var name: String = ""
    @State private var category: String = "Electronics"
    @State private var purchaseDate: Date = .now
    @State private var warrantyDurationMonths: Int = 12
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    @State private var isShowingScanner = false
    
    let categories = ["Electronics", "Appliances", "Furniture", "Clothing", "Other"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Receipt Image Picker
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        ZStack {
                            if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .clipped()
                            } else {
                                Rectangle()
                                    .fill(Color(.systemGray6))
                                    .frame(height: 200)
                                
                                VStack {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.largeTitle)
                                    Text("Tap to add a receipt")
                                        .font(.headline)
                                }
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // MARK: - Form Fields
                    VStack(spacing: 15) {
                        StyledTextField(icon: "square.and.pencil", placeholder: "Product Name", text: $name)
                        
                        StyledPicker(icon: "tag.fill", selection: $category, categories: categories)
                        
                        StyledDatePicker(icon: "calendar", selection: $purchaseDate)
                        
                        StyledSlider(icon: "hourglass", value: $warrantyDurationMonths, range: 1...60, label: "Warranty")
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color(.systemGroupedBackground))
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
            .onAppear(perform: setupView)
            .onChange(of: selectedItem) {
                Task {
                    selectedImageData = try? await selectedItem?.loadTransferable(type: Data.self)
                }
            }
            .onChange(of: scannerViewModel.scannedText) {
                if !scannerViewModel.scannedText.isEmpty {
                    if let productName = scannerViewModel.productName { name = productName }
                    if let date = scannerViewModel.purchaseDate { purchaseDate = date }
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
        }
    }
    
    private func saveItem() {
        // Haptic feedback for a satisfying save action
        let haptic = UIImpactFeedbackGenerator(style: .medium)
        haptic.impactOccurred()
        
        if let item = itemToEdit {
            item.name = name
            item.purchaseDate = purchaseDate
            item.warrantyDurationMonths = warrantyDurationMonths
            item.category = category
            item.receiptImageData = selectedImageData
        } else {
            let newItem = Item(name: name, purchaseDate: purchaseDate, warrantyMonths: warrantyDurationMonths, category: category)
            newItem.receiptImageData = selectedImageData
            modelContext.insert(newItem)
            NotificationManager.shared.scheduleWarrantyAlert(for: newItem)
        }
        dismiss()
    }
}

// MARK: - Styled Form Components

struct StyledTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(.secondary)
            TextField(placeholder, text: $text)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

struct StyledPicker: View {
    let icon: String
    @Binding var selection: String
    let categories: [String]
    
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(.secondary)
            Picker("Category", selection: $selection) {
                ForEach(categories, id: \.self) { Text($0) }
            }
            .pickerStyle(.menu)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

struct StyledDatePicker: View {
    let icon: String
    @Binding var selection: Date
    
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(.secondary)
            DatePicker("Purchase Date", selection: $selection, displayedComponents: .date)
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

struct StyledSlider: View {
    let icon: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let label: String
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: icon).foregroundColor(.secondary)
                Text("\(label): \(value) months")
                Spacer()
            }
            Slider(value: Binding(
                get: { Double(value) },
                set: { value = Int($0) }
            ), in: Double(range.lowerBound)...Double(range.upperBound), step: 1)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

// Helper to bind Int to Slider's Double
extension Binding where Value == Int {
    var double: Binding<Double> {
        Binding<Double>(
            get: { Double(self.wrappedValue) },
            set: { self.wrappedValue = Int($0) }
        )
    }
}
