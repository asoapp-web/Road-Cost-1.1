import SwiftUI

enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    case food = "food"
    case transport = "transport"
    case entertainment = "entertainment"
    case shopping = "shopping"
    case health = "health"
    case bills = "bills"
    case education = "education"
    case travel = "travel"
    case other = "other"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .food: return "Food"
        case .transport: return "Transport"
        case .entertainment: return "Entertainment"
        case .shopping: return "Shopping"
        case .health: return "Health"
        case .bills: return "Bills"
        case .education: return "Education"
        case .travel: return "Travel"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .entertainment: return "tv.fill"
        case .shopping: return "bag.fill"
        case .health: return "heart.fill"
        case .bills: return "doc.text.fill"
        case .education: return "graduationcap.fill"
        case .travel: return "airplane"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var sfSymbol: Image {
        Image(systemName: icon)
    }
    
    var color: Color {
        switch self {
        case .food: return Color(hex: "#FF6B6B")
        case .transport: return Color(hex: "#4ECDC4")
        case .entertainment: return Color(hex: "#95E1D3")
        case .shopping: return Color(hex: "#F38181")
        case .health: return Color(hex: "#AA96DA")
        case .bills: return Color(hex: "#A8E6CF")
        case .education: return Color(hex: "#87CEEB")
        case .travel: return Color(hex: "#FFB347")
        case .other: return Color(hex: "#FCBAD3")
        }
    }
    
    static let availableIcons = [
        "fork.knife", "car.fill", "tv.fill", "bag.fill", "heart.fill",
        "doc.text.fill", "graduationcap.fill", "airplane", "ellipsis.circle.fill",
        "house.fill", "gift.fill", "gamecontroller.fill", "book.fill",
        "pawprint.fill", "music.note", "camera.fill", "bicycle",
        "figure.walk", "cup.and.saucer.fill", "wineglass.fill"
    ]
    
    static let availableColors = [
        "#FF6B6B", "#4ECDC4", "#95E1D3", "#F38181", "#AA96DA",
        "#FCBAD3", "#A8E6CF", "#87CEEB", "#FFB347", "#B19CD9"
    ]
}
