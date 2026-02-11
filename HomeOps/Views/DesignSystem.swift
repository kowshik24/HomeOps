//
//  DesignSystem.swift
//  HomeOps
//
//  Design System - Centralized styling constants
//

import SwiftUI

// MARK: - Colors
struct AppColors {
    // Semantic Colors
    static let primary = Color.accentColor
    static let success = Color.green
    static let warning = Color.orange
    static let danger = Color.red
    
    // Surface Colors
    static let surface = Color(.secondarySystemGroupedBackground)
    static let surfaceVariant = Color(.tertiarySystemGroupedBackground)
    static let background = Color(.systemGroupedBackground)
    
    // Status Colors
    static let statusExpiring = Color.red
    static let statusWarning = Color.orange
    static let statusActive = Color.green
    static let statusExpired = Color.gray
    
    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let warningGradient = LinearGradient(
        colors: [Color.orange, Color.red],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let successGradient = LinearGradient(
        colors: [Color.green.opacity(0.8), Color.green],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Typography
struct AppTypography {
    static let hero = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold)
    static let headline = Font.system(size: 17, weight: .semibold)
    static let body = Font.system(size: 17, weight: .regular)
    static let bodyBold = Font.system(size: 17, weight: .semibold)
    static let callout = Font.system(size: 16, weight: .regular)
    static let subheadline = Font.system(size: 15, weight: .regular)
    static let footnote = Font.system(size: 13, weight: .regular)
    static let caption = Font.system(size: 12, weight: .regular)
    static let caption2 = Font.system(size: 11, weight: .regular)
}

// MARK: - Spacing
struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
struct AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let round: CGFloat = 999
}

// MARK: - Shadows
struct AppShadow {
    static let small: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
        Color.black.opacity(0.1),
        4,
        0,
        2
    )
    
    static let medium: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
        Color.black.opacity(0.15),
        8,
        0,
        4
    )
    
    static let large: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
        Color.black.opacity(0.2),
        16,
        0,
        8
    )
}

// MARK: - Animations
struct AppAnimation {
    static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let easeInOut = Animation.easeInOut(duration: 0.2)
    static let smooth = Animation.easeInOut(duration: 0.3)
    static let quick = Animation.easeInOut(duration: 0.1)
}

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    var elevation: CardElevation = .medium
    
    enum CardElevation {
        case low, medium, high
        
        var shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
            switch self {
            case .low: return AppShadow.small
            case .medium: return AppShadow.medium
            case .high: return AppShadow.large
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(AppRadius.md)
            .shadow(
                color: elevation.shadow.color,
                radius: elevation.shadow.radius,
                x: elevation.shadow.x,
                y: elevation.shadow.y
            )
    }
}

struct GlassStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(AppRadius.md)
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(AppAnimation.quick, value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle(elevation: CardStyle.CardElevation = .medium) -> some View {
        self.modifier(CardStyle(elevation: elevation))
    }
    
    func glassStyle() -> some View {
        self.modifier(GlassStyle())
    }
    
    func pressableButton() -> some View {
        self.buttonStyle(PressableButtonStyle())
    }
}

// MARK: - Reusable Components

struct StatusBadge: View {
    let daysRemaining: Int
    
    private var badgeColor: Color {
        if daysRemaining <= 7 {
            return AppColors.statusExpiring
        } else if daysRemaining <= 30 {
            return AppColors.statusWarning
        } else {
            return AppColors.statusActive
        }
    }
    
    private var badgeText: String {
        if daysRemaining <= 0 {
            return "Expired"
        } else if daysRemaining == 1 {
            return "1 day"
        } else if daysRemaining <= 30 {
            return "\(daysRemaining) days"
        } else {
            return "Active"
        }
    }
    
    var body: some View {
        Text(badgeText)
            .font(AppTypography.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(badgeColor)
            .cornerRadius(AppRadius.sm)
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(AppTypography.title1)
                .fontWeight(.bold)
            
            Text(title)
                .font(AppTypography.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .cardStyle(elevation: .low)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundColor(.secondary.opacity(0.5))
            
            VStack(spacing: AppSpacing.sm) {
                Text(title)
                    .font(AppTypography.title2)
                    .fontWeight(.bold)
                
                Text(message)
                    .font(AppTypography.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(AppTypography.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.md)
                        .background(AppColors.primary)
                        .cornerRadius(AppRadius.md)
                }
                .pressableButton()
            }
        }
        .padding(AppSpacing.xl)
    }
}
