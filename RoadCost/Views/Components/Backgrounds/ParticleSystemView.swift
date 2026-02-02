import SwiftUI

struct ParticleSystemView: View {
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGPoint
        var size: CGFloat
        var opacity: Double
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in particles {
                    let rect = CGRect(
                        x: particle.position.x,
                        y: particle.position.y,
                        width: particle.size,
                        height: particle.size
                    )
                    context.opacity = particle.opacity
                    context.fill(Path(ellipseIn: rect), with: .color(Color.accentYellow))
                }
            }
        }
        .background(Color.backgroundDark)
        .onAppear {
            generateParticles()
        }
    }
    
    func generateParticles() {
        for _ in 0..<30 {
            particles.append(
                Particle(
                    position: CGPoint(x: CGFloat.random(in: 0...400), y: CGFloat.random(in: 0...800)),
                    velocity: CGPoint(x: CGFloat.random(in: -0.5...0.5), y: CGFloat.random(in: -0.5...0.5)),
                    size: CGFloat.random(in: 2...8),
                    opacity: Double.random(in: 0.2...0.4)
                )
            )
        }
    }
}
