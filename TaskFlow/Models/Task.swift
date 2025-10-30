import Foundation
import FirebaseFirestore

struct Task: Identifiable, Codable {
    var id: String?
    var title: String
    var description: String
    var assignedTo: String // User ID
    var assignedToName: String // User display name
    var createdBy: String // User ID
    var createdByName: String // User display name
    var status: TaskStatus
    var slaDeadline: Date
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String? = nil,
        title: String,
        description: String,
        assignedTo: String,
        assignedToName: String,
        createdBy: String,
        createdByName: String,
        status: TaskStatus = .planned,
        slaDeadline: Date,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.assignedTo = assignedTo
        self.assignedToName = assignedToName
        self.createdBy = createdBy
        self.createdByName = createdByName
        self.status = status
        self.slaDeadline = slaDeadline
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}


