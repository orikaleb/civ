import SwiftUI

struct ThemeSettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        List {
            Section {
                ForEach(ThemeMode.allCases, id: \.self) { mode in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            appViewModel.setThemeMode(mode)
                        }
                    }) {
                        HStack {
                            Image(systemName: mode.icon)
                                .foregroundColor(mode == .light ? .orange : mode == .dark ? .purple : .blue)
                                .frame(width: 24)
                            
                            Text(mode.displayName)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if appViewModel.themeMode == mode {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .fontWeight(.semibold)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(appViewModel.themeMode == mode ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: appViewModel.themeMode)
                }
            } header: {
                Text("Appearance")
            } footer: {
                Text("Choose how CivicVoice should appear. System will automatically match your device's appearance.")
            }
            
            Section {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Theme")
                            .font(.headline)
                        
                        Text("Your app is currently using the \(appViewModel.themeMode.displayName.lowercased()) theme.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.dynamicBackground(for: appViewModel.themeMode))
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    ThemeSettingsView()
        .environmentObject(AppViewModel())
}