import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // MARK: - App Colors
    
    /// Primary dark background - #222B4A
    static let primaryDark = Color(hex: "#222B4A")
    
    /// Secondary dark - #283152
    static let secondaryDark = Color(hex: "#283152")
    
    /// Tertiary dark - #181F3C
    static let tertiaryDark = Color(hex: "#181F3C")
    
    /// Accent dark - #3F4867
    static let accentDark = Color(hex: "#3F4867")
    
    /// Background dark - #12182E
    static let backgroundDark = Color(hex: "#12182E")
    
    /// Overlay dark with 35% opacity - #181F3C59
    static let overlayDark = Color(hex: "#181F3C").opacity(0.35)
    
    /// Accent yellow with 48% opacity - #F9BF137A
    static let accentYellow = Color(hex: "#F9BF13")
    
    /// Text primary - white
    static let textPrimary = Color.white
}
