import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var showError = false
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        VStack {
            // Title
            VStack(spacing: 8) {
                Text("Centurion Boats")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .italic()
                Text("Pure Awesomeness")
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .italic()
                    .foregroundColor(Theme.accent)
            }
            .padding(.top, 100)
            
            VStack(spacing: 15) {
                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .padding(.top, 50)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                Button("Login") {
                    login()
                }
                .foregroundColor(.white)
                .frame(width: 200)
                .padding()
                .background(Theme.accent)
                .cornerRadius(8)
                .padding(.top, 20)
            }
            
            if showError {
                Text("Invalid username or password")
                    .foregroundColor(.red)
                    .padding(.top, 20)
            }
            
            Spacer()
            
            // Watermark
            Text("Courtesy of Collin Jensen")
                .font(.system(size: 12, weight: .light, design: .rounded))
                .italic()
                .foregroundColor(Theme.textSecondary.opacity(0.6))
                .padding(.bottom, 20)
        }
        .background(Theme.background.ignoresSafeArea())
    }
    
    private func login() {
        if username == "CenturionBoats" && password == "Ri245" {
            isAuthenticated = true
        } else {
            showError = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showError = false
            }
        }
    }
}

#Preview {
    LoginView(isAuthenticated: .constant(false))
} 