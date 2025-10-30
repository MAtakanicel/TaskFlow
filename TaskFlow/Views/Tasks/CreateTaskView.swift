import SwiftUI

struct CreateTaskView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var taskViewModel: TaskViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedUser: User?
    @State private var slaDeadline = Date().addingTimeInterval(86400) 
    @State private var validationError: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Görev Bilgileri") {
                    TextField("Başlık", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("Açıklama")
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                    }
                }
                
                Section("Atama") {
                    Picker("Sorumlu Kişi", selection: $selectedUser) {
                        Text("Seçiniz").tag(nil as User?)
                        ForEach(taskViewModel.availableUsers) { user in
                            Text(user.displayName).tag(user as User?)
                        }
                    }
                }
                
                Section("SLA") {
                    DatePicker(
                        "Bitiş Tarihi",
                        selection: $slaDeadline,
                        in: Date().addingTimeInterval(86400)...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                
                if let error = validationError {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Yeni Görev")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        saveTask()
                    }
                    .disabled(taskViewModel.isLoading)
                }
            }
            .onAppear {
                _Concurrency.Task {
                    await taskViewModel.loadUsers()
                }
            }
        }
    }
    
    private func saveTask() {
        validationError = nil
        
        guard !title.isEmpty else {
            validationError = "Başlık boş bırakılamaz"
            return
        }
        
        guard !description.isEmpty else {
            validationError = "Açıklama boş bırakılamaz"
            return
        }
        
        guard let selectedUser = selectedUser else {
            validationError = "Sorumlu kişi seçilmelidir"
            return
        }
        
        guard let currentUser = authViewModel.currentUser else {
            validationError = "Kullanıcı bilgisi bulunamadı"
            return
        }
        
        _Concurrency.Task {
            await taskViewModel.createTask(
                title: title,
                description: description,
                assignedTo: selectedUser.id ?? "",
                assignedToName: selectedUser.displayName,
                createdBy: currentUser.id ?? "",
                createdByName: currentUser.displayName,
                slaDeadline: slaDeadline
            )
            
            if taskViewModel.errorMessage == nil {
                dismiss()
            } else {
                validationError = taskViewModel.errorMessage
            }
        }
    }
}

#Preview {
    CreateTaskView()
        .environmentObject(AuthViewModel())
        .environmentObject(TaskViewModel())
}


