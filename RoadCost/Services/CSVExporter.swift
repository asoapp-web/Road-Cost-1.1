import Foundation
import UniformTypeIdentifiers

final class CSVExporter {
    
    /// Exports expenses to a CSV file and returns the file URL
    static func exportExpenses(_ expenses: [Expense]) -> URL? {
        let csvContent = generateCSVContent(expenses)
        
        let fileName = "RoadCost_Expenses_\(formattedDate()).csv"
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error writing CSV file: \(error)")
            return nil
        }
    }
    
    /// Generates CSV content from expenses
    static func generateCSVContent(_ expenses: [Expense]) -> String {
        var csv = "Date,Category,Amount,Note\n"
        
        let sortedExpenses = expenses.sorted { $0.date > $1.date }
        
        for expense in sortedExpenses {
            let date = DateFormatter.shortDate.string(from: expense.date)
            let category = expense.category.displayName
            let amount = String(format: "%.2f", expense.amount)
            let note = escapeCSV(expense.note ?? "")
            
            csv += "\(date),\(category),\(amount),\(note)\n"
        }
        
        return csv
    }
    
    /// Escapes special characters in CSV fields
    private static func escapeCSV(_ field: String) -> String {
        var escaped = field
        
        // If field contains comma, newline, or quotes, wrap in quotes
        if escaped.contains(",") || escaped.contains("\n") || escaped.contains("\"") {
            escaped = escaped.replacingOccurrences(of: "\"", with: "\"\"")
            escaped = "\"\(escaped)\""
        }
        
        return escaped
    }
    
    /// Returns formatted date string for file name
    private static func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmm"
        return formatter.string(from: Date())
    }
}

// MARK: - CSV Document for Share Sheet

import SwiftUI

struct CSVDocument: Transferable {
    let content: String
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .commaSeparatedText) { document in
            document.content.data(using: .utf8) ?? Data()
        }
    }
}
