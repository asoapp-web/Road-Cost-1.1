import SwiftUI
import Combine

final class BudgetViewModel: ObservableObject {
    @Published var budget: Budget?
    @Published var monthlyBudgetText: String = ""
    @Published var categoryLimits: [ExpenseCategory: String] = [:]
    @Published var currentMonthSpending: Double = 0
    @Published var categorySpending: [ExpenseCategory: Double] = [:]
    @Published var warnings: [BudgetWarning] = []
    @Published var showSetup = false
    
    private let dataManager: DataManager
    
    init(dataManager: DataManager = DataManager.shared) {
        self.dataManager = dataManager
        loadBudget()
    }
    
    func loadBudget() {
        budget = dataManager.loadBudget()
        
        if let budget = budget {
            monthlyBudgetText = budget.monthlyBudget.map { String(format: "%.2f", $0) } ?? ""
            
            for category in ExpenseCategory.allCases {
                if let limit = budget.getLimit(for: category) {
                    categoryLimits[category] = String(format: "%.2f", limit)
                }
            }
        }
        
        currentMonthSpending = dataManager.getTotalExpensesForCurrentMonth()
        categorySpending = dataManager.getExpensesByCategory(for: Date())
        checkBudgetLimits()
    }
    
    func saveBudget() {
        var newBudget = Budget()
        
        if let monthly = Double(monthlyBudgetText), monthly > 0 {
            newBudget.monthlyBudget = monthly
        }
        
        for (category, limitText) in categoryLimits {
            if let limit = Double(limitText), limit > 0 {
                newBudget.setLimit(for: category, limit: limit)
            }
        }
        
        do {
            try dataManager.saveBudget(newBudget)
            budget = newBudget
            checkBudgetLimits()
        } catch {
            print("Error saving budget: \(error)")
        }
    }
    
    func checkBudgetLimits() {
        warnings = []
        
        // Get alert threshold from settings
        let alertThreshold = UserDefaults.standard.double(forKey: "budgetAlertThreshold")
        let threshold = alertThreshold > 0 ? alertThreshold : 0.75
        
        // Check total budget
        if let monthly = budget?.monthlyBudget, monthly > 0 {
            let progress = currentMonthSpending / monthly
            
            // Check if enabled and threshold reached
            let alertsEnabled = UserDefaults.standard.bool(forKey: "budgetAlertsEnabled")
            if alertsEnabled && progress >= threshold {
                warnings.append(BudgetWarning(
                    category: nil,
                    threshold: progress,
                    currentSpending: currentMonthSpending,
                    limit: monthly
                ))
                
                // Send notification if needed
                if progress >= threshold {
                    NotificationService.shared.scheduleBudgetWarning(
                        percentage: progress,
                        budget: monthly,
                        spent: currentMonthSpending
                    )
                }
            }
        }
        
        // Check category limits
        for category in ExpenseCategory.allCases {
            if let limit = budget?.getLimit(for: category), limit > 0 {
                let spent = categorySpending[category] ?? 0
                let progress = spent / limit
                
                if progress >= 0.75 {
                    warnings.append(BudgetWarning(
                        category: category,
                        threshold: progress,
                        currentSpending: spent,
                        limit: limit
                    ))
                    
                    // Send notification
                    NotificationService.shared.scheduleCategoryLimitWarning(
                        category: category,
                        percentage: progress,
                        limit: limit,
                        spent: spent
                    )
                }
            }
        }
    }
    
    func getProgress() -> Double {
        guard let monthly = budget?.monthlyBudget, monthly > 0 else { return 0 }
        return min(currentMonthSpending / monthly, 1.0)
    }
    
    func getRemaining() -> Double {
        guard let monthly = budget?.monthlyBudget else { return 0 }
        return max(monthly - currentMonthSpending, 0)
    }
    
    func getCategoryProgress(for category: ExpenseCategory) -> Double {
        guard let limit = budget?.getLimit(for: category), limit > 0 else { return 0 }
        let spent = categorySpending[category] ?? 0
        return min(spent / limit, 1.0)
    }
}
