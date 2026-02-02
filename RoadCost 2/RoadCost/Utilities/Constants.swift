import SwiftUI

enum AppConstants {
    enum UI {
        static let cornerRadius: CGFloat = 16
        static let cardPadding: CGFloat = 16
        static let spacing: CGFloat = 12
        static let animationDuration: Double = 0.3
        static let springResponse: Double = 0.5
        static let springDamping: Double = 0.7
    }
    
    enum Data {
        static let maxNoteLength = 100
        static let defaultCurrency = "USD"
    }
    
    enum Animation {
        static let fadeIn = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let spring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.7)
        static let smooth = SwiftUI.Animation.easeOut(duration: 0.35)
    }
}

enum TimePeriod: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case all = "All Time"
    
    var icon: String {
        switch self {
        case .day: return "sun.max"
        case .week: return "calendar"
        case .month: return "chart.bar.fill"
        case .all: return "infinity"
        }
    }
}

enum SortOrder: String, CaseIterable {
    case dateDescending = "Newest First"
    case dateAscending = "Oldest First"
    case amountDescending = "Highest Amount"
    case amountAscending = "Lowest Amount"
}
