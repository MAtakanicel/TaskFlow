import Foundation
import FirebaseFirestore

class ReportService {
    static let shared = ReportService()
    private let db = Firestore.firestore()
    private let reportsCollection = "reports"
    
    private init() {}
    
    // Save report metadata to Firestore
    func saveReport(_ report: TaskReport) async throws {
        var newReport = report
        newReport.id = UUID().uuidString
        
        try db.collection(reportsCollection)
            .document(newReport.id!)
            .setData(from: newReport)
        
        // PDF data'yı UserDefaults'a kaydet (küçük dosyalar için)
        if let pdfData = report.pdfData {
            UserDefaults.standard.set(pdfData, forKey: "pdf_\(newReport.id!)")
        }
    }
    
    // Fetch user reports
    func fetchUserReports(userId: String) async throws -> [TaskReport] {
        let snapshot = try await db.collection(reportsCollection)
            .whereField("createdBy", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        var reports = snapshot.documents.compactMap { document -> TaskReport? in
            guard var report = try? document.data(as: TaskReport.self) else { return nil }
            report.id = document.documentID
            
            // PDF data'yı UserDefaults'tan çek
            if let pdfData = UserDefaults.standard.data(forKey: "pdf_\(report.id!)") {
                report.pdfData = pdfData
            }
            
            return report
        }
        
        return reports
    }
    
    // Delete report
    func deleteReport(id: String) async throws {
        try await db.collection(reportsCollection)
            .document(id)
            .delete()
        
        // PDF data'yı da sil
        UserDefaults.standard.removeObject(forKey: "pdf_\(id)")
    }
    
    // Get PDF data
    func getPDFData(reportId: String) -> Data? {
        return UserDefaults.standard.data(forKey: "pdf_\(reportId)")
    }
}

