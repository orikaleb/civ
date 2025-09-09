import SwiftUI

struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        NavigationView {
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
                
                ScrollView {
                    VStack(spacing: 30) {
                        // App logo and title
                        VStack(spacing: 16) {
                            Image(systemName: "building.columns.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                            
                            Text("CivicVoice")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Your voice in democracy")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.top, 60)
                        
                        // Authentication form
                        CivicCard {
                            VStack(spacing: 24) {
                                // Segmented control for login/signup
                                Picker("Mode", selection: $viewModel.isSignUp) {
                                    Text("Sign In").tag(false)
                                    Text("Sign Up").tag(true)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                
                                // Form fields
                                VStack(spacing: 16) {
                                    if viewModel.isSignUp {
                                        CivicTextField(placeholder: "Username", text: $viewModel.username, icon: "person")
                                    }
                                    
                                    CivicTextField(placeholder: "Email", text: $viewModel.email, icon: "envelope")
                                    CivicTextField(placeholder: "Password", text: $viewModel.password, icon: "lock", isSecure: true)
                                    
                                    if viewModel.isSignUp {
                                        CivicTextField(placeholder: "Confirm Password", text: $viewModel.confirmPassword, icon: "lock", isSecure: true)
                                    }
                                }
                                
                                // Error message
                                if !viewModel.errorMessage.isEmpty {
                                    Text(viewModel.errorMessage)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                }
                                
                                // Submit button
                                CivicButton(
                                    viewModel.isSignUp ? "Create Account" : "Sign In",
                                    isLoading: appViewModel.isLoading
                                ) {
                                    viewModel.submitForm(appViewModel: appViewModel)
                                }
                                
                                // Social login buttons
                                VStack(spacing: 12) {
                                    Text("Or continue with")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    HStack(spacing: 16) {
                                        SocialLoginButton(
                                            title: "Apple",
                                            icon: "applelogo",
                                            color: .black
                                        ) {
                                            // Apple sign in
                                        }
                                        
                                        SocialLoginButton(
                                            title: "Google",
                                            icon: "globe",
                                            color: .red
                                        ) {
                                            // Google sign in
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

class AuthenticationViewModel: ObservableObject {
    @Published var isSignUp = false
    @Published var email = ""
    @Published var username = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage = ""
    
    func submitForm(appViewModel: AppViewModel) {
        // Reset error message
        errorMessage = ""
        
        // Validate form
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all required fields"
            return
        }
        
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        if isSignUp {
            guard !username.isEmpty else {
                errorMessage = "Please enter a username"
                return
            }
            
            guard password == confirmPassword else {
                errorMessage = "Passwords do not match"
                return
            }
            
            guard password.count >= 6 else {
                errorMessage = "Password must be at least 6 characters"
                return
            }
            
            appViewModel.signUp(email: email, username: username, password: password)
        } else {
            appViewModel.signIn(email: email, password: password)
        }
    }
}

struct SocialLoginButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(color)
            .cornerRadius(12)
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AppViewModel())
}







