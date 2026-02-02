import SwiftUI

enum IncomeCategory: String, Codable, CaseIterable, Identifiable {
    case salary = "salary"
    case freelance = "freelance"
    case gift = "gift"
    case other = "other"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .salary: return "Salary"
        case .freelance: return "Freelance"
        case .gift: return "Gift"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .salary: return "briefcase.fill"
        case .freelance: return "laptopcomputer"
        case .gift: return "gift.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var sfSymbol: Image {
        Image(systemName: icon)
    }
    
    var color: Color {
        switch self {
        case .salary: return Color(hex: "#4ECDC4")
        case .freelance: return Color(hex: "#95E1D3")
        case .gift: return Color(hex: "#F38181")
        case .other: return Color(hex: "#FCBAD3")
        }
    }
}
