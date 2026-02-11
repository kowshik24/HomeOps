//
//  HapticManager.swift
//  HomeOps
//
//  Haptic feedback manager with error suppression
//

import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private var isHapticsAvailable: Bool {
        // Haptics are only available on physical devices
        #if targetEnvironment(simulator)
        return false
        #else
        return true
        #endif
    }
    
    // MARK: - Impact Feedback
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isHapticsAvailable else { return }
        
        DispatchQueue.main.async {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }
    }
    
    // MARK: - Notification Feedback
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isHapticsAvailable else { return }
        
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        }
    }
    
    // MARK: - Selection Feedback
    
    func selection() {
        guard isHapticsAvailable else { return }
        
        DispatchQueue.main.async {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
}
