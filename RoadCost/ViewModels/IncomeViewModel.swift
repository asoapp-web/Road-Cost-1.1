import SwiftUI
import Combine

final class IncomeViewModel: ObservableObject {
    @Published var incomes: [Income] = []
    @Published var filteredIncomes: [Income] = []
    @Published var totalIncome: Double = 0
    @Published var balance: Double = 0
    @Published var selectedPeriod: TimePeriod = .all
    @Published var isLoading = false
    @Published var showAddIncome = false
    
    private let dataManager: DataManager
    
    init(dataManager: DataManager = DataManager.shared) {
        self.dataManager = dataManager
        loadIncomes()
    }
    
    func loadIncomes() {
        isLoading = true
        incomes = dataManager.loadIncomes()
        filterIncomes()
        calculateTotals()
        isLoading = false
    }
    
    func filterIncomes() {
        var result = incomes
        
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
        
        filteredIncomes = result.sorted { $0.date > $1.date }
    }
    
    func calculateTotals() {
        totalIncome = filteredIncomes.reduce(0) { $0 + $1.amount }
        balance = dataManager.calculateBalance()
    }
    
    func deleteIncome(_ income: Income) {
        do {
            try dataManager.deleteIncome(income)
            loadIncomes()
        } catch {
            print("Error deleting income: \(error)")
        }
    }
}

// MARK: - Add Income ViewModel

final class AddIncomeViewModel: ObservableObject {
    @Published var amount: String = ""
    @Published var selectedCategory: IncomeCategory = .salary
    @Published var selectedDate: Date = Date()
    @Published var note: String = ""
    @Published var isValid: Bool = false
    
    private let dataManager: DataManager
    var onSave: (() -> Void)?
    
    init(dataManager: DataManager = DataManager.shared) {
        self.dataManager = dataManager
    }
    
    func validateForm() {
        isValid = Double(amount) != nil && !amount.isEmpty && Double(amount)! > 0
    }
    
    func saveIncome() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        
        let income = Income(
            amount: amountValue,
            category: selectedCategory,
            date: selectedDate,
            note: note.isEmpty ? nil : note
        )
        
        do {
            try dataManager.saveIncome(income)
            onSave?()
            resetForm()
        } catch {
            print("Error saving income: \(error)")
        }
    }
    
    func resetForm() {
        amount = ""
        selectedCategory = .salary
        selectedDate = Date()
        note = ""
        isValid = false
    }
}
