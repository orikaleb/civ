import SwiftUI

struct SplashView: View {
    @State private var animateIcon = false
    @State private var animateText = false
    @State private var animateSubtext = false
    @State private var showContent = false
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue,
                    Color.purple,
                    Color.blue.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Icon
                AnimatedAppIconView(size: 160)
                    .scaleEffect(animateIcon ? 1.0 : 0.5)
                    .opacity(animateIcon ? 1.0 : 0.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: animateIcon)
                
                // App Name
                VStack(spacing: 12) {
                    Text("CivicVoice")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(animateText ? 1.0 : 0.0)
                        .offset(y: animateText ? 0 : 30)
                        .animation(.easeOut(duration: 0.8).delay(0.6), value: animateText)
                    
                    Text("Your Voice Matters")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                        .opacity(animateSubtext ? 1.0 : 0.0)
                        .offset(y: animateSubtext ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.8), value: animateSubtext)
                }
                
                Spacer()
                
                // Loading indicator
                if showContent {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                        
                        Text("Loading...")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .opacity(showContent ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.5).delay(1.0), value: showContent)
                }
                
                Spacer()
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Start icon animation
        animateIcon = true
        
        // Start text animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            animateText = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            animateSubtext = true
        }
        
        // Show loading indicator
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showContent = true
        }
        
        // Complete splash screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                onComplete()
            }
        }
    }
}

// Alternative splash screen with different style
struct MinimalSplashView: View {
    @State private var animate = false
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Minimal app icon
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "megaphone.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.black)
                }
                .scaleEffect(animate ? 1.0 : 0.8)
                .opacity(animate ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animate)
                
                Text("CivicVoice")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(animate ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(0.3), value: animate)
            }
        }
        .onAppear {
            animate = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onComplete()
            }
        }
    }
}

#Preview {
    SplashView {
        print("Splash completed")
    }
}
