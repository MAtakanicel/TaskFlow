import Foundation

enum TaskStatus: String, Codable, CaseIterable {
    case planned = "Planlandı"
    case todo = "Yapılacak"
    case inProgress = "Çalışmada"
    case review = "Kontrol"
    case completed = "Tamamlandı"
    
    var color: String {
        switch self {
        case .planned: return "blue"
        case .todo: return "orange"
        case .inProgress: return "purple"
        case .review: return "yellow"
        case .completed: return "green"
        }
    }
    
    var nextStatus: TaskStatus? {
        switch self {
        case .planned: return .todo
        case .todo: return .inProgress
        case .inProgress: return .review
        case .review: return .completed
        case .completed: return nil
        }
    }
}


