import Foundation

struct AppData: Codable {
    var expenses: [Expense] = []
    var incomes: [Income] = []
    var budget: Budget?
    var recurringPayments: [RecurringPayment] = []
    var savingsGoals: [SavingsGoal] = []
    var savingsTransactions: [SavingsTransaction] = []
    var customExpenseCategories: [CustomCategory] = []
    var customIncomeCategories: [CustomCategory] = []
    
    static let key = "RoadCostAppData"
}

// MARK: - Custom Category

struct CustomCategory: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    var colorHex: String
    
    init(id: UUID = UUID(), name: String, icon: String, colorHex: String) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
    }
}
