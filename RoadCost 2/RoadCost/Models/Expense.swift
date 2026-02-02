import Foundation

struct Expense: Identifiable, Codable, Hashable {
    let id: UUID
    let amount: Double
    let category: ExpenseCategory
    let date: Date
    let note: String?
    let receiptPhotoId: UUID?
    
    init(id: UUID = UUID(), amount: Double, category: ExpenseCategory, date: Date, note: String? = nil, receiptPhotoId: UUID? = nil) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
        self.receiptPhotoId = receiptPhotoId
    }
    
    var hasReceiptPhoto: Bool {
        receiptPhotoId != nil
    }
    
    // Computed properties
    var formattedAmount: String {
        amount.formattedCurrency
    }
    
    var formattedDate: String {
        DateFormatter.shortDate.string(from: date)
    }
}

extension Expense {
    static var sampleData: [Expense] {
        [
            Expense(amount: 25.50, category: .food, date: Date(), note: "Lunch"),
            Expense(amount: 15.00, category: .transport, date: Date().addingTimeInterval(-86400), note: "Taxi"),
            Expense(amount: 89.99, category: .shopping, date: Date().addingTimeInterval(-172800), note: "Groceries"),
            Expense(amount: 45.00, category: .entertainment, date: Date().addingTimeInterval(-300000), note: "Movies")
        ]
    }
}
