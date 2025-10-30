import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var taskViewModel = TaskViewModel()
    @State private var showCreateTask = false
    @State private var selectedStatus: TaskStatus?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FilterChip(title: "Tümü", isSelected: selectedStatus == nil) {
                            selectedStatus = nil
                        }
                        
                        ForEach(TaskStatus.allCases, id: \.self) { status in
                            FilterChip(title: status.rawValue, isSelected: selectedStatus == status) {
                                selectedStatus = status
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .background(Color(.systemBackground))
                
                Divider()
                

                if filteredTasks.isEmpty {
                    ContentUnavailableView(
                        "Görev Bulunamadı",
                        systemImage: "tray.fill",
                        description: Text("Henüz görev bulunmuyor.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredTasks) { task in
                                NavigationLink(destination: TaskDetailView(task: task)) {
                                    TaskCardView(
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
            .navigationTitle("Görevler")
            .toolbar {
                if authViewModel.isAdmin {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showCreateTask = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                }
            }
            .sheet(isPresented: $showCreateTask) {
                CreateTaskView()
                    .environmentObject(taskViewModel)
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
    
    private var filteredTasks: [Task] {
        if let status = selectedStatus {
            return taskViewModel.tasks(byStatus: status)
        }
        return taskViewModel.tasks
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundStyle(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

#Preview {
    TaskListView()
        .environmentObject(AuthViewModel())
}


