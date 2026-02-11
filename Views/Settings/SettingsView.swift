import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notifications")) {
                    Button("Request Notification Permissions") {
                        NotificationManager.shared.requestPermission()
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text(Bundle.main.appVersion ?? "N/A")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

extension Bundle {
    var appVersion: String? {
        self.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

#Preview {
    SettingsView()
}
