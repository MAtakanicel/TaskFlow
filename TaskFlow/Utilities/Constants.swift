import Foundation
import SwiftUI

struct Constants {

    static let usersCollection = "users"
    static let tasksCollection = "tasks"
    

    static let themeKey = "app_theme"
    

    static let slaWarningThreshold: TimeInterval = 24 * 3600 // 24 hours
    static let slaCriticalThreshold: TimeInterval = 6 * 3600 // 6 hours
}

enum SLAStatus {
    case safe
    case warning
    case critical
    case overdue
    
    var color: Color {
        switch self {
        case .safe: return .green
        case .warning: return .yellow
        case .critical: return .orange
        case .overdue: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .safe: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .critical: return "exclamationmark.triangle.fill"
        case .overdue: return "xmark.circle.fill"
        }
    }
}


