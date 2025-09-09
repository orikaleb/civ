import SwiftUI

extension Color {
    static let primaryColor = Color("PrimaryColor")
    
    // App theme colors
    static let appPrimary = Color("PrimaryColor")
    static let appSecondary = Color("SecondaryColor")
    static let appAccent = Color("AccentColor")
    
    // Dynamic background colors based on theme
    static func dynamicBackground(for themeMode: ThemeMode) -> Color {
        switch themeMode {
        case .light:
            return Color(.systemBackground)
        case .dark:
            return Color.darkBackground
        case .system:
            return Color(.systemBackground)
        }
    }
    
    static func dynamicSecondaryBackground(for themeMode: ThemeMode) -> Color {
        switch themeMode {
        case .light:
            return Color(.secondarySystemBackground)
        case .dark:
            return Color.darkBackground.opacity(0.9)
        case .system:
            return Color(.secondarySystemBackground)
        }
    }
    
    static func dynamicTertiaryBackground(for themeMode: ThemeMode) -> Color {
        switch themeMode {
        case .light:
            return Color(.tertiarySystemBackground)
        case .dark:
            return Color.darkBackground.opacity(0.8)
        case .system:
            return Color(.tertiarySystemBackground)
        }
    }
}
