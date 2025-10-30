import Foundation
import Combine

@MainActor
class ReportsViewModel: ObservableObject {
    @Published var reports: [TaskReport] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadReports(userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            reports = try await ReportService.shared.fetchUserReports(userId: userId)
        } catch {
            errorMessage = "Raporlar yüklenemedi: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func deleteReport(_ report: TaskReport) async {
        guard let reportId = report.id else { return }
        
        do {
            try await ReportService.shared.deleteReport(id: reportId)
            reports.removeAll { $0.id == reportId }
        } catch {
            errorMessage = "Rapor silinemedi: \(error.localizedDescription)"
        }
    }
}

