# Changelog

All notable changes to HomeOps will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- iCloud sync across devices
- Home Screen widgets
- Lock Screen widgets
- Siri shortcuts
- Apple Watch companion app
- Family sharing

## [1.0.1] - 2026-02-12

### Fixed
- **Critical: SwiftData Migration Error** - Fixed fatal database migration error preventing items from being saved
  - Added automatic database recovery system
  - Implements intelligent error detection for migration failures (error code 134110)
  - Automatically deletes corrupted database files and creates fresh database
  - Falls back to in-memory storage if all recovery attempts fail
  - Items now save and appear correctly in Dashboard and Collections
  
- **UI/Navigation Issues**
  - Fixed tab bar icon arrangement and spacing for better visual balance
  - Fixed scrolling issues in Settings view (removed conflicting NavigationView)
  - Fixed scrolling issues in Analytics view (proper ScrollView implementation)
  - Updated all views to use NavigationStack instead of deprecated NavigationView
  
- **Data Persistence**
  - Fixed items not appearing in Dashboard after save
  - Fixed items not appearing in Collections after save
  - Added explicit `modelContext.save()` calls for immediate persistence
  - Wrapped save operations in `@MainActor` tasks for thread safety

### Added
- **Enhanced Debugging**
  - Comprehensive debug logging throughout save flow
  - ModelContext tracking and validation
  - Item count logging in Dashboard and Collections views
  - Success/error messages for all save operations
  
- **Haptic Feedback Improvements**
  - Enhanced HapticManager with iOS simulator detection
  - Automatically disables haptics in simulator to prevent console errors
  - Maintains full haptic support on physical devices

### Changed
- **Technical Improvements**
  - Improved error handling in ModelContainer initialization
  - Better SwiftData context management
  - Enhanced console logging for easier debugging
  - More robust database lifecycle management

## [1.0.0] - TBD

### Added
- **Core Features**
  - Warranty tracking with expiration alerts
  - Receipt storage with image support
  - Smart OCR scanning (extracts name, price, date, store)
  - Local notifications for expiring warranties
  
- **Organization**
  - 16 predefined categories (Electronics, Appliances, etc.)
  - Custom category creation
  - Unlimited custom tags system
  - Location/room tracking
  - Favorites system
  - Smart collections (auto-grouped by category, location, tags)
  
- **Search & Filter**
  - Full-text search across items
  - Category filtering
  - 7 sorting options (date, name, warranty, price)
  - Advanced filtering combinations
  
- **Analytics Dashboard**
  - Overview statistics (total items, value, averages)
  - Category breakdown pie chart
  - Value analysis with top items
  - Warranty timeline visualization
  - Monthly purchase trends
  - Smart insights and recommendations
  
- **Warranty Claims Assistant**
  - 4-step guided workflow
  - Pre-written email templates
  - Document checklist
  - One-tap copy to clipboard
  
- **Data Export**
  - Individual item PDF reports
  - Full inventory PDF export
  - CSV export for backup/analysis
  - System share sheet integration
  - Text sharing
  
- **UI/UX**
  - Modern SwiftUI design
  - Custom design system (colors, typography, spacing)
  - Card-based layouts with shadows
  - Gradient backgrounds
  - Status badges (color-coded by urgency)
  - Progress indicators
  - Pull-to-refresh
  - Haptic feedback throughout
  - Dark mode support
  - VoiceOver accessibility
  
- **Technical**
  - SwiftData for local persistence
  - VisionKit for OCR
  - Swift Charts for analytics
  - PDFKit for report generation
  - UserNotifications for alerts
  - iOS 17.0+ requirement

### Changed
- N/A (initial release)

### Deprecated
- N/A (initial release)

### Removed
- N/A (initial release)

### Fixed
- N/A (initial release)

### Security
- All OCR processing happens on-device
- Receipt images stored locally with encryption
- No analytics or tracking
- No external dependencies

---

## Version History Summary

- **v1.0.0** (TBD) - Initial release with core features
- **v1.1.0** (Planned) - iCloud sync and widgets
- **v1.2.0** (Future) - Apple Watch and family sharing

---

[Unreleased]: https://github.com/yourusername/HomeOps/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourusername/HomeOps/releases/tag/v1.0.0
