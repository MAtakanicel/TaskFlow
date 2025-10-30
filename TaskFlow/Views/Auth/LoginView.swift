import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                
                Text("TaskFlow")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Görev Yönetim Sistemi")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                

                VStack(spacing: 15) {
                    TextField("E-posta", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    SecureField("Şifre", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                    
                    Button {
                        _Concurrency.Task {
                            await authViewModel.signIn(email: email, password: password)
                        }
                    } label: {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Giriş Yap")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                    .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
                }
                .padding(.horizontal, 30)
                

                Button {
                    showRegister = true
                } label: {
                    HStack {
                        Text("Hesabınız yok mu?")
                            .foregroundStyle(.secondary)
                        Text("Kayıt Ol")
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                }
                .padding(.top, 10)
                
                Spacer()
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}


