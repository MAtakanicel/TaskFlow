import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthService {
    static let shared = AuthService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // Sign in
    func signIn(email: String, password: String) async throws -> User {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return try await fetchUser(uid: authResult.user.uid)
    }
    
    // Sign up
    func signUp(email: String, password: String, displayName: String) async throws -> User {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
        let newUser = User(
            id: authResult.user.uid,
            email: email,
            displayName: displayName,
            role: .user,
            createdAt: Date()
        )
        
        try db.collection(Constants.usersCollection)
            .document(authResult.user.uid)
            .setData(from: newUser)
        
        return newUser
    }
    
    // Sign out
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // Fetch user data from Firestore
    func fetchUser(uid: String) async throws -> User {
        let document = try await db.collection(Constants.usersCollection)
            .document(uid)
            .getDocument()
        
        guard var user = try? document.data(as: User.self) else {
            throw NSError(domain: "AuthService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bulunamadı"])
        }
        
        // Manuel olarak id set et
        user.id = document.documentID
        return user
    }
    
    // Get current user ID
    func getCurrentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    // Fetch all users (for task assignment)
    func fetchAllUsers() async throws -> [User] {
        let snapshot = try await db.collection(Constants.usersCollection).getDocuments()
        return snapshot.documents.compactMap { document in
            guard var user = try? document.data(as: User.self) else { return nil }
            user.id = document.documentID
            return user
        }
    }
    
    // Update user role
    func updateUserRole(userId: String, newRole: UserRole) async throws {
        try await db.collection(Constants.usersCollection)
            .document(userId)
            .updateData(["role": newRole.rawValue])
    }
}


