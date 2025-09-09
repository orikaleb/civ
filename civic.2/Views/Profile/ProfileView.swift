import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showingSettings = false
    @State private var showingNewPost = false
    @State private var isRefreshing = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                if appViewModel.isLoading {
                    // Professional loading state
                    VStack(spacing: 24) {
                        Spacer()
                        
                        // Animated loading indicator
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(Color.appPrimary)
                        
                        Text("Loading Profile...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: appViewModel.isLoading)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 32)
                } else if let user = appViewModel.currentUser {
                    // Profile content
                    ProfileHeader(user: user)
                    StatsSection(user: user)
                    QuickActionsSection()
                    RecentActivitySection()
                    SettingsSection()
                    
                    // Admin Panel (only for admin users)
                    if user.isAdmin {
                        AdminPanelSection(user: user)
                    }
                } else {
                    // Professional empty state
                    VStack(spacing: 24) {
                        Spacer()
                        
                        // Professional empty state icon
                        ZStack {
                            Circle()
                                .fill(Color.appPrimary.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color.appPrimary)
                        }
                        
                        VStack(spacing: 12) {
                            Text("Welcome to CivicVoice")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Sign in to access your profile and start engaging with your community")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                        }
                        
                        // Professional sign in button
                        Button(action: {
                            // This will be handled by the parent view
                        }) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("Get Started")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Color.appPrimary)
                            .cornerRadius(25)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 32)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .background(Color.dynamicBackground(for: appViewModel.themeMode))
        .refreshable {
            await refreshProfile()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: {
                        showingNewPost = true
                    }) {
                        Image(systemName: "plus.app.fill")
                            .foregroundColor(Color.appPrimary)
                            .font(.title3)
                    }
                    .accessibilityLabel("Create new post")
                    
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(Color.appPrimary)
                            .font(.title3)
                    }
                    .accessibilityLabel("Settings")
                }
            }
        }
        .navigationDestination(isPresented: $showingSettings) {
            SettingsView()
        }
        .navigationDestination(isPresented: $showingNewPost) {
            NewPostView { content, postType, images, poll, performanceRef in
                // Handle new post creation
                showingNewPost = false
            }
        }
    }
    
    @MainActor
    private func refreshProfile() async {
        isRefreshing = true
        // Simulate refresh delay for better UX
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        isRefreshing = false
    }
}

struct ProfileHeader: View {
    @EnvironmentObject var appViewModel: AppViewModel
    let user: User
    
    var body: some View {
        CivicCard(themeMode: appViewModel.themeMode, shadowIntensity: .premium) {
            VStack(spacing: 20) {
                // Professional profile image with role indicator
                ZStack(alignment: .bottomTrailing) {
                    // Main profile image
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary.opacity(0.2), Color.appPrimary.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 50))
                                .foregroundColor(Color.appPrimary)
                        )
                    
                    // Role indicator badge
                    if user.isAdmin {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.dynamicBackground(for: appViewModel.themeMode), lineWidth: 2)
                            )
                    } else if user.isVerified {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.dynamicBackground(for: appViewModel.themeMode), lineWidth: 2)
                            )
                    }
                }
                
                // User info with professional typography
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Text(user.fullName.isEmpty ? user.username : user.fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if user.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                        }
                    }
                    
                    Text("@\(user.username)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Member since \(user.joinDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Professional bio section
                if !user.bio.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(user.bio)
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Professional interests section
                if !user.interests.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Interests")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(user.interests, id: \.self) { interest in
                                HStack {
                                    Image(systemName: "tag.fill")
                                        .font(.caption)
                                        .foregroundColor(Color.appPrimary)
                                    
                                    Text(interest)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(Color.appPrimary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.appPrimary.opacity(0.1))
                                .cornerRadius(16)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

struct StatsSection: View {
    @EnvironmentObject var appViewModel: AppViewModel
    let user: User
    
    var body: some View {
        CivicCard(themeMode: appViewModel.themeMode, shadowIntensity: .medium) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(Color.appPrimary)
                        .font(.title3)
                    
                    Text("Your Activity")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                HStack(spacing: 16) {
                    StatItem(
                        icon: "hand.thumbsup.fill",
                        title: "Votes",
                        value: "\(user.totalVotes)",
                        color: .green,
                        themeMode: appViewModel.themeMode
                    )
                    
                    StatItem(
                        icon: "star.fill",
                        title: "Ratings",
                        value: "\(user.totalRatings)",
                        color: .orange,
                        themeMode: appViewModel.themeMode
                    )
                    
                    StatItem(
                        icon: "lightbulb.fill",
                        title: "Ideas",
                        value: "\(user.totalRecommendations)",
                        color: .purple,
                        themeMode: appViewModel.themeMode
                    )
                }
            }
        }
    }
}

struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let themeMode: ThemeMode
    
    var body: some View {
        VStack(spacing: 12) {
            // Professional icon with background
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.dynamicTertiaryBackground(for: themeMode))
        )
    }
}

struct QuickActionsSection: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        CivicCard(themeMode: appViewModel.themeMode, shadowIntensity: .medium) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(Color.appPrimary)
                        .font(.title3)
                    
                    Text("Quick Actions")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                VStack(spacing: 12) {
                    QuickActionRow(
                        icon: "plus.circle.fill",
                        title: "Submit Recommendation",
                        subtitle: "Share your ideas with the community",
                        color: Color.appPrimary,
                        themeMode: appViewModel.themeMode
                    ) {
                        // Navigate to new recommendation
                    }
                    
                    QuickActionRow(
                        icon: "star.circle.fill",
                        title: "Rate Government",
                        subtitle: "Evaluate current performance",
                        color: .orange,
                        themeMode: appViewModel.themeMode
                    ) {
                        // Navigate to rating
                    }
                    
                    QuickActionRow(
                        icon: "hand.raised.fill",
                        title: "View Active Polls",
                        subtitle: "Participate in community decisions",
                        color: .green,
                        themeMode: appViewModel.themeMode
                    ) {
                        // Navigate to polls
                    }
                }
            }
        }
    }
}

struct QuickActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let themeMode: ThemeMode
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Professional icon with background
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.dynamicTertiaryBackground(for: themeMode))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecentActivitySection: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        CivicCard(themeMode: appViewModel.themeMode) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Recent Activity")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button("See All") {
                        // Navigate to full activity
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                
                VStack(spacing: 12) {
                    ActivityRow(
                        icon: "vote.yea",
                        title: "Voted on Infrastructure Poll",
                        time: "2 hours ago",
                        color: .green
                    )
                    
                    ActivityRow(
                        icon: "star.fill",
                        title: "Rated Economy 4.2/5",
                        time: "1 day ago",
                        color: .orange
                    )
                    
                    ActivityRow(
                        icon: "lightbulb.fill",
                        title: "Submitted Infrastructure Idea",
                        time: "3 days ago",
                        color: .purple
                    )
                }
            }
        }
    }
}

struct ActivityRow: View {
    let icon: String
    let title: String
    let time: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct SettingsSection: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        CivicCard(themeMode: appViewModel.themeMode) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Account")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                VStack(spacing: 12) {
                    SettingsRow(
                        icon: "person.circle",
                        title: "Edit Profile",
                        color: .blue
                    ) {
                        // Edit profile
                    }
                    
                    SettingsRow(
                        icon: "bell",
                        title: "Notifications",
                        color: .orange
                    ) {
                        // Notifications settings
                    }
                    
                    SettingsRow(
                        icon: "lock",
                        title: "Privacy",
                        color: .green
                    ) {
                        // Privacy settings
                    }
                    
