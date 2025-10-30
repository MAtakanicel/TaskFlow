import Foundation
import FirebaseFirestore

struct TaskReport: Identifiable, Codable, Hashable {
    var id: String?
    var taskId: String
    var taskTitle: String
    var createdBy: String
    var createdByName: String
    var createdAt: Date
    var pdfData: Data?
    
    enum CodingKeys: String, CodingKey {
        case id
        case taskId
        case taskTitle
        case createdBy
        case createdByName
        case createdAt
    }
    
    init(id: String? = nil, taskId: String, taskTitle: String, createdBy: String, createdByName: String, createdAt: Date = Date(), pdfData: Data? = nil) {
        self.id = id
        self.taskId = taskId
        self.taskTitle = taskTitle
        self.createdBy = createdBy
        self.createdByName = createdByName
        self.createdAt = createdAt
        self.pdfData = pdfData
    }
    

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TaskReport, rhs: TaskReport) -> Bool {
        lhs.id == rhs.id
    }
}

