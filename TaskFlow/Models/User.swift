import Foundation
import FirebaseFirestore

enum UserRole: String, Codable {
    case admin = "admin"
    case user = "user"
}

struct User: Identifiable, Codable, Hashable {
    var id: String?
    var email: String
    var displayName: String
    var role: UserRole
    var createdAt: Date
    
    init(id: String? = nil, email: String, displayName: String, role: UserRole = .user, createdAt: Date = Date()) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.role = role
        self.createdAt = createdAt
    }
    

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}


