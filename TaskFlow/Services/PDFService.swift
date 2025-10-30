import Foundation
import PDFKit
import UIKit

class PDFService {
    static let shared = PDFService()
    
    private init() {}
    
    func generateTaskPDF(task: Task) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "TaskFlow App",
            kCGPDFContextAuthor: task.createdByName,
            kCGPDFContextTitle: "Görev Raporu - \(task.title)"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 size in points
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = 50
            let leftMargin: CGFloat = 50
            let rightMargin: CGFloat = 545
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            let titleText = "Görev Raporu"
            titleText.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: titleAttributes)
            yPosition += 40
            
            // Divider
            let dividerPath = UIBezierPath()
            dividerPath.move(to: CGPoint(x: leftMargin, y: yPosition))
            dividerPath.addLine(to: CGPoint(x: rightMargin, y: yPosition))
            UIColor.lightGray.setStroke()
            dividerPath.lineWidth = 1
            dividerPath.stroke()
            yPosition += 30
            
            // Task details
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.darkGray
            ]
            
            // Title
            "Görev Başlığı:".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: headerAttributes)
            yPosition += 20
            task.title.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: bodyAttributes)
            yPosition += 30
            
            // Description
            "Açıklama:".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: headerAttributes)
            yPosition += 20
            let descriptionRect = CGRect(x: leftMargin, y: yPosition, width: rightMargin - leftMargin, height: 200)
            task.description.draw(in: descriptionRect, withAttributes: bodyAttributes)
            yPosition += 100
            
            // Status
            "Durum:".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: headerAttributes)
            yPosition += 20
            task.status.rawValue.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: bodyAttributes)
            yPosition += 30
            
            // Assigned to
            "Sorumlu:".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: headerAttributes)
            yPosition += 20
            task.assignedToName.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: bodyAttributes)
            yPosition += 30
            
            // Created by
            "Oluşturan:".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: headerAttributes)
            yPosition += 20
            task.createdByName.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: bodyAttributes)
            yPosition += 30
            
            // Created date
            "Oluşturulma Tarihi:".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: headerAttributes)
            yPosition += 20
            task.createdAt.formatted().draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: bodyAttributes)
            yPosition += 30
            
            // SLA deadline
            "SLA Bitiş Tarihi:".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: headerAttributes)
            yPosition += 20
            task.slaDeadline.formatted().draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: bodyAttributes)
            yPosition += 30
            
            // Completed date (if completed)
            if task.status == .completed {
                "Tamamlanma Tarihi:".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: headerAttributes)
                yPosition += 20
                task.updatedAt.formatted().draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: bodyAttributes)
                yPosition += 30
            }
            
            // Footer
            yPosition = 800
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.gray
            ]
            let footerText = "TaskFlow - \(Date().formatted())"
            footerText.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: footerAttributes)
        }
        
        return data
    }
}


