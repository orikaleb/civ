import SwiftUI

struct CivicCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let backgroundColor: Color
    let shadowIntensity: ShadowIntensity
    
    enum ShadowIntensity {
        case light, medium, heavy, premium, floating
        
        var shadowColor: Color {
            switch self {
            case .light:
                return Color.black.opacity(0.05)
            case .medium:
                return Color.black.opacity(0.1)
            case .heavy:
                return Color.black.opacity(0.15)
            case .premium:
                return Color.black.opacity(0.2)
            case .floating:
                return Color.black.opacity(0.25)
            }
        }
        
        var shadowRadius: CGFloat {
            switch self {
            case .light:
                return 4
            case .medium:
                return 8
            case .heavy:
                return 12
            case .premium:
                return 16
            case .floating:
                return 20
            }
        }
        
        var shadowOffset: CGSize {
            switch self {
            case .light:
                return CGSize(width: 0, height: 1)
            case .medium:
                return CGSize(width: 0, height: 2)
            case .heavy:
                return CGSize(width: 0, height: 4)
            case .premium:
                return CGSize(width: 0, height: 6)
            case .floating:
                return CGSize(width: 0, height: 8)
            }
        }
        
        var secondaryShadowColor: Color {
            switch self {
            case .light:
                return Color.black.opacity(0.02)
            case .medium:
                return Color.black.opacity(0.04)
            case .heavy:
                return Color.black.opacity(0.06)
            case .premium:
                return Color.black.opacity(0.08)
            case .floating:
                return Color.black.opacity(0.1)
            }
        }
        
        var secondaryShadowRadius: CGFloat {
            switch self {
            case .light:
                return 2
            case .medium:
                return 4
            case .heavy:
                return 6
            case .premium:
                return 8
            case .floating:
                return 10
            }
        }
        
        var tertiaryShadowColor: Color {
            switch self {
            case .light:
                return Color.black.opacity(0.01)
            case .medium:
                return Color.black.opacity(0.02)
            case .heavy:
                return Color.black.opacity(0.03)
            case .premium:
                return Color.black.opacity(0.04)
            case .floating:
                return Color.black.opacity(0.05)
            }
        }
        
        var tertiaryShadowRadius: CGFloat {
            switch self {
            case .light:
                return 1
            case .medium:
                return 2
            case .heavy:
                return 3
            case .premium:
                return 4
            case .floating:
                return 5
            }
        }
    }
    
    init(padding: CGFloat = 16, backgroundColor: Color = Color(.systemBackground), shadowIntensity: ShadowIntensity = .medium, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
        self.backgroundColor = backgroundColor
        self.shadowIntensity = shadowIntensity
    }
    
    // Convenience initializer for dynamic background
    init(padding: CGFloat = 16, themeMode: ThemeMode, shadowIntensity: ShadowIntensity = .medium, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
        self.backgroundColor = Color.dynamicSecondaryBackground(for: themeMode)
        self.shadowIntensity = shadowIntensity
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(16)
            // Primary shadow (main depth)
            .shadow(
                color: shadowIntensity.shadowColor,
                radius: shadowIntensity.shadowRadius,
                x: shadowIntensity.shadowOffset.width,
                y: shadowIntensity.shadowOffset.height
            )
            // Secondary shadow (ambient depth)
            .shadow(
                color: shadowIntensity.secondaryShadowColor,
                radius: shadowIntensity.secondaryShadowRadius,
                x: 0,
                y: 1
            )
            // Tertiary shadow (soft glow)
            .shadow(
                color: shadowIntensity.tertiaryShadowColor,
                radius: shadowIntensity.tertiaryShadowRadius,
                x: 0,
                y: 0
            )
            // Inner shadow effect with overlay
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.clear,
                                Color.black.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            // Subtle inner highlight
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                    .blendMode(.overlay)
            )
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            CivicCard(shadowIntensity: .light) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Light Shadow")
                        .font(.headline)
                    Text("Subtle shadow for minimal depth.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            
            CivicCard(shadowIntensity: .medium) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Medium Shadow")
                        .font(.headline)
                    Text("Standard shadow for most cards.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            
            CivicCard(shadowIntensity: .heavy) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Heavy Shadow")
                        .font(.headline)
                    Text("Enhanced depth for important cards.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            
            CivicCard(backgroundColor: Color.blue.opacity(0.1), shadowIntensity: .premium) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Premium Shadow")
                        .font(.headline)
                    Spacer()
                }
            }
            
            CivicCard(backgroundColor: Color.purple.opacity(0.1), shadowIntensity: .floating) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.purple)
                    Text("Floating Shadow")
                        .font(.headline)
                    Spacer()
                }
            }
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}







