import Foundation
import SwiftUI

struct SavingsGoal: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var icon: String
    var colorHex: String
    var createdAt: Date
    var deadline: Date?
    
    init(
        id: UUID = UUID(),
        name: String,
        targetAmount: Double,
        currentAmount: Double = 0,
        icon: String = "banknote.fill",
        colorHex: String = "#F9BF13",
        deadline: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.icon = icon
        self.colorHex = colorHex
        self.createdAt = Date()
        self.deadline = deadline
    }
    
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    
    var remaining: Double {
        max(targetAmount - currentAmount, 0)
    }
    
    var isCompleted: Bool {
        currentAmount >= targetAmount
    }
    
    var color: Color {
        Color(hex: colorHex)
    }
    
    var formattedTarget: String {
        targetAmount.formattedCurrency
    }
    
    var formattedCurrent: String {
        currentAmount.formattedCurrency
    }
    
    var formattedRemaining: String {
        remaining.formattedCurrency
    }
    
    var daysRemaining: Int? {
        guard let deadline = deadline else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day ?? 0
        return max(days, 0)
    }
    
    var suggestedDailyAmount: Double? {
        guard let days = daysRemaining, days > 0 else { return nil }
        return remaining / Double(days)
    }
}

// MARK: - Savings Transaction

struct SavingsTransaction: Identifiable, Codable, Hashable {
    let id: UUID
    let goalId: UUID
    let amount: Double
    let date: Date
    let note: String?
    let isDeposit: Bool
    
    init(id: UUID = UUID(), goalId: UUID, amount: Double, isDeposit: Bool = true, note: String? = nil) {
        self.id = id
        self.goalId = goalId
        self.amount = amount
        self.date = Date()
        self.note = note
        self.isDeposit = isDeposit
    }
}

// MARK: - Preset Icons & Colors

extension SavingsGoal {
    static let presetIcons = [
        "banknote.fill",
        "house.fill",
        "car.fill",
        "airplane",
        "gift.fill",
        "gamecontroller.fill",
        "laptopcomputer",
        "iphone",
        "heart.fill",
        "graduationcap.fill",
        "figure.walk",
        "bicycle",
        "camera.fill",
        "music.note",
        "pawprint.fill"
    ]
    
    static let presetColors = [
        "#F9BF13", // Yellow
        "#4ECDC4", // Teal
        "#FF6B6B", // Red
        "#95E1D3", // Mint
        "#F38181", // Coral
        "#A8E6CF", // Green
        "#DDA0DD", // Plum
        "#87CEEB", // Sky Blue
        "#FFB347", // Orange
        "#B19CD9"  // Lavender
    ]
}

extension SavingsGoal {
    static var sampleData: [SavingsGoal] {
        [
            SavingsGoal(name: "New iPhone", targetAmount: 1200, currentAmount: 450, icon: "iphone", colorHex: "#4ECDC4"),
            SavingsGoal(name: "Vacation", targetAmount: 3000, currentAmount: 1200, icon: "airplane", colorHex: "#F38181", deadline: Calendar.current.date(byAdding: .month, value: 3, to: Date())),
            SavingsGoal(name: "Emergency Fund", targetAmount: 5000, currentAmount: 2500, icon: "shield.fill", colorHex: "#95E1D3")
        ]
    }
}
