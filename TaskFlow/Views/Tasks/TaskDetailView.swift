import SwiftUI

struct TaskDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var taskViewModel = TaskViewModel()
    @State var task: Task
    @State private var showShareSheet = false
    @State private var pdfData: Data?
    @State private var showDeleteAlert = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                HStack {
                    StatusBadgeView(status: task.status)
                    Spacer()
                    Image(systemName: slaStatus.icon)
                        .font(.title2)
                        .foregroundStyle(slaStatus.color)
                }
                
                Text(task.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Açıklama")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text(task.description)
                        .font(.body)
                }
                
                Divider()
                
            
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(icon: "person.fill", title: "Sorumlu", value: task.assignedToName)
                    DetailRow(icon: "person.badge.plus", title: "Oluşturan", value: task.createdByName)
                    DetailRow(icon: "calendar", title: "Oluşturulma", value: task.createdAt.formatted())
                    DetailRow(icon: "clock.badge.exclamationmark", title: "SLA Bitiş", value: task.slaDeadline.formatted())
                    DetailRow(icon: "hourglass", title: "Kalan Süre", value: task.slaDeadline.timeRemaining(), valueColor: slaStatus.color)
                    
                    if task.status == .completed {
                        DetailRow(icon: "checkmark.circle.fill", title: "Tamamlanma", value: task.updatedAt.formatted())
                    }
                }
                
                Divider()
                
        
                VStack(spacing: 12) {
                   
                    if let nextStatus = task.status.nextStatus {
                        Button {
                            _Concurrency.Task {
                                await taskViewModel.updateTaskStatus(task)
                                if taskViewModel.errorMessage == nil {
                                    task.status = nextStatus
                                    task.updatedAt = Date()
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("Durumu Değiştir: \(nextStatus.rawValue)")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                        }
                    }
                    

                    if task.status == .completed {
                        Button {
                            generatePDF()
                        } label: {
                            HStack {
                                Image(systemName: "doc.fill")
                                Text("PDF Raporu Oluştur")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                        }
                    }
                    

                    if authViewModel.isAdmin {
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Görevi Sil")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .foregroundStyle(.red)
                            .cornerRadius(10)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Görev Sil", isPresented: $showDeleteAlert) {
            Button("İptal", role: .cancel) { }
            Button("Sil", role: .destructive) {
                _Concurrency.Task {
                    if let taskId = task.id {
                        await taskViewModel.deleteTask(id: taskId)
                        if taskViewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                }
            }
        } message: {
            Text("Bu görevi silmek istediğinizden emin misiniz?")
        }
        .alert("Hata", isPresented: .constant(taskViewModel.errorMessage != nil)) {
            Button("Tamam") {
                taskViewModel.errorMessage = nil
            }
        } message: {
            if let error = taskViewModel.errorMessage {
                Text(error)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let pdfData = pdfData {
                ShareSheet(items: [pdfData])
            }
        }
    }
    
    private var slaStatus: SLAStatus {
        taskViewModel.getSLAStatus(for: task)
    }
    
    private func generatePDF() {
        guard let generatedPDF = PDFService.shared.generateTaskPDF(task: task) else { return }
        pdfData = generatedPDF
        
        if let userId = authViewModel.currentUser?.id,
           let userName = authViewModel.currentUser?.displayName {
            let report = TaskReport(
                taskId: task.id ?? "",
                taskTitle: task.title,
                createdBy: userId,
                createdByName: userName,
                pdfData: generatedPDF
            )
            
            _Concurrency.Task {
                try? await ReportService.shared.saveReport(report)
            }
        }
        
        showShareSheet = true
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
                    .foregroundStyle(valueColor)
            }
            
            Spacer()
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        TaskDetailView(
            task: Task(
                title: "Test Görevi",
                description: "Bu bir test görevidir. Detaylı açıklama burada yer alır.",
                assignedTo: "123",
                assignedToName: "Ahmet Yılmaz",
                createdBy: "456",
                createdByName: "Mehmet Demir",
                status: .inProgress,
                slaDeadline: Date().addingTimeInterval(3600 * 5)
            )
        )
        .environmentObject(AuthViewModel())
    }
}


