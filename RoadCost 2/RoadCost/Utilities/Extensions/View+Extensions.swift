import SwiftUI
import UIKit

extension View {
    func glassEffect(cornerRadius: CGFloat = 16) -> some View {
        self.background(GlassBackground(cornerRadius: cornerRadius))
    }
    
    func glassCard(padding: CGFloat = 16, cornerRadius: CGFloat = 16) -> some View {
        GlassCardView(content: self, cornerRadius: cornerRadius, padding: padding)
    }
    
    func animateOnAppear(delay: Double = 0) -> some View {
        self.modifier(AnimateOnAppearModifier(delay: delay))
    }
}

// MARK: - Haptic Feedback

func hapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
}

func hapticNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(type)
}

func hapticSelection() {
    let generator = UISelectionFeedbackGenerator()
    generator.selectionChanged()
}

// MARK: - Animate On Appear Modifier

struct AnimateOnAppearModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay), value: isVisible)
            .onAppear {
                isVisible = true
            }
    }
}

