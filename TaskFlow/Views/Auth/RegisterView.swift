import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    @State private var validationError: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            

            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("Hesap Oluştur")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            

            VStack(spacing: 15) {
                TextField("Ad Soyad", text: $displayName)
                    .textContentType(.name)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                TextField("E-posta", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                SecureField("Şifre", text: $password)
                    .textContentType(.newPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                SecureField("Şifre Tekrar", text: $confirmPassword)
                    .textContentType(.newPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                if let error = validationError ?? authViewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
                
                Button {
                    if validateForm() {
                        _Concurrency.Task {
                            await authViewModel.signUp(email: email, password: password, displayName: displayName)
                            if authViewModel.isAuthenticated {
                                dismiss()
                            }
                        }
                    }
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Kayıt Ol")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .cornerRadius(10)
                .disabled(authViewModel.isLoading || !isFormValid)
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && !displayName.isEmpty && !confirmPassword.isEmpty
    }
    
    private func validateForm() -> Bool {
        validationError = nil
        
        if displayName.isEmpty {
            validationError = "Ad soyad boş bırakılamaz"
            return false
        }
        
        if email.isEmpty {
            validationError = "E-posta boş bırakılamaz"
            return false
        }
        
        if password.count < 6 {
            validationError = "Şifre en az 6 karakter olmalıdır"
            return false
        }
        
        if password != confirmPassword {
            validationError = "Şifreler eşleşmiyor"
            return false
        }
        
        return true
    }
}

#Preview {
    NavigationStack {
        RegisterView()
            .environmentObject(AuthViewModel())
    }
}


