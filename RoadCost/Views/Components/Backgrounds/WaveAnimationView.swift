import SwiftUI

struct WaveAnimationView: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.backgroundDark.ignoresSafeArea()
            
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let midHeight = height / 2
                    
                    path.move(to: CGPoint(x: 0, y: midHeight))
                    
                    for x in stride(from: 0, to: width, by: 1) {
                        let relativeX = x / width
                        let sine = sin(relativeX * .pi * 2 + phase)
                        let y = midHeight + sine * 40
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [Color.overlayDark, Color.accentYellow.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
}
