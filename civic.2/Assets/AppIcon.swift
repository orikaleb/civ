import SwiftUI

// App Icon Generator
struct AppIconGenerator {
    static func generateAppIcon(size: CGFloat = 1024) -> some View {
        AppIconView(size: size, showBackground: true)
    }
}

// App Icon Preview
struct AppIconPreview: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("CivicVoice App Icon")
                .font(.title)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                // Different sizes
                VStack {
                    AppIconGenerator.generateAppIcon(size: 60)
                    Text("60x60")
                        .font(.caption)
                }
                
                VStack {
                    AppIconGenerator.generateAppIcon(size: 120)
                    Text("120x120")
                        .font(.caption)
                }
                
                VStack {
                    AppIconGenerator.generateAppIcon(size: 180)
                    Text("180x180")
                        .font(.caption)
                }
            }
            
            // Large preview
            AppIconGenerator.generateAppIcon(size: 300)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
        .padding()
    }
}

#Preview {
    AppIconPreview()
}
