import SwiftUI

struct CivicTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    
    @State private var isSecureVisible = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            // Text field
            Group {
                if isSecure && !isSecureVisible {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .keyboardType(keyboardType)
            .textInputAutocapitalization(autocapitalization)
            .autocorrectionDisabled()
            
            // Show/hide password button
            if isSecure {
                Button(action: {
                    isSecureVisible.toggle()
                }) {
                    Image(systemName: isSecureVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        CivicTextField(placeholder: "Username", text: .constant(""), icon: "person")
        CivicTextField(placeholder: "Email", text: .constant(""), icon: "envelope")
        CivicTextField(placeholder: "Password", text: .constant(""), icon: "lock", isSecure: true)
    }
    .padding()
}
