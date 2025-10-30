import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var taskViewModel = TaskViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hoş Geldiniz")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        
                        if let user = authViewModel.currentUser {
                            Text(user.displayName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        StatCard(
                            title: "Toplam",
                            value: "\(taskViewModel.tasks.count)",
                            icon: "list.bullet",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Tamamlanan",
                            value: "\(completedCount)",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Devam Eden",
                            value: "\(inProgressCount)",
                            icon: "arrow.clockwise.circle.fill",
                            color: .orange
                        )
                        
                        StatCard(
                            title: "SLA Uyarısı",
                            value: "\(slaWarningCount)",
                            icon: "exclamationmark.triangle.fill",
                            color: .red
                        )
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Hızlı İşlemler")
                            .font(.headline)
                            .padding(.horizontal)

                        NavigationLink(destination: MyReportsView()) {
                            QuickActionCard(
                                title: "Raporlarım",
                                icon: "doc.text.fill",
                                color: .green
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: SLAWarningsView()) {
                            QuickActionCard(
                                title: "SLA Uyarıları",
                                icon: "exclamationmark.triangle.fill",
                                color: slaWarningCount > 0 ? .red : .orange
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if authViewModel.isAdmin {
                            NavigationLink(destination: CreateTaskView().environmentObject(taskViewModel)) {
                                QuickActionCard(
                                    title: "Yeni Görev Oluştur",
                                    icon: "plus.circle.fill",
                                    color: .blue
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    if !upcomingSLATasks.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SLA Yaklaşan Görevler")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(upcomingSLATasks.prefix(5)) { task in
                                NavigationLink(destination: TaskDetailView(task: task)) {
                                    TaskCardView(
                                        task: task,
                                        slaStatus: taskViewModel.getSLAStatus(for: task)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    if !recentTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Son Görevler")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(recentTasks.prefix(5)) { task in
                                NavigationLink(destination: TaskDetailView(task: task)) {
                                    TaskCardView(
                                        task: task,
                                        slaStatus: taskViewModel.getSLAStatus(for: task)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
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
    
    private var completedCount: Int {
        taskViewModel.tasks.filter { $0.status == .completed }.count
    }
    
    private var inProgressCount: Int {
        taskViewModel.tasks.filter { $0.status == .inProgress || $0.status == .todo }.count
    }
    
    private var slaWarningCount: Int {
        taskViewModel.tasks.filter { task in
            let status = taskViewModel.getSLAStatus(for: task)
            return status == .warning || status == .critical || status == .overdue
        }.count
    }
    
    private var upcomingSLATasks: [Task] {
        taskViewModel.upcomingSLATasks()
    }
    
    private var recentTasks: [Task] {
        taskViewModel.tasks.filter { $0.status != .completed }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}