                    SettingsRow(
                        icon: "arrow.right.square",
                        title: "Sign Out",
                        color: .red
                    ) {
                        appViewModel.signOut()
                    }
                }
            }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showingThemeSettings = false
    
    var body: some View {
            List {
                Section("Account") {
                    Text("Edit Profile")
                    Text("Change Password")
                    Text("Privacy Settings")
                }
            
            Section("Appearance") {
                Button(action: {
                    showingThemeSettings = true
                }) {
                    HStack {
                        Image(systemName: appViewModel.themeMode.icon)
                            .foregroundColor(appViewModel.themeMode == .light ? .orange : appViewModel.themeMode == .dark ? .purple : .blue)
                            .frame(width: 24)
                        
                        Text("Theme")
                        
                        Spacer()
                        
                        Text(appViewModel.themeMode.displayName)
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                }
                
                Section("Notifications") {
                    Text("Push Notifications")
                    Text("Email Notifications")
                    Text("Poll Reminders")
                }
                
                Section("App") {
                    Text("About CivicVoice")
                    Text("Terms of Service")
                    Text("Privacy Policy")
                    Text("Version 1.0.0")
                }
            }
        .scrollContentBackground(.hidden)
        .background(Color.dynamicBackground(for: appViewModel.themeMode))
            .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(isPresented: $showingThemeSettings) {
            ThemeSettingsView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        }
    }
}


// MARK: - Admin Panel Section

struct AdminPanelSection: View {
    @EnvironmentObject var appViewModel: AppViewModel
    let user: User
    @State private var showingAdminDashboard = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "shield.fill")
                    .font(.title2)
                    .foregroundColor(user.roleColor)
                
                Text("Administrative Panel")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    showingAdminDashboard = true
                }) {
                    Text("Manage")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(user.roleColor)
                        .cornerRadius(8)
                }
            }
            
            // Admin permissions
            VStack(alignment: .leading, spacing: 8) {
                Text("Permissions")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(user.role.permissions, id: \.self) { permission in
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Text(permission.displayName)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
            }
            
            // Quick admin actions
            VStack(alignment: .leading, spacing: 8) {
                Text("Quick Actions")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    AdminQuickAction(
                        icon: "person.3.fill",
                        title: "Users",
                        color: .blue
                    ) {
                        // Navigate to user management
                    }
                    
                    AdminQuickAction(
                        icon: "flag.fill",
                        title: "Reports",
                        color: .orange
                    ) {
                        // Navigate to reports
                    }
                    
                    AdminQuickAction(
                        icon: "chart.bar.fill",
                        title: "Analytics",
                        color: .green
                    ) {
                        // Navigate to analytics
                    }
                    
                    AdminQuickAction(
                        icon: "gear",
                        title: "Settings",
                        color: .purple
                    ) {
                        // Navigate to settings
                    }
                }
            }
        }
        .padding(16)
        .background(Color.dynamicSecondaryBackground(for: appViewModel.themeMode))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(user.roleColor.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 16)
        .sheet(isPresented: $showingAdminDashboard) {
            AdminDashboardView()
                .environmentObject(appViewModel)
        }
    }
}

struct AdminQuickAction: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Admin Dashboard View

struct AdminDashboardView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Administrative Dashboard")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Manage CivicVoice platform")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Admin features grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    AdminFeatureCard(
                        icon: "person.3.fill",
                        title: "User Management",
                        description: "Manage users and roles",
                        color: .blue
                    ) {
                        // Navigate to user management
                    }
                    
                    AdminFeatureCard(
                        icon: "flag.fill",
                        title: "Content Moderation",
                        description: "Review and moderate content",
                        color: .orange
                    ) {
                        // Navigate to content moderation
                    }
                    
                    AdminFeatureCard(
                        icon: "chart.bar.fill",
                        title: "Analytics",
                        description: "View platform analytics",
                        color: .green
                    ) {
                        // Navigate to analytics
                    }
                    
                    AdminFeatureCard(
                        icon: "gear",
                        title: "System Settings",
                        description: "Configure platform settings",
                        color: .purple
                    ) {
                        // Navigate to settings
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .background(Color.dynamicBackground(for: appViewModel.themeMode))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AdminFeatureCard: View {
    @EnvironmentObject var appViewModel: AppViewModel
    let icon: String
    let title: String
    let description: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(color)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.dynamicSecondaryBackground(for: appViewModel.themeMode))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


#Preview {
    ProfileView()
        .environmentObject(AppViewModel())
}
