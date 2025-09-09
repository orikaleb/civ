//
//  ContentView.swift
//  civic.2
//
//  Created by Caleb Otchere on 15/08/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showSplash = true
    
    var body: some View {
        Group {
            if !appViewModel.isInitialized {
                // Show loading while AppViewModel initializes
                Color.clear
                    .onAppear {
                        // Ensure initialization is complete
                    }
            } else if showSplash {
                SplashView {
                    showSplash = false
                }
            } else if !appViewModel.hasCompletedOnboarding {
                OnboardingView()
            } else if !appViewModel.isAuthenticated {
                AuthenticationView()
            } else {
                MainTabView()
            }
        }
        .background(Color.dynamicBackground(for: appViewModel.themeMode))
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}
