import SwiftUI

struct GlassButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var style: ButtonStyle = .primary
    
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
    }
    
    var body: some View {
        Button(action: {
            hapticFeedback()
            action()
        }) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                Group {
                    if style == .primary {
                        Color.accentYellow
                    } else if style == .destructive {
                        Color.red.opacity(0.8)
                    } else {
                        GlassBackground(cornerRadius: 16)
                    }
                }
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .foregroundStyle(style == .secondary ? .white : .white)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
