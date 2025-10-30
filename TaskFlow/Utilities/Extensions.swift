import Foundation
import SwiftUI

extension Date {
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: self)
    }
    
    func timeRemaining() -> String {
        let interval = self.timeIntervalSince(Date())
        
        if interval < 0 {
            return "Süre doldu"
        }
        
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 24 {
            let days = hours / 24
            return "\(days) gün kaldı"
        } else if hours > 0 {
            return "\(hours) saat \(minutes) dakika kaldı"
        } else {
            return "\(minutes) dakika kaldı"
        }
    }
}

extension Color {
    static func from(statusColor: String) -> Color {
        switch statusColor {
        case "blue": return .blue
        case "orange": return .orange
        case "purple": return .purple
        case "yellow": return .yellow
        case "green": return .green
        default: return .gray
        }
    }
}


