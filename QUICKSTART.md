# HomeOps - Quick Start Guide

## 🚀 Running the App

### Prerequisites
- macOS 14.0 or later
- Xcode 15.0 or later
- iOS 17.0+ simulator or device

### Step 1: Open Project
```bash
cd /Users/kowshik/personal-work/HomeOps
open HomeOps.xcodeproj
```

### Step 2: Select Target
1. In Xcode, click the scheme dropdown (top-left)
2. Select **HomeOps** scheme
3. Choose a simulator (e.g., iPhone 15 Pro)

### Step 3: Build & Run
Press **⌘R** or click the Play button

---

## 🧪 Testing

### Run All Tests
Press **⌘U** in Xcode

### Run Specific Test
Right-click on test method → Run "test_name"

---

## 🏗️ Build Configurations

### Debug (Development)
- Optimizations disabled
- Debug symbols included
- Assertions enabled
- Used for development

### Release (Production)
- Full optimizations
- Debug symbols stripped
- Assertions disabled
- Used for App Store

---

## 📱 Simulator Shortcuts

### iOS Simulator
- **⌘+Shift+H** - Home button
- **⌘+Shift+A** - App Switcher
- **⌘+K** - Toggle keyboard
- **⌘+Left/Right** - Rotate device
- **⌘+S** - Take screenshot

### Xcode Shortcuts
- **⌘+B** - Build
- **⌘+R** - Build & Run
- **⌘+.** - Stop running
- **⌘+Shift+K** - Clean build
- **⌘+U** - Run tests
- **⌘+I** - Profile (Instruments)

---

## 🔧 Common Issues & Solutions

### Issue: "Developer cannot be verified"
**Solution:**
1. Open System Settings → Privacy & Security
2. Click "Open Anyway" for HomeOps
3. Run again from Xcode

### Issue: "Unable to boot simulator"
**Solution:**
```bash
# Reset simulator
xcrun simctl shutdown all
xcrun simctl erase all
```

### Issue: Build fails with "No signing certificate"
**Solution:**
1. Xcode → Settings → Accounts
2. Add your Apple ID
3. Select team in project settings
4. Choose "Automatically manage signing"

### Issue: SwiftData error on first launch
**Solution:**
- This is expected - SwiftData creates database on first run
- Restart the app if needed
- Check Console for detailed error messages

---

## 🎨 Design Preview

### SwiftUI Previews
1. Open any View file (e.g., `DashboardView.swift`)
2. Press **⌘+Option+Enter** to show preview
3. Click play button in preview to interact

### Preview Multiple Devices
```swift
#Preview {
    DashboardView()
        .previewDevice("iPhone 15 Pro")
}

#Preview {
    DashboardView()
        .previewDevice("iPhone SE (3rd generation)")
}
```

---

## 📊 Performance Profiling

### Memory Leaks
1. Run app with **⌘+I**
2. Choose "Leaks" instrument
3. Use app and check for red markers

### CPU Usage
1. Run app with **⌘+I**
2. Choose "Time Profiler"
3. Record and analyze hotspots

### SwiftUI View Hierarchy
1. While running, click Debug View Hierarchy (pause-like icon)
2. 3D view shows all layers
3. Inspect individual views

---

## 🐛 Debugging Tips

### Print Debugging
```swift
print("🔍 Debug: \(variable)")
debugPrint(complexObject)
```

### Breakpoints
- Click line number to add breakpoint
- Right-click breakpoint → Edit for conditions
- **po** command in console to print objects

### View Modifiers for Debugging
```swift
.border(Color.red) // See view bounds
.background(Color.blue.opacity(0.3)) // Visualize layout
```

---

## 📦 Archiving for Distribution

### Create Archive
1. Product → Archive (⌘+B)
2. Wait for build to complete
3. Organizer window opens automatically

### Export for Testing
1. Select archive
2. Click "Distribute App"
3. Choose "Development" or "Ad Hoc"
4. Follow wizard

### Export for App Store
1. Select archive
2. Click "Distribute App"
3. Choose "App Store Connect"
4. Upload to TestFlight

---

## 🔍 Console Logs

### View Logs
1. Window → Devices and Simulators
2. Select device
3. Click "Open Console" button
4. Filter by "HomeOps"

### Log Levels
```swift
// Debug (development only)
#if DEBUG
print("Debug info")
#endif

// Always log
NSLog("Important event")

// Structured logging
os_log("OCR completed", log: .default, type: .info)
```

---

## 📲 Install on Device

### Wireless Debugging (iOS 17+)
1. Connect device via USB once
2. Window → Devices and Simulators
3. Right-click device → Connect via Network
4. Unplug USB - now wireless!

### Run on Device
1. Select your device in scheme
2. Xcode will handle signing automatically
3. Press ⌘+R
4. Trust developer on device if prompted

---

## 🎯 Feature Testing Checklist

### Core Features
- [ ] Add new item manually
- [ ] Scan receipt with camera
- [ ] Edit existing item
- [ ] Delete item
- [ ] Mark item as favorite

### Organization
- [ ] Apply filters
- [ ] Sort by different options
- [ ] Search for items
- [ ] Browse collections
- [ ] Add custom tags

### Analytics
- [ ] View dashboard
- [ ] Check all charts render
- [ ] Read insights
- [ ] Navigate between sections

### Export
- [ ] Export item PDF
- [ ] Export inventory PDF
- [ ] Export CSV
- [ ] Share via AirDrop
- [ ] Share via Messages

### Claims
- [ ] Start claims assistant
- [ ] Complete all 4 steps
- [ ] Copy email to clipboard
- [ ] Verify email content

---

## 🌐 Localization Testing

### Test Languages
1. Edit Scheme → Run → Options
2. Application Language → Choose language
3. Test all screens for text overflow

### Current Support
- English (US) - ✅ Fully supported
- Other languages - Use system translations

---

## 💾 Data Management

### View Database Location
```swift
// Add to app for debugging
print(FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask))
```

### Reset Database
1. Delete app from simulator
2. Run again - fresh database

### Backup Data (for testing)
1. Export to CSV
2. Save file
3. Reset app
4. Re-import (future feature)

---

## 🎓 Learning Resources

### SwiftUI
- [Apple SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Hacking with Swift](https://www.hackingwithswift.com)

### SwiftData
- [Apple SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [WWDC23 SwiftData Session](https://developer.apple.com/videos/play/wwdc2023/10187/)

### VisionKit
- [DataScannerViewController Guide](https://developer.apple.com/documentation/visionkit/datascannerviewcontroller)

---

## 🚨 Emergency Procedures

### App Won't Launch
1. Clean Build Folder (**⌘+Shift+K**)
2. Delete Derived Data
3. Restart Xcode
4. Restart Mac (if needed)

### Xcode Freezes
1. Force quit Xcode
2. Delete `~/Library/Developer/Xcode/DerivedData`
3. Reopen project

### Corrupted Project
1. Close Xcode
2. Delete `.xcodeproj/project.xcworkspace`
3. Delete `.xcodeproj/xcuserdata`
4. Reopen - Xcode regenerates

---

## 📞 Getting Help

### Resources
1. Check `ARCHITECTURE.md` for technical details
2. Review `CONTRIBUTING.md` for guidelines
3. Read `README.md` for overview
4. Check `BUILD_REPORT.md` for status

### Community
- GitHub Issues
- Stack Overflow (tag: swiftui)
- Swift Forums
- Apple Developer Forums

---

**Last Updated:** February 12, 2026  
**For:** HomeOps v1.0.0

**Happy Coding! 🎉**
