import SwiftUI

struct StatusBadgeView: View {
    let status: TaskStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.from(statusColor: status.color).opacity(0.2))
            .foregroundStyle(Color.from(statusColor: status.color))
            .cornerRadius(8)
    }
}

#Preview {
    VStack {
        StatusBadgeView(status: .planned)
        StatusBadgeView(status: .todo)
        StatusBadgeView(status: .inProgress)
        StatusBadgeView(status: .review)
        StatusBadgeView(status: .completed)
    }
}


