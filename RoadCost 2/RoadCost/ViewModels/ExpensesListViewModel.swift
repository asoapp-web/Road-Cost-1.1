import SwiftUI
import Combine

final class ExpensesListViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var filteredExpenses: [Expense] = []
    @Published var selectedCategory: ExpenseCategory?
    @Published var selectedPeriod: TimePeriod = .all
    @Published var sortOrder: SortOrder = .dateDescending
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showAddExpense = false
    
    private let dataManager: DataManager
    
    init(dataManager: DataManager = DataManager.shared) {
        self.dataManager = dataManager
        loadExpenses()
    }
    
    func loadExpenses() {
        isLoading = true
        // Process recurring payments first
        processRecurringPayments()
        expenses = dataManager.loadExpenses()
        filterAndSortExpenses()
        isLoading = false
    }
    
    private func processRecurringPayments() {
        let recurringPayments = dataManager.loadRecurringPayments()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        for payment in recurringPayments where payment.isActive {
            let paymentDate = calendar.startOfDay(for: payment.nextPaymentDate)
            
            // If payment date has passed or is today, create expense
            if paymentDate <= today {
                var updatedPayment = payment
                let expense = updatedPayment.processPayment()
                
                do {
                    // Save the expense
                    try dataManager.saveExpense(expense)
                    // Update the recurring payment with new next date
                    try dataManager.updateRecurringPayment(updatedPayment)
                } catch {
                    print("Error processing recurring payment: \(error)")
                }
            }
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        do {
            try dataManager.deleteExpense(expense)
            loadExpenses()
        } catch {
            errorMessage = "Failed to delete expense: \(error.localizedDescription)"
        }
    }
    
    func deleteExpenses(at offsets: IndexSet) {
        for index in offsets {
            let expense = filteredExpenses[index]
            deleteExpense(expense)
        }
    }
    
    func filterAndSortExpenses() {
        var result = expenses
        
        // Filter by category
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // Filter by period
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .day:
            result = result.filter { calendar.isDate($0.date, inSameDayAs: now) }
        case .week:
            if let weekStart = calendar.date(byAdding: .day, value: -7, to: now) {
                result = result.filter { $0.date >= weekStart }
            }
        case .month:
            if let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) {
                result = result.filter { $0.date >= monthStart }
            }
        case .all:
            break
        }
        
        // Sort
        switch sortOrder {
        case .dateDescending:
            result.sort { $0.date > $1.date }
        case .dateAscending:
            result.sort { $0.date < $1.date }
        case .amountDescending:
            result.sort { $0.amount > $1.amount }
        case .amountAscending:
            result.sort { $0.amount < $1.amount }
        }
        
        filteredExpenses = result
    }
    
    func getTotalAmount() -> Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }
    
    func getExpensesByCategory() -> [ExpenseCategory: [Expense]] {
        Dictionary(grouping: filteredExpenses, by: { $0.category })
    }
    
    func clearFilters() {
        selectedCategory = nil
        selectedPeriod = .all
        sortOrder = .dateDescending
        filterAndSortExpenses()
    }
}

// MARK: - Preview

extension ExpensesListViewModel {
    static var preview: ExpensesListViewModel {
        let vm = ExpensesListViewModel()
        vm.expenses = Expense.sampleData
        vm.filteredExpenses = Expense.sampleData
        return vm
    }
}
