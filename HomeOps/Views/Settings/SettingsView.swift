import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var items: [Item]
    @State private var showingExportOptions = false
    @State private var showingShareSheet = false
    @State private var shareItem: Any?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Data & Insights")) {
                    NavigationLink(destination: AnalyticsView()) {
                        Label("Analytics Dashboard", systemImage: "chart.bar.fill")
                    }
                }
                
                Section(header: Text("Export & Backup")) {
                    Button(action: exportPDF) {
                        Label("Export to PDF", systemImage: "doc.fill")
                    }
                    
                    Button(action: exportCSV) {
                        Label("Export to CSV", systemImage: "tablecells")
                    }
                    
                    Text("Export your entire inventory for backup or sharing.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Notifications")) {
                    Button("Request Notification Permissions") {
                        NotificationManager.shared.requestPermission()
                    }
                    Text("Manage notification settings for warranty alerts.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Items")
                        Spacer()
                        Text("\(items.count)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingShareSheet) {
                if let item = shareItem {
                    ActivityViewController(activityItems: [item])
                }
            }
        }
    }
    
    private func exportPDF() {
        guard let pdfData = ExportManager.shared.generateInventoryPDF(for: items) else { return }
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("HomeOps_Inventory.pdf")
        
        do {
            try pdfData.write(to: tempURL)
            shareItem = tempURL
            showingShareSheet = true
        } catch {
            print("Error saving PDF: \(error)")
        }
    }
    
    private func exportCSV() {
        let csvString = ExportManager.shared.generateCSV(for: items)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("HomeOps_Inventory.csv")
        
        do {
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            shareItem = tempURL
            showingShareSheet = true
        } catch {
            print("Error saving CSV: \(error)")
        }
    }
}

#Preview {
    SettingsView()
}
