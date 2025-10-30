import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = .systemGroupedBackground
        
        if let document = PDFDocument(data: data) {
            pdfView.document = document
            print("✅ PDFKitView: PDF document yüklendi - \(document.pageCount) sayfa")
        } else {
            print("❌ PDFKitView: PDF document oluşturulamadı - Data size: \(data.count) bytes")
        }
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        if pdfView.document == nil {
            if let document = PDFDocument(data: data) {
                pdfView.document = document
                print("✅ PDFKitView updateUIView: PDF document güncellendi")
            }
        }
    }
}

