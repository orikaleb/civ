import Foundation
import Combine
import SwiftUI

// Local ThemeMode to ensure availability in this target
enum ThemeMode: String, CaseIterable, Codable {
    case light
    case dark
    case system
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
    
    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "gear"
        }
    }
}

class AppViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding = false
    @Published var isLoading = false
    @Published var themeMode: ThemeMode = .system
    @Published var isInitialized = false
    
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Initialize all properties first
        self.currentUser = nil
        self.isAuthenticated = false
        self.hasCompletedOnboarding = false
        self.isLoading = false
        self.themeMode = .system
        self.isInitialized = false
        
        // Load settings synchronously
        loadUserSession()
        loadThemeSettings()
        
        // Mark as initialized
        self.isInitialized = true
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Check if this is an admin login
            let isAdmin = email.contains("admin") || email == "admin@civicvoice.com"
            let userRole: UserRole = isAdmin ? .admin : .user
            
            let user = User(
                email: email,
                username: isAdmin ? "Admin" : "Caleb",
                fullName: isAdmin ? "Administrator" : "Caleb",
                bio: isAdmin ? "System Administrator for CivicVoice platform. Managing user experience and platform operations." : "Passionate about civic engagement and community building. Working to make our democracy more accessible and transparent.",
                interests: isAdmin ? ["Administration", "Platform Management", "User Experience"] : ["Social Justice", "Technology", "Education"],
                followers: ["amina", "kwame", "joel", "sarah"],
                following: ["mohammed", "lucy", "david"],
                role: userRole,
                isVerified: isAdmin,
                isActive: true,
                lastActive: Date()
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            self.isLoading = false
            self.saveUserSession()
        }
    }
    
    func signUp(email: String, username: String, password: String) {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let user = User(
                email: email,
                username: username,
                fullName: "Jane Smith",
                bio: "Community advocate and civic technology enthusiast. Committed to fostering meaningful dialogue and positive change in our society.",
                interests: ["Social Justice", "Technology", "Education"],
                followers: ["caleb", "nana"],
                following: ["civicvoice", "gov_analytics", "dev_updates"],
                role: .user,
                isVerified: false,
                isActive: true,
                lastActive: Date()
            )
            
            self.currentUser = user
            self.isAuthenticated = true
            self.isLoading = false
            self.saveUserSession()
        }
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        userDefaults.removeObject(forKey: "userSession")
    }
    
    func completeOnboarding(interests: [String]) {
        hasCompletedOnboarding = true
        userDefaults.set(true, forKey: "hasCompletedOnboarding")
        
        if var user = currentUser {
            user.interests = interests
            currentUser = user
            saveUserSession()
        }
    }
    
    private func saveUserSession() {
        if let user = currentUser,
           let userData = try? JSONEncoder().encode(user) {
            userDefaults.set(userData, forKey: "userSession")
        }
    }
    
    private func loadUserSession() {
        // Load onboarding status first
        hasCompletedOnboarding = userDefaults.bool(forKey: "hasCompletedOnboarding")
        
        // Load user session if available
        if let userData = userDefaults.data(forKey: "userSession") {
            do {
                let user = try JSONDecoder().decode(User.self, from: userData)
                currentUser = user
                isAuthenticated = true
            } catch {
                print("Error loading user session: \(error)")
                // Clear corrupted data
                userDefaults.removeObject(forKey: "userSession")
                currentUser = nil
                isAuthenticated = false
            }
        }
    }
    
    // MARK: - Theme Management
    
    func setThemeMode(_ mode: ThemeMode) {
        // Immediate UI update
        DispatchQueue.main.async {
            self.themeMode = mode
        }
        // Save to UserDefaults
        userDefaults.set(mode.rawValue, forKey: "themeMode")
    }
    
    private func loadThemeSettings() {
        if let themeModeString = userDefaults.string(forKey: "themeMode"),
           let mode = ThemeMode(rawValue: themeModeString) {
            themeMode = mode
        }
    }
    
    // MARK: - Admin Management
    
    var isCurrentUserAdmin: Bool {
        return currentUser?.isAdmin ?? false
    }
    
    var isCurrentUserModerator: Bool {
        return currentUser?.isModerator ?? false
    }
    
    func currentUserHasPermission(_ permission: AdminPermission) -> Bool {
        return currentUser?.hasPermission(permission) ?? false
    }
    
    func updateUserRole(_ userId: String, newRole: UserRole) {
        // This would typically make an API call to update the user's role
        // For now, we'll just update the current user if it matches
        if currentUser?.id == userId {
            currentUser?.role = newRole
            saveUserSession()
        }
    }
    
    func suspendUser(_ userId: String, reason: String) {
        // This would typically make an API call to suspend the user
        // For now, we'll just update the current user if it matches
        if currentUser?.id == userId {
            currentUser?.isActive = false
            currentUser?.adminNotes = reason
            saveUserSession()
        }
    }
    
    func activateUser(_ userId: String) {
        // This would typically make an API call to activate the user
        // For now, we'll just update the current user if it matches
        if currentUser?.id == userId {
            currentUser?.isActive = true
            currentUser?.adminNotes = nil
            saveUserSession()
        }
    }
}

