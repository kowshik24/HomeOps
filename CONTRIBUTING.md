# Contributing to HomeOps

Thanks for your interest in making HomeOps better! This guide will help you get started.

## Getting Started

### Prerequisites
- macOS 14.0+
- Xcode 15.0+
- Git
- Basic Swift and SwiftUI knowledge

### Setup
1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/HomeOps.git
   cd HomeOps
   ```
3. Open `HomeOps.xcodeproj` in Xcode
4. Build and run (⌘R)

## Development Workflow

### Branch Strategy
- `main` - Stable, production-ready code
- `develop` - Integration branch for features
- `feature/[name]` - New features
- `bugfix/[name]` - Bug fixes
- `hotfix/[name]` - Urgent production fixes

### Making Changes

1. **Create a branch:**
   ```bash
   git checkout -b feature/my-awesome-feature
   ```

2. **Make your changes:**
   - Write clean, self-documenting code
   - Follow existing code style
   - Add comments for complex logic
   - Test on multiple device sizes

3. **Commit your changes:**
   ```bash
   git add .
   git commit -m "feat: add awesome new feature"
   ```

4. **Push to your fork:**
   ```bash
   git push origin feature/my-awesome-feature
   ```

5. **Open a Pull Request**

## Code Style

### Swift Style Guide
We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).

**Key Points:**
- Use `camelCase` for variables and functions
- Use `PascalCase` for types and protocols
- Prefer `let` over `var`
- Use meaningful names (no abbreviations)
- Keep functions focused and small

**Example:**
```swift
// Good
func calculateWarrantyExpiration(purchaseDate: Date, months: Int) -> Date {
    Calendar.current.date(byAdding: .month, value: months, to: purchaseDate) ?? purchaseDate
}

// Bad
func calcExp(d: Date, m: Int) -> Date {
    Calendar.current.date(byAdding: .month, value: m, to: d) ?? d
}
```

### SwiftUI Best Practices
- Break large views into smaller components
- Use `@State` for view-local state
- Use `@StateObject` for ViewModel ownership
- Use `@ObservedObject` for passed ViewModels
- Extract computed properties for readability

### File Organization
```
Feature/
├── FeatureView.swift          # Main view
├── FeatureViewModel.swift     # Business logic
├── FeatureModel.swift         # Data models
└── Components/                # Reusable components
    ├── FeatureCard.swift
    └── FeatureRow.swift
```

## Commit Message Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `style:` - Formatting, missing semicolons, etc.
- `refactor:` - Code restructuring
- `test:` - Adding tests
- `chore:` - Maintenance tasks

**Examples:**
```
feat(scanner): add barcode scanning support
fix(dashboard): correct expiration date calculation
docs(readme): update installation instructions
style(design): apply new color scheme
refactor(export): extract PDF generation logic
test(model): add Item model unit tests
chore(deps): update SwiftLint configuration
```

## Testing

### Running Tests
```bash
# Command line
xcodebuild test -scheme HomeOps -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Or use Xcode: ⌘U
```

### Writing Tests
- Test business logic, not UI
- Use descriptive test names
- Follow Arrange-Act-Assert pattern

**Example:**
```swift
func test_warrantyExpiration_whenPurchasedToday_shouldExpireInTwelveMonths() {
    // Arrange
    let item = Item(name: "Test", purchaseDate: Date(), warrantyMonths: 12, category: "Test")
    
    // Act
    let expiration = item.warrantyExpirationDate
    
    // Assert
    let expectedDate = Calendar.current.date(byAdding: .month, value: 12, to: Date())!
    XCTAssertEqual(expiration.timeIntervalSince1970, expectedDate.timeIntervalSince1970, accuracy: 60)
}
```

## Pull Request Process

### Before Submitting
- [ ] Code builds without errors
- [ ] Tests pass
- [ ] No new warnings
- [ ] Code follows style guide
- [ ] Commit messages follow convention
- [ ] Documentation updated if needed

### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tested on iPhone (specify models)
- [ ] Tested on iPad
- [ ] Dark mode tested
- [ ] Accessibility tested

## Screenshots
[If UI changes, include before/after screenshots]

## Related Issues
Fixes #123
```

### Review Process
1. Submit PR with clear description
2. Wait for CI checks to pass
3. Address review feedback
4. Maintainer will merge once approved

## Code Review Guidelines

### As a Reviewer
- Be kind and constructive
- Focus on code quality, not personal style
- Suggest improvements with examples
- Approve promptly if changes look good

### As a Contributor
- Don't take feedback personally
- Ask questions if unclear
- Make requested changes promptly
- Thank reviewers for their time

## Design System

HomeOps uses a centralized design system (`DesignSystem.swift`):

### Colors
```swift
AppColors.primary         // Accent color
AppColors.success         // Green for positive actions
AppColors.warning         // Orange for warnings
AppColors.danger          // Red for errors
```

### Typography
```swift
AppTypography.hero        // 34pt bold rounded
AppTypography.title1      // 28pt bold rounded
AppTypography.body        // 17pt regular
AppTypography.caption     // 12pt regular
```

### Spacing
```swift
AppSpacing.xs   // 4pt
AppSpacing.sm   // 8pt
AppSpacing.md   // 16pt
AppSpacing.lg   // 24pt
AppSpacing.xl   // 32pt
```

### Components
Always use existing components before creating new ones:
- `CardStyle` - Elevated card with shadow
- `StatusBadge` - Color-coded status indicator
- `TagChip` - Tag display with remove option
- `StatCard` - Analytics stat card

## Architecture

### MVVM Pattern
```
View → ViewModel → Model
  ↓                  ↓
SwiftUI           SwiftData
```

- **View**: SwiftUI views (display only)
- **ViewModel**: Business logic, state management
- **Model**: Data structures, SwiftData models

### Services
Singleton managers for cross-cutting concerns:
- `CategoryManager` - Category management
- `TagManager` - Tag management
- `NotificationManager` - Push notifications
- `ExportManager` - PDF/CSV export

## Documentation

### Code Comments
- Use `///` for documentation comments
- Explain *why*, not *what*
- Document public APIs

**Example:**
```swift
/// Calculates the number of days remaining until warranty expiration.
/// 
/// - Returns: Days remaining, or 0 if expired
var daysRemaining: Int {
    let components = Calendar.current.dateComponents([.day], from: Date(), to: warrantyExpirationDate)
    return max(components.day ?? 0, 0)
}
```

### README Updates
Update README.md when:
- Adding major features
- Changing requirements
- Updating installation steps
- Modifying architecture

## Community

### Getting Help
- Check existing [Issues](https://github.com/yourusername/HomeOps/issues)
- Read the [README](README.md)
- Ask in [Discussions](https://github.com/yourusername/HomeOps/discussions)

### Reporting Bugs
Use the bug report template:
- Clear title
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable
- Device and iOS version

### Suggesting Features
Use the feature request template:
- Problem you're solving
- Proposed solution
- Alternatives considered
- Mockups if applicable

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Reach out:
- **Email:** dev@homeops.app
- **GitHub Issues:** For bugs and features
- **GitHub Discussions:** For questions and ideas

---

**Thank you for contributing to HomeOps!** 🎉
