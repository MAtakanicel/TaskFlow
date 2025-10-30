import SwiftUI

struct TaskCardView: View {
    let task: Task
    let slaStatus: SLAStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                StatusBadgeView(status: task.status)
                Spacer()
                Image(systemName: slaStatus.icon)
                    .foregroundStyle(slaStatus.color)
            }
            

            Text(task.title)
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(2)
            

            Text(task.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            Divider()
            

            HStack {
                Label(task.assignedToName, systemImage: "person.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Label(task.slaDeadline.timeRemaining(), systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundStyle(slaStatus.color)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(slaStatus.color.opacity(0.3), lineWidth: 2)
        )
    }
}

#Preview {
    TaskCardView(
        task: Task(
            title: "Test Görevi",
            description: "Bu bir test görevidir",
            assignedTo: "123",
            assignedToName: "Ahmet Yılmaz",
            createdBy: "456",
            createdByName: "Mehmet Demir",
            status: .inProgress,
            slaDeadline: Date().addingTimeInterval(3600 * 5)
        ),
        slaStatus: .warning
    )
    .padding()
}


