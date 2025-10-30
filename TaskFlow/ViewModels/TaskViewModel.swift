import Foundation
import FirebaseFirestore
import Combine

@MainActor
class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var selectedTask: Task?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var availableUsers: [User] = []
    
    private var tasksListener: ListenerRegistration?
    
    func startListening(userId: String?, isAdmin: Bool) {
        tasksListener = FirebaseService.shared.listenToTasks(userId: userId, isAdmin: isAdmin) { [weak self] tasks in
            self?.tasks = tasks
        }
    }
    
    func stopListening() {
        tasksListener?.remove()
        tasksListener = nil
    }
    
    func loadUsers() async {
        do {
            availableUsers = try await AuthService.shared.fetchAllUsers()
        } catch {
            errorMessage = "Kullanıcılar yüklenemedi: \(error.localizedDescription)"
        }
    }
    
    func createTask(
        title: String,
        description: String,
        assignedTo: String,
        assignedToName: String,
        createdBy: String,
        createdByName: String,
        slaDeadline: Date
    ) async {
        isLoading = true
        errorMessage = nil
        
        let task = Task(
            title: title,
            description: description,
            assignedTo: assignedTo,
            assignedToName: assignedToName,
            createdBy: createdBy,
            createdByName: createdByName,
            status: .planned,
            slaDeadline: slaDeadline
        )
        
        do {
            try await FirebaseService.shared.createTask(task)
            successMessage = "Görev başarıyla oluşturuldu"
        } catch {
            errorMessage = "Görev oluşturulamadı: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateTask(_ task: Task) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await FirebaseService.shared.updateTask(task)
            successMessage = "Görev güncellendi"
        } catch {
            errorMessage = "Görev güncellenemedi: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateTaskStatus(_ task: Task) async {
        guard let nextStatus = task.status.nextStatus else {
            errorMessage = "Görev zaten tamamlanmış"
            return
        }
        
        var updatedTask = task
        updatedTask.status = nextStatus
        await updateTask(updatedTask)
    }
    
    func deleteTask(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await FirebaseService.shared.deleteTask(id: id)
            successMessage = "Görev silindi"
        } catch {
            errorMessage = "Görev silinemedi: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func getSLAStatus(for task: Task) -> SLAStatus {
        let timeRemaining = task.slaDeadline.timeIntervalSince(Date())
        
        if timeRemaining < 0 {
            return .overdue
        } else if timeRemaining < Constants.slaCriticalThreshold {
            return .critical
        } else if timeRemaining < Constants.slaWarningThreshold {
            return .warning
        } else {
            return .safe
        }
    }
    
    func tasks(byStatus status: TaskStatus) -> [Task] {
        return tasks.filter { $0.status == status }
    }
    
    func upcomingSLATasks() -> [Task] {
        return tasks.filter { task in
            let slaStatus = getSLAStatus(for: task)
            return slaStatus == .warning || slaStatus == .critical
        }.sorted { $0.slaDeadline < $1.slaDeadline }
    }
    
}


