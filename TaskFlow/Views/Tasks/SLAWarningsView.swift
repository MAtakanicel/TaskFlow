import SwiftUI

struct SLAWarningsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var taskViewModel = TaskViewModel()
    
    var warningTasks: [Task] {
        taskViewModel.tasks.filter { task in
            let slaStatus = taskViewModel.getSLAStatus(for: task)
            return (slaStatus == .warning || slaStatus == .critical || slaStatus == .overdue) && task.status != .completed
        }.sorted { $0.slaDeadline < $1.slaDeadline }
    }
    
    var body: some View {
        Group {
            if warningTasks.isEmpty {
                ContentUnavailableView(
                    "SLA Uyarısı Yok",
                    systemImage: "checkmark.circle.fill",
                    description: Text("Tüm görevleriniz zamanında ilerliyor!")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(warningTasks) { task in
                            NavigationLink(destination: TaskDetailView(task: task)) {
                                SLAWarningCard(
                                    task: task,
                                    slaStatus: taskViewModel.getSLAStatus(for: task)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("SLA Uyarıları")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            taskViewModel.startListening(
                userId: authViewModel.currentUser?.id,
                isAdmin: authViewModel.isAdmin
            )
        }
        .onDisappear {
            taskViewModel.stopListening()
        }
    }
}

struct SLAWarningCard: View {
    let task: Task
    let slaStatus: SLAStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: slaStatus.icon)
                    .font(.title2)
                    .foregroundStyle(slaStatus.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(urgencyText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(slaStatus.color)
                    
                    Text(task.slaDeadline.timeRemaining())
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                StatusBadgeView(status: task.status)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(task.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text(task.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Label(task.assignedToName, systemImage: "person.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Label(task.slaDeadline.formatted(), systemImage: "clock.fill")
                        .font(.caption)
                        .foregroundStyle(slaStatus.color)
                }
            }
        }
        .padding()
        .background(slaStatus.color.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(slaStatus.color, lineWidth: 2)
        )
    }
    
    private var urgencyText: String {
        switch slaStatus {
        case .safe: return "Normal"
        case .warning: return "Dikkat!"
        case .critical: return "Acil!"
        case .overdue: return "Gecikmiş!"
        }
    }
}

#Preview {
    NavigationStack {
        SLAWarningsView()
            .environmentObject(AuthViewModel())
    }
}

