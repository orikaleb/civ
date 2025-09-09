import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    private var backgroundColor: Color {
        Color.dynamicBackground(for: appViewModel.themeMode)
    }
    
    private var darkBackgroundColor: Color {
        Color.dynamicBackground(for: appViewModel.themeMode)
    }
    
    var body: some View {
        NavigationStack {
            TabView {
                FeedView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
                GovernmentDashboardView()
                    .tabItem {
                        Image(systemName: "building.columns.fill")
                        Text("Dashboard")
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
                SearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass.circle.fill")
                        Text("Search")
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
                PollsView()
                    .tabItem {
                        Image(systemName: "ballot.box.fill")
                        Text("Polls")
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.circle.fill")
                        Text("Profile")
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
            .accentColor(.blue)
            .background(backgroundColor)
            .safeAreaInset(edge: .bottom) {
                // This ensures content doesn't get hidden behind the tab bar
                Color.clear.frame(height: 0)
            }
            .onAppear {
                updateTabBarAppearance()
            }
            .onChange(of: appViewModel.themeMode) {
                updateTabBarAppearance()
            }
        }
    }
    
    private func updateTabBarAppearance() {
        // Customize tab bar appearance for better visibility
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(darkBackgroundColor)
        
        // Make icons more visible
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemBlue
        
        // Improve text styling
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppViewModel())
}
