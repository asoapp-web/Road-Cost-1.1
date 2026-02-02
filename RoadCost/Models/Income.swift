import Foundation

struct Income: Identifiable, Codable, Hashable {
    let id: UUID
    let amount: Double
    let category: IncomeCategory
    let date: Date
    let note: String?
    
    init(id: UUID = UUID(), amount: Double, category: IncomeCategory, date: Date, note: String? = nil) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
    }
    
    var formattedAmount: String {
        amount.formattedCurrency
    }
    
    var formattedDate: String {
        DateFormatter.shortDate.string(from: date)
    }
}

extension Income {
    static var sampleData: [Income] {
        [
            Income(amount: 5000, category: .salary, date: Date(), note: "Monthly salary"),
            Income(amount: 500, category: .freelance, date: Date().addingTimeInterval(-86400), note: "Design project"),
            Income(amount: 100, category: .gift, date: Date().addingTimeInterval(-172800), note: "Birthday")
        ]
    }
}
