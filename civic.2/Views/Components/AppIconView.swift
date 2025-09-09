import SwiftUI

struct AppIconView: View {
    let size: CGFloat
    let showBackground: Bool
    
    init(size: CGFloat = 120, showBackground: Bool = true) {
        self.size = size
        self.showBackground = showBackground
    }
    
    var body: some View {
        ZStack {
            if showBackground {
                // Background with gradient
                RoundedRectangle(cornerRadius: size * 0.22)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue,
                                Color.purple,
                                Color.blue.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            // Main icon - Megaphone representing voice/communication
            Image(systemName: "megaphone.fill")
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
            
            // Decorative elements
            if showBackground {
                // Sound waves
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: size * 0.6 + CGFloat(index * 8), height: size * 0.6 + CGFloat(index * 8))
                        .offset(x: size * 0.15, y: 0)
                }
                
                // Small accent dots
                ForEach(0..<4) { index in
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 4, height: 4)
                        .offset(
                            x: size * 0.3 * cos(Double(index) * .pi / 2),
                            y: size * 0.3 * sin(Double(index) * .pi / 2)
                        )
                }
            }
        }
    }
}

struct AnimatedAppIconView: View {
    let size: CGFloat
    @State private var animate = false
    
    init(size: CGFloat = 120) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            AppIconView(size: size, showBackground: true)
            
            // Animated sound waves
            ForEach(0..<3) { index in
                Circle()
                    .stroke(Color.white.opacity(0.4), lineWidth: 2)
                    .frame(width: size * 0.8 + CGFloat(index * 15), height: size * 0.8 + CGFloat(index * 15))
                    .scaleEffect(animate ? 1.2 : 0.8)
                    .opacity(animate ? 0.0 : 0.6)
                    .animation(
                        .easeInOut(duration: 2.0 + Double(index) * 0.3)
                        .repeatForever(autoreverses: false)
                        .delay(Double(index) * 0.2),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// Preview
#Preview {
    VStack(spacing: 30) {
        AppIconView(size: 120)
        AnimatedAppIconView(size: 120)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
