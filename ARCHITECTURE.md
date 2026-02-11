# HomeOps Architecture

This document describes the technical architecture, design patterns, and key decisions behind HomeOps.

## Table of Contents
- [Overview](#overview)
- [Architecture Pattern](#architecture-pattern)
- [Project Structure](#project-structure)
- [Data Layer](#data-layer)
- [UI Layer](#ui-layer)
- [Service Layer](#service-layer)
- [Design System](#design-system)
- [Key Technologies](#key-technologies)
- [Performance Considerations](#performance-considerations)
- [Security](#security)

## Overview

HomeOps is built using modern iOS development practices with a focus on:
- **Native Performance** - SwiftUI and SwiftData for optimal performance
- **Type Safety** - Swift's strong type system prevents runtime errors
- **Maintainability** - Clear separation of concerns and modular design
- **Testability** - Business logic isolated from UI
- **Accessibility** - Full VoiceOver support and Dynamic Type

## Architecture Pattern

### MVVM (Model-View-ViewModel)

```
┌─────────────────────────────────────────┐
│              SwiftUI Views              │
│  (Declarative UI, State-driven)         │
└────────────┬────────────────────────────┘
             │ @StateObject/@ObservedObject
             ▼
┌─────────────────────────────────────────┐
│            ViewModels                   │
│  (Business Logic, State Management)     │
└────────────┬────────────────────────────┘
             │ @Published
             ▼
┌─────────────────────────────────────────┐
│         SwiftData Models                │
│  (Data Persistence, Core Data)          │
└─────────────────────────────────────────┘
```

**Why MVVM?**
- Clean separation between UI and business logic
- Testable business logic (ViewModels can be unit tested)
- SwiftUI's reactive nature pairs perfectly with MVVM
- ObservableObject makes state management trivial

## Project Structure

```
HomeOps/
├── App/
│   ├── HomeOpsApp.swift          # App lifecycle, SwiftData setup
│   └── ContentView.swift         # Root view with tab navigation
│
├── Models/
│   ├── Item.swift                # Core data model (@Model)
│   ├── CategoryManager.swift    # Category business logic
│   └── TagManager.swift          # Tag management
│
├── Views/
│   ├── Dashboard/
│   │   ├── DashboardView.swift  # Main inventory list
│   │   └── ItemRowView.swift    # List item component
│   ├── AddItem/
│   │   ├── AddItemView.swift    # Item creation/editing
│   │   └── ScannerView.swift    # OCR scanner
│   ├── Detail/
│   │   └── ItemDetailView.swift # Item detail with actions
│   ├── Settings/
│   │   └── SettingsView.swift   # App settings
│   ├── AnalyticsView.swift      # Analytics dashboard
│   ├── SmartCollectionsView.swift # Auto-generated collections
│   ├── WarrantyClaimView.swift  # Claims assistant
│   ├── TagComponents.swift      # Tag UI components
│   └── DesignSystem.swift       # Design tokens and components
│
├── ViewModels/
│   ├── InventoryViewModel.swift # Inventory business logic
│   └── ScannerViewModel.swift   # OCR processing logic
│
└── Services/
    ├── NotificationManager.swift # Push notifications
    ├── ExportManager.swift       # PDF/CSV generation
    └── ImageStore.swift          # Image persistence
```

### Organizational Principles
1. **Feature-based** - Views grouped by feature, not type
2. **Flat hierarchy** - Avoid deep nesting
3. **Single Responsibility** - Each file has one clear purpose
4. **Reusable Components** - Extract common UI patterns

## Data Layer

### SwiftData (@Model)

```swift
@Model
final class Item {
    var id: UUID
    var name: String
    var purchaseDate: Date
    var warrantyDurationMonths: Int
    var category: String
    var purchasePrice: Decimal?
    var tags: [String]?
    var location: String?
    var isFavorite: Bool
    @Attribute(.externalStorage) var receiptImageData: Data?
    
    // Computed properties
    var warrantyExpirationDate: Date { ... }
    var daysRemaining: Int { ... }
}
```

**Key Decisions:**
- `@Model` macro generates boilerplate (no manual Core Data stack)
- `@Attribute(.externalStorage)` keeps images out of main database
- Optionals for fields that may not exist
- Computed properties for derived data
- UUID for stable identity across devices

### ModelContainer Setup

```swift
@main
struct HomeOpsApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Item.self)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
```

### Data Access Patterns

**Query Data:**
```swift
@Query(sort: \Item.purchaseDate, order: .reverse) private var items: [Item]
```

**Insert Data:**
```swift
let item = Item(name: "iPhone", purchaseDate: .now, warrantyMonths: 12, category: "Electronics")
modelContext.insert(item)
```

**Update Data:**
```swift
item.isFavorite = true
// Auto-saved by SwiftData
```

**Delete Data:**
```swift
modelContext.delete(item)
```

## UI Layer

### SwiftUI View Lifecycle

```
View Creation
    ↓
@State initialization
    ↓
body evaluation
    ↓
View appears (.onAppear)
    ↓
State changes trigger body re-evaluation
    ↓
View disappears (.onDisappear)
```

### State Management

**View-local state:**
```swift
@State private var isEditing = false
```

**Shared state (ViewModel):**
```swift
@StateObject private var viewModel = InventoryViewModel()
```

**Passed state:**
```swift
@Binding var selectedCategory: String
```

**Environment:**
```swift
@Environment(\.modelContext) private var modelContext
@Environment(\.dismiss) private var dismiss
```

### Navigation

Custom tab bar implementation:
```swift
VStack {
    // Content
    ZStack {
        if selectedTab == .dashboard { DashboardView() }
        else if selectedTab == .collections { SmartCollectionsView() }
        else if selectedTab == .settings { SettingsView() }
    }
    
    // Custom Tab Bar
    CustomTabBar(selectedTab: $selectedTab)
}
```

**Why custom?**
- Full design control
- Centered FAB (Floating Action Button)
- Smooth animations
- Better for complex layouts

## Service Layer

### Singleton Managers

Services use the singleton pattern for app-wide access:

```swift
class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    func scheduleWarrantyAlert(for item: Item) { ... }
}
```

### NotificationManager

Handles all local notifications:
- Permission requests
- Schedule warranty alerts (30 days before)
- Cancel notifications
- Notification content formatting

### ExportManager

Generates reports:
- **PDF Generation:** UIGraphicsPDFRenderer for individual items and full inventory
- **CSV Export:** Properly escaped CSV for Excel/Google Sheets
- **Share Sheet:** Integration with UIActivityViewController

### ImageStore

Manages receipt images:
- Compression (reduce file size)
- Thumbnail generation
- External storage via SwiftData
- Memory management

## Design System

Centralized in `DesignSystem.swift`:

### Colors
```swift
struct AppColors {
    static let primary = Color.accentColor
    static let success = Color.green
    static let warning = Color.orange
    static let danger = Color.red
}
```

### Typography
```swift
struct AppTypography {
    static let hero = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    // ...
}
```

### Spacing
```swift
struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
}
```

### Component Modifiers
```swift
.cardStyle(elevation: .medium)  // Adds shadow and background
.glassStyle()                   // Translucent material
.pressableButton()              // Scale animation on press
```

## Key Technologies

### SwiftData (iOS 17+)
- Modern replacement for Core Data
- Swift-first API with macros
- Automatic schema migration
- Type-safe queries
- CloudKit sync ready (future)

### VisionKit
- DataScannerViewController for live text recognition
- On-device ML (no server calls)
- Supports text and barcodes
- Real-time scanning

### Swift Charts (iOS 16+)
- Native charting framework
- Accessible by default
- Smooth animations
- Multiple chart types (pie, bar, line, area)

### PDFKit
- Native PDF generation
- Text and image support
- Multi-page documents
- System share integration

## Performance Considerations

### Memory Management
- **Images:** External storage keeps database small
- **Queries:** Lazy loading with `@Query`
- **Views:** Break into small components to limit re-renders

### Database Optimization
- **Indexes:** SwiftData auto-indexes primary keys
- **Predicates:** Efficient filtering at database level
- **Sorting:** Done in SQL, not in-memory

### Image Handling
```swift
// Compress before saving
if let data = image.jpegData(compressionQuality: 0.7) {
    item.receiptImageData = data
}
```

### Lazy Loading
```swift
// Only load visible rows
LazyVStack {
    ForEach(items) { item in
        ItemRowView(item: item)
    }
}
```

## Security

### Data Protection
- **Local Storage:** All data encrypted at rest (iOS default)
- **No Cloud:** Data never leaves device (until iCloud sync)
- **No Analytics:** No tracking or telemetry
- **Sandboxed:** Standard iOS app sandbox

### OCR Privacy
- **On-Device:** All text recognition happens locally
- **No Server:** Receipts never uploaded anywhere
- **User Control:** Users can review before saving

### Image Storage
- **External Storage:** Prevents accidental data leaks
- **Compressed:** Reduces file size
- **Local Only:** Never synced to third parties

## Testing Strategy

### Unit Tests
Test business logic in ViewModels:
```swift
func test_warrantyExpiration_calculatesCorrectly() {
    let item = Item(...)
    XCTAssertEqual(item.daysRemaining, expectedDays)
}
```

### UI Tests
Test critical user flows:
- Add item flow
- Edit item flow
- Export flow
- Claims assistant flow

### Manual Testing
- Multiple device sizes (iPhone SE to Pro Max)
- Dark mode
- VoiceOver
- Dynamic Type (all sizes)
- Low bandwidth
- Low storage

## Future Architecture

### iCloud Sync (v1.1)
```
Local SwiftData ←→ CloudKit ←→ Other Devices
```

### Widgets (v1.1)
```
WidgetKit Extension
    ↓
Shared SwiftData Container
    ↓
Timeline Provider
```

### Apple Watch (v1.2)
```
Watch Extension
    ↓
WatchConnectivity
    ↓
iPhone App
```

## Design Decisions

### Why SwiftData over Core Data?
- Simpler API (less boilerplate)
- Swift-first (no Objective-C baggage)
- Better compiler integration
- Future-proof (Apple's focus)

### Why SwiftUI over UIKit?
- Declarative = less code
- Better performance (diffing algorithm)
- Automatic accessibility
- Native dark mode
- Future-proof

### Why No External Dependencies?
- Faster compile times
- No supply chain vulnerabilities
- Smaller binary size
- No version conflicts
- Complete control

### Why No Backend?
- Privacy (data never leaves device)
- No server costs
- Works offline
- No account required
- Simpler architecture

---

**Last Updated:** February 2026  
**Version:** 1.0.0
