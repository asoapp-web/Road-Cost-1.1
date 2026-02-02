import SwiftUI

struct OrbitalCirclesView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Color.backgroundDark.ignoresSafeArea()
            
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.overlayDark.opacity(0.3),
                                        Color.overlayDark.opacity(0.1)
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)
                            .offset(
                                x: cos(rotation + Double(index) * .pi * 2 / 3) * 100,
                                y: sin(rotation + Double(index) * .pi * 2 / 3) * 100
                            )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                rotation = .pi * 2
            }
        }
    }
}
