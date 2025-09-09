//
//  ContentView.swift
//  civic.2
//
//  Created by Caleb Otchere on 15/08/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        Group {
            if appViewModel.isAuthenticated && appViewModel.hasCompletedOnboarding {
                MainTabView()
            } else if appViewModel.isAuthenticated {
                OnboardingView()
            } else {
                AuthenticationView()
            }
        }
        .onAppear {
            setupDevelopmentState()
        }
    }
    
    private func setupDevelopmentState() {
        // Create a mock user for development
        let mockUser = User(
            email: "dev@civicvoice.com",
            username: "Developer",
            fullName: "App Developer",
            bio: "Testing the app interface",
            interests: ["Technology", "Development", "Testing"],
            role: .user,
            isVerified: true,
            isActive: true,
            lastActive: Date()
        )
        
        // Set the app to authenticated state
        appViewModel.currentUser = mockUser
        appViewModel.isAuthenticated = true
        appViewModel.hasCompletedOnboarding = true
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}
