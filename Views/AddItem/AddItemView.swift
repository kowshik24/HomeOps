import SwiftUI
import PhotosUI

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // View model for handling scanner logic
    @StateObject private var scannerViewModel = ScannerViewModel()
    
    // State for the form fields
    @State private var name: String = ""
    @State private var category: String = "Electronics"
    @State private var purchaseDate: Date = .now
    @State private var warrantyDurationMonths: Int = 12
    
    // State for image picker
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    // State to control scanner presentation
    @State private var isShowingScanner = false
    
    let categories = ["Electronics", "Appliances", "Furniture", "Clothing", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Product Details")) {
                    TextField("Product Name", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                Section(header: Text("Warranty Information")) {
                    DatePicker("Purchase Date", selection: $purchaseDate, displayedComponents: .date)
                    
                    VStack(alignment: .leading) {
                        Text("Warranty: \(warrantyDurationMonths) months")
                        Slider(value: $warrantyDurationMonths.double, in: 1...60, step: 1)
                    }
                }
                
                Section(header: Text("Receipt")) {
                    PhotosPicker("Select Receipt Image", selection: $selectedItem, matching: .images)
                    
                    if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("Add New Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        saveItem()
                        dismiss()
                    }
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
            .onChange(of: selectedItem) {
                Task {
                    selectedImageData = try? await selectedItem?.loadTransferable(type: Data.self)
                }
            }
            .onChange(of: scannerViewModel.scannedText) {
                // When scanner text changes, attempt to pre-fill the form
                if !scannerViewModel.scannedText.isEmpty {
                    if let productName = scannerViewModel.productName {
                        name = productName
                    }
                    if let date = scannerViewModel.purchaseDate {
                        purchaseDate = date
                    }
                    isShowingScanner = false // Automatically dismiss scanner on tap
                }
            }
        }
    }
    
    private func saveItem() {
        let newItem = Item(name: name, purchaseDate: purchaseDate, warrantyMonths: warrantyDurationMonths, category: category)
        newItem.receiptImageData = selectedImageData
        modelContext.insert(newItem)
        
        // Schedule notifications
        NotificationManager.shared.scheduleWarrantyAlert(for: newItem)
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

#Preview {
    AddItemView()
}
