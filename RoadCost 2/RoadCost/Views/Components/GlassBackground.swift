import SwiftUI
import UIKit

struct GlassBackground: UIViewRepresentable {
    let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat = 16) {
        self.cornerRadius = cornerRadius
    }
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        // Blur effect
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        // Overlay view for additional tinting
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor(Color(hex: "#181F3C")).withAlphaComponent(0.35)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(blurView)
        containerView.addSubview(overlayView)
        
        // Constraints
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: containerView.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            overlayView.topAnchor.constraint(equalTo: containerView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // Corner radius
        containerView.layer.cornerRadius = cornerRadius
        containerView.layer.masksToBounds = true
        
        // Border
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.layer.cornerRadius = cornerRadius
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.backgroundDark.ignoresSafeArea()
        
        Text("Glass Effect")
            .foregroundStyle(.white)
            .padding(40)
            .background(GlassBackground())
    }
}
