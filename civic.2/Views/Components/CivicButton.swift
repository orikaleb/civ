import SwiftUI

struct CivicButton: View {
    let title: String
    let action: () -> Void
    let style: ButtonStyle
    let isLoading: Bool
    
    init(_ title: String, style: ButtonStyle = .primary, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.textColor))
                        .scaleEffect(0.8)
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(style.textColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(style.backgroundColor)
            .cornerRadius(12)
            // Enhanced shadows for buttons
            .shadow(
                color: Color.black.opacity(style == .primary ? 0.15 : 0.08),
                radius: style == .primary ? 8 : 4,
                x: 0,
                y: style == .primary ? 4 : 2
            )
            .shadow(
                color: Color.black.opacity(style == .primary ? 0.08 : 0.04),
                radius: style == .primary ? 4 : 2,
                x: 0,
                y: style == .primary ? 2 : 1
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(style == .primary ? 0.2 : 0.1),
                                Color.clear,
                                Color.black.opacity(style == .primary ? 0.1 : 0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
        }
        .disabled(isLoading)
    }
}

enum ButtonStyle {
    case primary
    case secondary
    case destructive
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return Color.appPrimary
        case .secondary:
            return Color.clear
        case .destructive:
            return Color.red
        }
    }
    
    var textColor: Color {
        switch self {
        case .primary:
            return Color.white
        case .secondary:
            return Color.appPrimary
        case .destructive:
            return Color.white
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CivicButton("Primary Button") {
            print("Primary tapped")
        }
        
        CivicButton("Secondary Button", style: .secondary) {
            print("Secondary tapped")
        }
        
        CivicButton("Loading Button", isLoading: true) {
            print("Loading tapped")
        }
        
        CivicButton("Destructive Button", style: .destructive) {
            print("Destructive tapped")
        }
    }
    .padding()
}
