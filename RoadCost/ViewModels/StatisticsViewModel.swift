import SwiftUI
import Combine

struct CategoryStat: Identifiable {
    let id = UUID()
    let category: ExpenseCategory
    let amount: Double
    let percentage: Double
    var color: Color { category.color }
}

final class StatisticsViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var selectedPeriod: TimePeriod = .all
    @Published var categoryStats: [CategoryStat] = []
    @Published var totalAmount: Double = 0
    
    private let dataManager: DataManager
    
    init(dataManager: DataManager = DataManager.shared) {
        self.dataManager = dataManager
        loadStatistics()
    }
    
    func loadStatistics() {
        let allExpenses = dataManager.loadExpenses()
        
        // Filter by Period
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .day:
            expenses = allExpenses.filter { calendar.isDate($0.date, inSameDayAs: now) }
        case .week:
            let weekStart = calendar.date(byAdding: .day, value: -7, to: now)!
            expenses = allExpenses.filter { $0.date >= weekStart }
        case .month:
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            expenses = allExpenses.filter { $0.date >= monthStart }
        case .all:
            expenses = allExpenses
        }
        
        calculateCategoryStats()
    }
    
    func calculateCategoryStats() {
        totalAmount = expenses.reduce(0) { $0 + $1.amount }
        
        guard totalAmount > 0 else {
            categoryStats = []
            return
        }
        
        let grouped = Dictionary(grouping: expenses, by: { $0.category })
        
        categoryStats = grouped.map { (category, expenses) in
            let amount = expenses.reduce(0) { $0 + $1.amount }
            let percentage = amount / totalAmount
            return CategoryStat(category: category, amount: amount, percentage: percentage)
        }.sorted { $0.amount > $1.amount }
    }
}
