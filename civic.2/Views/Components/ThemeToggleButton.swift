import SwiftUI

struct ThemeToggleButton: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        Button(action: {
            // Cycle through light -> dark -> system
            switch appViewModel.themeMode {
            case .light:
                appViewModel.setThemeMode(.dark)
            case .dark:
                appViewModel.setThemeMode(.system)
            case .system:
                appViewModel.setThemeMode(.light)
            }
        }) {
            Image(systemName: themeIcon)
                .font(.title2)
                .foregroundColor(themeColor)
        }
    }
    
    private var themeIcon: String {
        switch appViewModel.themeMode {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .system:
            return "gear"
        }
    }
    
    private var themeColor: Color {
        switch appViewModel.themeMode {
        case .light:
            return .orange
        case .dark:
            return .purple
        case .system:
            return .blue
        }
    }
}

#Preview {
    ThemeToggleButton()
        .environmentObject(AppViewModel())
}
