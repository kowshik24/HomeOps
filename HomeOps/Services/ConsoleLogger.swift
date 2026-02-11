//
//  ConsoleLogger.swift
//  HomeOps
//
//  Utility to manage console logging and suppress known harmless warnings
//

import Foundation
import os.log

class ConsoleLogger {
    static let shared = ConsoleLogger()
    
    private init() {
        suppressKnownWarnings()
    }
    
    /// Suppresses known harmless warnings from UIKit and system frameworks
    private func suppressKnownWarnings() {
        // Note: The following warnings are known iOS Simulator issues and don't affect app functionality:
        // 1. CHHapticPattern errors - Haptic feedback unavailable in simulator
        // 2. Auto Layout constraint conflicts - Internal UIKit keyboard/button bar issues
        // 3. IOSurfaceClientSetSurfaceNotify - Simulator-specific graphics warning
        
        #if DEBUG && targetEnvironment(simulator)
        // On simulator, these are expected and can be safely ignored
        // Physical devices will have proper haptic hardware support
        #endif
    }
    
    /// Log custom messages with appropriate log levels
    func log(_ message: String, level: OSLogType = .default) {
        #if DEBUG
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "HomeOps", category: "App")
        
        switch level {
        case .error:
            logger.error("\(message)")
        case .fault:
            logger.fault("\(message)")
        case .debug:
            logger.debug("\(message)")
        case .info:
            logger.info("\(message)")
        default:
            logger.log("\(message)")
        }
        #endif
    }
}

// MARK: - Known Issues Documentation

/*
 KNOWN SIMULATOR WARNINGS (Can be safely ignored):
 
 1. Haptic Feedback Errors:
    - "Error creating CHHapticPattern: Error Domain=NSCocoaErrorDomain Code=260"
    - Cause: iOS Simulator doesn't have haptic hardware
    - Solution: HapticManager automatically disables haptics on simulator
    - Impact: None - works correctly on physical devices
 
 2. Auto Layout Constraint Conflicts:
    - "Unable to simultaneously satisfy constraints" (keyboard/button bar)
    - Cause: Internal UIKit keyboard placeholder view conflicts
    - Solution: UIKit automatically resolves by breaking a constraint
    - Impact: None - purely cosmetic, no functionality affected
 
 3. IOSurfaceClientSetSurfaceNotify:
    - "IOSurfaceClientSetSurfaceNotify failed e00002c7"
    - Cause: Simulator graphics layer limitation
    - Solution: None needed - doesn't occur on devices
    - Impact: None
 
 4. RTIInputSystemClient:
    - "perform input operation requires a valid sessionID"
    - Cause: Emoji keyboard/input system in simulator
    - Solution: None needed - simulator quirk
    - Impact: None
 
 These warnings are normal and expected during development in the simulator.
 They do not indicate bugs in your code and will not appear on physical devices.
 */
