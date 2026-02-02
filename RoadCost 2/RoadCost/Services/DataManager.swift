import Foundation

final class DataManager {
    static let shared = DataManager()
    
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // In-memory cache
    private var appData: AppData
    
    private init() {
        if let data = userDefaults.data(forKey: AppData.key),
           let decoded = try? decoder.decode(AppData.self, from: data) {
            self.appData = decoded
        } else {
            self.appData = AppData()
        }
    }
    
    // MARK: - Expenses
    
    func saveExpense(_ expense: Expense) throws {
        appData.expenses.append(expense)
        try saveAppData(appData)
    }
    
    func loadExpenses() -> [Expense] {
        return appData.expenses
    }
    
    func deleteExpense(_ expense: Expense) throws {
        appData.expenses.removeAll { $0.id == expense.id }
        try saveAppData(appData)
    }
    
    func updateExpense(_ expense: Expense) throws {
        if let index = appData.expenses.firstIndex(where: { $0.id == expense.id }) {
            appData.expenses[index] = expense
            try saveAppData(appData)
        }
    }
    
    // MARK: - Incomes
    
    func saveIncome(_ income: Income) throws {
        appData.incomes.append(income)
        try saveAppData(appData)
    }
    
    func loadIncomes() -> [Income] {
        return appData.incomes
    }
    
    func deleteIncome(_ income: Income) throws {
        appData.incomes.removeAll { $0.id == income.id }
        try saveAppData(appData)
    }
    
    func updateIncome(_ income: Income) throws {
        if let index = appData.incomes.firstIndex(where: { $0.id == income.id }) {
            appData.incomes[index] = income
            try saveAppData(appData)
        }
    }
    
    // MARK: - Budget
    
    func saveBudget(_ budget: Budget) throws {
        appData.budget = budget
        try saveAppData(appData)
    }
    
    func loadBudget() -> Budget? {
        return appData.budget
    }
    
    func deleteBudget() throws {
        appData.budget = nil
        try saveAppData(appData)
    }
    
    // MARK: - Recurring Payments
    
    func saveRecurringPayment(_ payment: RecurringPayment) throws {
        appData.recurringPayments.append(payment)
        try saveAppData(appData)
    }
    
    func loadRecurringPayments() -> [RecurringPayment] {
        return appData.recurringPayments
    }
    
    func deleteRecurringPayment(_ payment: RecurringPayment) throws {
        appData.recurringPayments.removeAll { $0.id == payment.id }
        try saveAppData(appData)
    }
    
    func updateRecurringPayment(_ payment: RecurringPayment) throws {
        if let index = appData.recurringPayments.firstIndex(where: { $0.id == payment.id }) {
            appData.recurringPayments[index] = payment
            try saveAppData(appData)
        }
    }
    
    // MARK: - Balance Calculation
    
    func calculateBalance() -> Double {
        let totalIncome = appData.incomes.reduce(0) { $0 + $1.amount }
        let totalExpenses = appData.expenses.reduce(0) { $0 + $1.amount }
        return totalIncome - totalExpenses
    }
    
    func getTotalExpensesForCurrentMonth() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        return appData.expenses
            .filter { $0.date >= monthStart }
            .reduce(0) { $0 + $1.amount }
    }
    
    func getExpensesByCategory(for month: Date? = nil) -> [ExpenseCategory: Double] {
        var expenses = appData.expenses
        
        if let month = month {
            let calendar = Calendar.current
            expenses = expenses.filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) }
        }
        
        var result: [ExpenseCategory: Double] = [:]
        for expense in expenses {
            result[expense.category, default: 0] += expense.amount
        }
        return result
    }
    
    // MARK: - Savings Goals
    
    func saveSavingsGoal(_ goal: SavingsGoal) throws {
        appData.savingsGoals.append(goal)
        try saveAppData(appData)
    }
    
    func loadSavingsGoals() -> [SavingsGoal] {
        return appData.savingsGoals
    }
    
    func deleteSavingsGoal(_ goal: SavingsGoal) throws {
        appData.savingsGoals.removeAll { $0.id == goal.id }
        appData.savingsTransactions.removeAll { $0.goalId == goal.id }
        try saveAppData(appData)
    }
    
    func updateSavingsGoal(_ goal: SavingsGoal) throws {
        if let index = appData.savingsGoals.firstIndex(where: { $0.id == goal.id }) {
            appData.savingsGoals[index] = goal
            try saveAppData(appData)
        }
    }
    
    func addToSavings(goalId: UUID, amount: Double, note: String? = nil) throws {
        guard let index = appData.savingsGoals.firstIndex(where: { $0.id == goalId }) else { return }
        
        appData.savingsGoals[index].currentAmount += amount
        
        let transaction = SavingsTransaction(goalId: goalId, amount: amount, isDeposit: true, note: note)
        appData.savingsTransactions.append(transaction)
        
        try saveAppData(appData)
    }
    
    func withdrawFromSavings(goalId: UUID, amount: Double, note: String? = nil) throws {
        guard let index = appData.savingsGoals.firstIndex(where: { $0.id == goalId }) else { return }
        
        let withdrawAmount = min(amount, appData.savingsGoals[index].currentAmount)
        appData.savingsGoals[index].currentAmount -= withdrawAmount
        
        let transaction = SavingsTransaction(goalId: goalId, amount: withdrawAmount, isDeposit: false, note: note)
        appData.savingsTransactions.append(transaction)
        
        try saveAppData(appData)
    }
    
    func getSavingsTransactions(for goalId: UUID) -> [SavingsTransaction] {
        return appData.savingsTransactions.filter { $0.goalId == goalId }
    }
    
    func loadAllSavingsTransactions() -> [SavingsTransaction] {
        return appData.savingsTransactions
    }
    
    func getTotalSavings() -> Double {
        return appData.savingsGoals.reduce(0) { $0 + $1.currentAmount }
    }
    
    // MARK: - Custom Categories
    
    func saveCustomExpenseCategory(_ category: CustomCategory) throws {
        appData.customExpenseCategories.append(category)
        try saveAppData(appData)
    }
    
    func loadCustomExpenseCategories() -> [CustomCategory] {
        return appData.customExpenseCategories
    }
    
    func deleteCustomExpenseCategory(_ category: CustomCategory) throws {
        appData.customExpenseCategories.removeAll { $0.id == category.id }
        try saveAppData(appData)
    }
    
    // MARK: - Clear All Data
    
    func clearAllData() throws {
        appData.expenses = []
        appData.incomes = []
        appData.budget = nil
        appData.recurringPayments = []
        appData.savingsGoals = []
        appData.savingsTransactions = []
        appData.customExpenseCategories = []
        appData.customIncomeCategories = []
        try saveAppData(appData)
    }
    
    // MARK: - Helpers
    
    private func saveAppData(_ data: AppData) throws {
        let encoded = try encoder.encode(data)
        userDefaults.set(encoded, forKey: AppData.key)
    }
}
