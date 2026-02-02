import SwiftUI

struct AnimatedGradientMeshView: View {
    @State private var animationPhase: CGFloat = 0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            
            Canvas { context, size in
                // Background
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .color(Color.backgroundDark)
                )
                
                // Draw multiple gradient circles
                let circles: [(offset: CGPoint, color: Color, size: CGFloat, speed: Double)] = [
                    (CGPoint(x: 0.3, y: 0.3), Color.primaryDark, 0.6, 0.1),
                    (CGPoint(x: 0.7, y: 0.2), Color.secondaryDark, 0.5, 0.15),
                    (CGPoint(x: 0.5, y: 0.7), Color.accentYellow.opacity(0.3), 0.4, 0.12),
                    (CGPoint(x: 0.2, y: 0.6), Color.accentDark, 0.5, 0.08),
                    (CGPoint(x: 0.8, y: 0.8), Color.tertiaryDark, 0.45, 0.11)
                ]
                
                for circle in circles {
                    let offsetX = sin(time * circle.speed + circle.offset.x * 10) * size.width * 0.1
                    let offsetY = cos(time * circle.speed + circle.offset.y * 10) * size.height * 0.1
                    
                    let center = CGPoint(
                        x: circle.offset.x * size.width + offsetX,
                        y: circle.offset.y * size.height + offsetY
                    )
                    
                    let radius = min(size.width, size.height) * circle.size
                    
                    let gradient = Gradient(colors: [
                        circle.color.opacity(0.4),
                        circle.color.opacity(0.1),
                        circle.color.opacity(0)
                    ])
                    
                    context.drawLayer { ctx in
                        ctx.fill(
                            Path(ellipseIn: CGRect(
                                x: center.x - radius,
                                y: center.y - radius,
                                width: radius * 2,
                                height: radius * 2
                            )),
                            with: .radialGradient(
                                gradient,
                                center: center,
                                startRadius: 0,
                                endRadius: radius
                            )
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    AnimatedGradientMeshView()
        .ignoresSafeArea()
}
