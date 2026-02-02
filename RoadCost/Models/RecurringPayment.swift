import Foundation

enum PaymentFrequency: String, Codable, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
    
    var icon: String {
        switch self {
        case .daily: return "sun.max"
        case .weekly: return "calendar"
        case .monthly: return "calendar.badge.clock"
        case .yearly: return "calendar.badge.exclamationmark"
        }
    }
    
    func nextDate(from date: Date) -> Date {
        let calendar = Calendar.current
        switch self {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: date) ?? date
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: date) ?? date
        }
    }
}

struct RecurringPayment: Identifiable, Codable, Hashable {
    let id: UUID
    let amount: Double
    let category: ExpenseCategory
    let name: String
    let startDate: Date
    let frequency: PaymentFrequency
    var nextPaymentDate: Date
    var isActive: Bool
    
    init(
        id: UUID = UUID(),
        amount: Double,
        category: ExpenseCategory,
        name: String,
        startDate: Date = Date(),
        frequency: PaymentFrequency,
        isActive: Bool = true
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.name = name
        self.startDate = startDate
        self.frequency = frequency
        self.nextPaymentDate = frequency.nextDate(from: startDate)
        self.isActive = isActive
    }
    
    var formattedAmount: String {
        amount.formattedCurrency
    }
    
    var formattedNextDate: String {
        DateFormatter.shortDate.string(from: nextPaymentDate)
    }
    
    mutating func processPayment() -> Expense {
        let expense = Expense(
            amount: amount,
            category: category,
            date: nextPaymentDate,
            note: "\(name) (Recurring)"
        )
        nextPaymentDate = frequency.nextDate(from: nextPaymentDate)
        return expense
    }
}

extension RecurringPayment {
    static var sampleData: [RecurringPayment] {
        [
            RecurringPayment(amount: 9.99, category: .entertainment, name: "Netflix", frequency: .monthly),
            RecurringPayment(amount: 50, category: .transport, name: "Metro Pass", frequency: .monthly),
            RecurringPayment(amount: 500, category: .other, name: "Rent", frequency: .monthly)
        ]
    }
}
