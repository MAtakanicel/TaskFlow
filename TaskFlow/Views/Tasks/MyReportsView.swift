import SwiftUI
import PDFKit

struct MyReportsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ReportsViewModel()
    @State private var selectedReport: TaskReport?
    @State private var showShareSheet = false
    @State private var reportToDelete: TaskReport?
    
    var body: some View {
        contentView
            .navigationTitle("Raporlarım")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: loadReportsIfNeeded)
            .alert("Rapor Sil", isPresented: isDeleteAlertPresented, actions: deleteAlertActions, message: deleteAlertMessage)
            .alert("Hata", isPresented: isErrorPresented, actions: errorAlertActions, message: errorAlertMessage)
            .sheet(item: $selectedReport) { report in
                if let pdfData = report.pdfData {
                    PDFPreviewView(pdfData: pdfData, title: report.taskTitle)
                }
            }
            .sheet(isPresented: $showShareSheet, content: shareSheet)
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            loadingView
        } else if viewModel.reports.isEmpty {
            emptyStateView
        } else {
            reportListView
        }
    }
    
    private var loadingView: some View {
        ProgressView("Raporlar yükleniyor...")
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            "Rapor Bulunamadı",
            systemImage: "doc.text.fill",
            description: Text("Henüz oluşturulmuş rapor bulunmuyor.")
        )
    }
    
    private var reportListView: some View {
        List {
            ForEach(viewModel.reports) { report in
                reportRow(for: report)
            }
        }
    }
    
    private func reportRow(for report: TaskReport) -> some View {
        Button {
            handleReportTap(report)
        } label: {
            ReportRowView(report: report)
        }
        .buttonStyle(PlainButtonStyle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            deleteButton(for: report)
            shareButton(for: report)
        }
    }
    
    private func deleteButton(for report: TaskReport) -> some View {
        Button(role: .destructive) {
            reportToDelete = report
        } label: {
            Label("Sil", systemImage: "trash")
        }
    }
    
    private func shareButton(for report: TaskReport) -> some View {
        Button {
            handleShareTap(report)
        } label: {
            Label("Paylaş", systemImage: "square.and.arrow.up")
        }
        .tint(.blue)
    }
    
    private func handleReportTap(_ report: TaskReport) {
        selectedReport = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedReport = report
        }
    }
    
    private func handleShareTap(_ report: TaskReport) {
        selectedReport = report
        showShareSheet = true
    }
    
    private var isDeleteAlertPresented: Binding<Bool> {
        Binding(
            get: { reportToDelete != nil },
            set: { if !$0 { reportToDelete = nil } }
        )
    }
    
    private var isErrorPresented: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
    
    @ViewBuilder
    private func deleteAlertActions() -> some View {
        Button("İptal", role: .cancel) {
            reportToDelete = nil
        }
        Button("Sil", role: .destructive) {
            deleteSelectedReport()
        }
    }
    
    private func deleteAlertMessage() -> some View {
        Text("Bu raporu silmek istediğinizden emin misiniz?")
    }
    
    @ViewBuilder
    private func errorAlertActions() -> some View {
        Button("Tamam") {
            viewModel.errorMessage = nil
        }
    }
    
    @ViewBuilder
    private func errorAlertMessage() -> some View {
        if let error = viewModel.errorMessage {
            Text(error)
        }
    }
    
    @ViewBuilder
    private func shareSheet() -> some View {
        if let report = selectedReport, let pdfData = report.pdfData {
            ShareSheet(items: [pdfData])
        }
    }
    
    private func loadReportsIfNeeded() {
        guard let userId = authViewModel.currentUser?.id else { return }
        
        _Concurrency.Task {
            await viewModel.loadReports(userId: userId)
        }
    }
    
    private func deleteSelectedReport() {
        guard let report = reportToDelete else { return }
        
        _Concurrency.Task {
            await viewModel.deleteReport(report)
            reportToDelete = nil
        }
    }
}

struct ReportRowView: View {
    let report: TaskReport
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text.fill")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(report.taskTitle)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(report.createdAt.formatted())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct PDFPreviewView: View {
    let pdfData: Data
    let title: String
    @Environment(\.dismiss) var dismiss
    @State private var showShareSheet = false
    @State private var isLoading = true
    @State private var hasError = false
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        closeButton
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        shareButton
                    }
                }
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(items: [pdfData])
                }
                .onAppear {
                    validatePDFData()
                }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if hasError {
            errorView
        } else {
            VStack(spacing: 0) {
                pdfInfoBar
                pdfViewer
            }
        }
    }
    
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
            
            Text("PDF Yüklenemedi")
                .font(.headline)
            
            Text("PDF dosyası bozuk veya bulunamadı")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var pdfInfoBar: some View {
        HStack {
            Image(systemName: "doc.text.fill")
                .foregroundStyle(.blue)
            
            Text("PDF Önizleme")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(formatFileSize(pdfData.count))
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                .cornerRadius(6)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var pdfViewer: some View {
        PDFKitView(data: pdfData)
            .background(Color(.systemGroupedBackground))
    }
    
    private var closeButton: some View {
        Button("Kapat") {
            dismiss()
        }
    }
    
    private var shareButton: some View {
        Button {
            showShareSheet = true
        } label: {
            Label("Paylaş", systemImage: "square.and.arrow.up")
        }
    }
    
    private func validatePDFData() {
        if pdfData.isEmpty {
            hasError = true
            print("❌ PDF data boş")
            return
        }
        
        if PDFDocument(data: pdfData) == nil {
            hasError = true
            print("❌ PDF document oluşturulamadı")
            return
        }
        
        print("✅ PDF başarıyla yüklendi - \(formatFileSize(pdfData.count))")
        isLoading = false
    }
    
    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

#Preview {
    NavigationStack {
        MyReportsView()
            .environmentObject(AuthViewModel())
    }
}

