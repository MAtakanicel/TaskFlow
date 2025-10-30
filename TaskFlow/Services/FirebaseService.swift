import Foundation
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Task Operations
    
    func createTask(_ task: Task) async throws {
        var newTask = task
        newTask.updatedAt = Date()
        
        try db.collection(Constants.tasksCollection)
            .document()
            .setData(from: newTask)
    }
    
    func updateTask(_ task: Task) async throws {
        guard let taskId = task.id else {
            throw NSError(domain: "FirebaseService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Görev ID'si bulunamadı"])
        }
        
        var updatedTask = task
        updatedTask.updatedAt = Date()
        
        try db.collection(Constants.tasksCollection)
            .document(taskId)
            .setData(from: updatedTask)
    }
    
    func deleteTask(id: String) async throws {
        try await db.collection(Constants.tasksCollection)
            .document(id)
            .delete()
    }
    
    func fetchTasks() async throws -> [Task] {
        let snapshot = try await db.collection(Constants.tasksCollection)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            guard var task = try? document.data(as: Task.self) else { return nil }
            task.id = document.documentID
            return task
        }
    }
    
    func fetchUserTasks(userId: String) async throws -> [Task] {
        let snapshot = try await db.collection(Constants.tasksCollection)
            .whereField("assignedTo", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            guard var task = try? document.data(as: Task.self) else { return nil }
            task.id = document.documentID
            return task
        }
    }
    
    // Real-time listener for tasks
    func listenToTasks(userId: String?, isAdmin: Bool, completion: @escaping ([Task]) -> Void) -> ListenerRegistration {
        var query: Query = db.collection(Constants.tasksCollection)
            .order(by: "createdAt", descending: true)
        
        // If not admin, only show assigned tasks
        if !isAdmin, let userId = userId {
            query = query.whereField("assignedTo", isEqualTo: userId)
        }
        
        return query.addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching tasks: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let tasks = documents.compactMap { document -> Task? in
                guard var task = try? document.data(as: Task.self) else { return nil }
                task.id = document.documentID
                return task
            }
            completion(tasks)
        }
    }
}


