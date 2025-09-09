//
//  civic_2App.swift
//  civic.2
//
//  Created by Caleb Otchere on 15/08/2025.
//

import SwiftUI

@main
struct civic_2App: App {
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
                .preferredColorScheme(colorScheme)
                .onAppear {
                    // Ensure AppViewModel is properly initialized
                    if !appViewModel.isInitialized {
                        print("Warning: AppViewModel not initialized")
                    }
                }
        }
    }
    
    private var colorScheme: ColorScheme? {
        switch appViewModel.themeMode {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}
