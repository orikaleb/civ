import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: appViewModel.themeMode == .dark ? 
                    [Color.darkBackground, Color.darkBackground.opacity(0.8)] :
                    [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        appViewModel.completeOnboarding(interests: [])
                    }
                    .foregroundColor(.white)
                    .padding()
                }
                
                Spacer()
                
                // Page content
                TabView(selection: $viewModel.currentPage) {
                    WelcomeView()
                        .tag(0)
                    
                    FeaturesView()
                        .tag(1)
                    
                    InterestsView(selectedInterests: $viewModel.selectedInterests)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: viewModel.currentPage)
                
                Spacer()
                
                // Enhanced Navigation buttons
                HStack {
                    if viewModel.currentPage > 0 {
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                viewModel.currentPage -= 1
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                    .font(.body)
                                Text("Back")
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    
                    Spacer()
                    
                    // Enhanced Page indicators
                    HStack(spacing: 12) {
                        ForEach(0..<3) { index in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(viewModel.currentPage == index ? Color.white : Color.white.opacity(0.3))
                                .frame(width: viewModel.currentPage == index ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.currentPage)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if viewModel.currentPage == 2 {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                appViewModel.completeOnboarding(interests: viewModel.selectedInterests)
                            }
                        } else {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                viewModel.currentPage += 1
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(viewModel.currentPage == 2 ? "Get Started" : "Next")
                                .font(.body)
                                .fontWeight(.semibold)
                            if viewModel.currentPage < 2 {
                                Image(systemName: "chevron.right")
                                    .font(.body)
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.body)
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        )
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 20)
            }
        }
    }
}

class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var selectedInterests: [String] = []
}

struct WelcomeView: View {
    @State private var animateIcon = false
    @State private var animateText = false
    @State private var animateSubtext = false
    
    var body: some View {
        VStack(spacing: 40) {
            // Animated App Icon
            AnimatedAppIconView(size: 140)
                .scaleEffect(animateIcon ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateIcon)
                .onAppear {
                    animateIcon = true
                }
            
            VStack(spacing: 20) {
                // Main title with animation
                Text("Welcome to")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(animateText ? 1.0 : 0.0)
                    .offset(y: animateText ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: animateText)
                
                Text("CivicVoice")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(animateText ? 1.0 : 0.0)
                    .offset(y: animateText ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: animateText)
                
                // Subtitle with animation
                Text("Your voice matters in shaping the future of our community. Rate, vote, and recommend to make a difference.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(animateSubtext ? 1.0 : 0.0)
                    .offset(y: animateSubtext ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.6), value: animateSubtext)
            }
            
            // Feature highlights
            VStack(spacing: 16) {
                FeatureHighlight(icon: "star.fill", text: "Rate Government Performance")
                FeatureHighlight(icon: "checkmark.circle.fill", text: "Participate in Community Polls")
                FeatureHighlight(icon: "lightbulb.fill", text: "Submit Your Recommendations")
            }
            .opacity(animateSubtext ? 1.0 : 0.0)
            .offset(y: animateSubtext ? 0 : 20)
            .animation(.easeOut(duration: 0.8).delay(0.8), value: animateSubtext)
        }
        .padding()
        .onAppear {
            animateText = true
            animateSubtext = true
        }
    }
}

struct FeatureHighlight: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

