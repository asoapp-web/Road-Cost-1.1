import Foundation

struct Budget: Codable {
    var monthlyBudget: Double?
    var categoryLimits: [String: Double] // ExpenseCategory rawValue -> limit
    var notificationThresholds: [Double] // e.g., [0.5, 0.75, 0.9, 1.0]
    
    init(monthlyBudget: Double? = nil, categoryLimits: [String: Double] = [:], notificationThresholds: [Double] = [0.5, 0.75, 0.9, 1.0]) {
        self.monthlyBudget = monthlyBudget
        self.categoryLimits = categoryLimits
        self.notificationThresholds = notificationThresholds
    }
    
    func getLimit(for category: ExpenseCategory) -> Double? {
        return categoryLimits[category.rawValue]
    }
    
    mutating func setLimit(for category: ExpenseCategory, limit: Double?) {
        if let limit = limit {
            categoryLimits[category.rawValue] = limit
        } else {
            categoryLimits.removeValue(forKey: category.rawValue)
        }
    }
}

// MARK: - Budget Warning

struct BudgetWarning: Identifiable {
    let id = UUID()
    let category: ExpenseCategory?
    let threshold: Double
    let currentSpending: Double
    let limit: Double
    
    var message: String {
        let percent = Int(threshold * 100)
        if let category = category {
            return "You've used \(percent)% of your \(category.displayName) budget"
        } else {
            return "You've used \(percent)% of your monthly budget"
        }
    }
    
    var isOverBudget: Bool {
        currentSpending >= limit
    }
}
