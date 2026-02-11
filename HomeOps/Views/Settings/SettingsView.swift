import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
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
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
