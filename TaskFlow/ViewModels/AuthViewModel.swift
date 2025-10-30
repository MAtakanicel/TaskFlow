import Foundation
import FirebaseAuth
import Combine


typealias AsyncTask = _Concurrency.Task

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    init() {
        registerAuthStateHandler()
    }
    
    private func registerAuthStateHandler() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            AsyncTask { @MainActor [weak self] in
                guard let self = self else { return }
                
                if let firebaseUser = firebaseUser {
                    do {
                        self.currentUser = try await AuthService.shared.fetchUser(uid: firebaseUser.uid)
                        self.isAuthenticated = true
                    } catch {
                        print("Error fetching user: \(error.localizedDescription)")
                        self.isAuthenticated = false
                    }
                } else {
                    self.currentUser = nil
                    self.isAuthenticated = false
                }
            }
        }
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            currentUser = try await AuthService.shared.signIn(email: email, password: password)
            isAuthenticated = true
        } catch {
            errorMessage = "Giriş başarısız: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signUp(email: String, password: String, displayName: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            currentUser = try await AuthService.shared.signUp(email: email, password: password, displayName: displayName)
            isAuthenticated = true
        } catch {
            errorMessage = "Kayıt başarısız: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try AuthService.shared.signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            errorMessage = "Çıkış başarısız: \(error.localizedDescription)"
        }
    }
    
    var isAdmin: Bool {
        return currentUser?.role == .admin
    }
    
    func updateUserRole(_ newRole: UserRole) async {
        guard let userId = currentUser?.id else {
            errorMessage = "Kullanıcı ID bulunamadı"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await AuthService.shared.updateUserRole(userId: userId, newRole: newRole)
            currentUser = try await AuthService.shared.fetchUser(uid: userId)
        } catch {
            errorMessage = "Rol güncellenemedi: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    deinit {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
}


