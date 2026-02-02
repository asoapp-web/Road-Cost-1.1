import SwiftUI
import Combine

final class SavingsViewModel: ObservableObject {
    @Published var goals: [SavingsGoal] = []
    @Published var totalSavings: Double = 0
    @Published var showAddGoal = false
    @Published var selectedGoal: SavingsGoal?
    
    private let dataManager: DataManager
    
    init(dataManager: DataManager = DataManager.shared) {
        self.dataManager = dataManager
        loadGoals()
    }
    
    func loadGoals() {
        goals = dataManager.loadSavingsGoals()
        totalSavings = dataManager.getTotalSavings()
    }
    
    func addGoal(_ goal: SavingsGoal) {
        do {
            try dataManager.saveSavingsGoal(goal)
            loadGoals()
        } catch {
            print("Error saving goal: \(error)")
        }
    }
    
    func deleteGoal(_ goal: SavingsGoal) {
        do {
            try dataManager.deleteSavingsGoal(goal)
            loadGoals()
        } catch {
            print("Error deleting goal: \(error)")
        }
    }
    
    func deposit(to goal: SavingsGoal, amount: Double, note: String? = nil) {
        do {
            try dataManager.addToSavings(goalId: goal.id, amount: amount, note: note)
            loadGoals()
        } catch {
            print("Error depositing: \(error)")
        }
    }
    
    func withdraw(from goal: SavingsGoal, amount: Double, note: String? = nil) {
        do {
            try dataManager.withdrawFromSavings(goalId: goal.id, amount: amount, note: note)
            loadGoals()
        } catch {
            print("Error withdrawing: \(error)")
        }
    }
    
    func getTransactions(for goal: SavingsGoal) -> [SavingsTransaction] {
        return dataManager.getSavingsTransactions(for: goal.id)
    }
}

// MARK: - Add Goal ViewModel

final class AddSavingsGoalViewModel: ObservableObject {
    @Published var name = ""
    @Published var targetAmount = ""
    @Published var selectedIcon = "banknote.fill"
    @Published var selectedColor = "#F9BF13"
    @Published var hasDeadline = false
    @Published var deadline = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    var isValid: Bool {
        !name.isEmpty && Double(targetAmount) != nil && Double(targetAmount)! > 0
    }
    
    func createGoal() -> SavingsGoal {
        SavingsGoal(
            name: name,
            targetAmount: Double(targetAmount) ?? 0,
            icon: selectedIcon,
            colorHex: selectedColor,
            deadline: hasDeadline ? deadline : nil
        )
    }
    
    func reset() {
        name = ""
        targetAmount = ""
        selectedIcon = "banknote.fill"
        selectedColor = "#F9BF13"
        hasDeadline = false
        deadline = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    }
}
