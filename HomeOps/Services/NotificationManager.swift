import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success { print("Permissions granted") }
        }
    }
    
    func scheduleWarrantyAlert(for item: Item) {
        // 30-Day Alert
        scheduleAlert(for: item, daysBefore: 30, title: "Warranty Expiring Soon!", body: "The warranty for \(item.name) expires in 30 days.")
        
        // 1-Week Alert
        scheduleAlert(for: item, daysBefore: 7, title: "Final Warranty Notice!", body: "The warranty for \(item.name) expires in just one week.")
    }
    
    private func scheduleAlert(for item: Item, daysBefore: Int, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        guard let triggerDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: item.warrantyExpirationDate) else { return }
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Use a unique identifier for each notification
        let identifier = "\(item.id.uuidString)-\(daysBefore)days"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}
