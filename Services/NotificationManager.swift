import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success { print("Permissions granted") }
        }
    }
    
    func scheduleWarrantyAlert(for item: Item) {
        let content = UNMutableNotificationContent()
        content.title = "Warranty Expiring Soon!"
        content.body = "The warranty for \(item.name) expires in 30 days."
        content.sound = .default
        
        // Calculate date 30 days before expiration
        guard let triggerDate = Calendar.current.date(byAdding: .day, value: -30, to: item.warrantyExpirationDate) else { return }
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