struct FeaturesView: View {
    @State private var animateTitle = false
    @State private var animateFeatures = false
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 20) {
                Text("What You Can Do")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(animateTitle ? 1.0 : 0.0)
                    .offset(y: animateTitle ? 0 : 30)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: animateTitle)
                
                Text("Discover the powerful features that put democracy in your hands")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(animateTitle ? 1.0 : 0.0)
                    .offset(y: animateTitle ? 0 : 30)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: animateTitle)
            }
            
            VStack(spacing: 24) {
                EnhancedFeatureRow(
                    icon: "star.fill",
                    title: "Rate Government Performance",
                    description: "Evaluate different aspects of government services",
                    color: .yellow,
                    delay: 0.6
                )
                .opacity(animateFeatures ? 1.0 : 0.0)
                .offset(x: animateFeatures ? 0 : -50)
                .animation(.easeOut(duration: 0.8).delay(0.6), value: animateFeatures)
                
                EnhancedFeatureRow(
                    icon: "checkmark.circle.fill",
                    title: "Participate in Polls",
                    description: "Vote on important community decisions",
                    color: .green,
                    delay: 0.8
                )
                .opacity(animateFeatures ? 1.0 : 0.0)
                .offset(x: animateFeatures ? 0 : 50)
                .animation(.easeOut(duration: 0.8).delay(0.8), value: animateFeatures)
                
                EnhancedFeatureRow(
                    icon: "lightbulb.fill",
                    title: "Submit Recommendations",
                    description: "Share your ideas for improvement",
                    color: .orange,
                    delay: 1.0
                )
                .opacity(animateFeatures ? 1.0 : 0.0)
                .offset(x: animateFeatures ? 0 : -50)
                .animation(.easeOut(duration: 0.8).delay(1.0), value: animateFeatures)
            }
            .padding(.horizontal, 40)
        }
        .padding()
        .onAppear {
            animateTitle = true
            animateFeatures = true
        }
    }
}

struct EnhancedFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let delay: Double
    
    @State private var animateIcon = false
    
    var body: some View {
        HStack(spacing: 20) {
            // Icon with background
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .scaleEffect(animateIcon ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateIcon)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    animateIcon = true
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
    }
}

struct InterestsView: View {
    @Binding var selectedInterests: [String]
    @State private var animateTitle = false
    @State private var animateInterests = false
    
    private let availableInterests = [
        ("Environment", "leaf.fill", Color.green),
        ("Infrastructure", "building.2.fill", Color.blue),
        ("Economy", "chart.line.uptrend.xyaxis", Color.orange),
        ("Security", "shield.fill", Color.red),
        ("Social Welfare", "heart.fill", Color.pink),
        ("Technology", "laptopcomputer", Color.purple),
        ("Transportation", "car.fill", Color.cyan),
        ("Housing", "house.fill", Color.brown),
        ("Culture", "theatermasks.fill", Color.indigo)
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 20) {
                Text("Choose Your Interests")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(animateTitle ? 1.0 : 0.0)
                    .offset(y: animateTitle ? 0 : 30)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: animateTitle)
                
                Text("Select topics that matter most to you. We'll personalize your experience based on your interests.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(animateTitle ? 1.0 : 0.0)
                    .offset(y: animateTitle ? 0 : 30)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: animateTitle)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(Array(availableInterests.enumerated()), id: \.offset) { index, interest in
                    EnhancedInterestChip(
                        title: interest.0,
                        icon: interest.1,
                        color: interest.2,
                        isSelected: selectedInterests.contains(interest.0),
                        delay: Double(index) * 0.1
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if selectedInterests.contains(interest.0) {
                                selectedInterests.removeAll { $0 == interest.0 }
                            } else {
                                selectedInterests.append(interest.0)
                            }
                        }
                    }
                    .opacity(animateInterests ? 1.0 : 0.0)
                    .offset(y: animateInterests ? 0 : 50)
                    .animation(.easeOut(duration: 0.6).delay(0.6 + Double(index) * 0.1), value: animateInterests)
                }
            }
            .padding(.horizontal, 40)
            
            // Selection counter
            if !selectedInterests.isEmpty {
                Text("\(selectedInterests.count) interest\(selectedInterests.count == 1 ? "" : "s") selected")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 10)
                    .opacity(animateInterests ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.8).delay(1.5), value: animateInterests)
            }
        }
        .padding()
        .onAppear {
            animateTitle = true
            animateInterests = true
        }
    }
}

struct EnhancedInterestChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let delay: Double
    let action: () -> Void
    
    @State private var animateIcon = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? color.opacity(0.3) : Color.white.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(isSelected ? color : .white.opacity(0.8))
                        .scaleEffect(animateIcon ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateIcon)
                }
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? color : .white)
                    .multilineTextAlignment(.center)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color.opacity(0.1) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? color.opacity(0.5) : Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                animateIcon = true
            }
        }
    }
}

struct InterestChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .blue : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.white : Color.white.opacity(0.2))
                )
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppViewModel())
}







