import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Animated gradient mesh background
            AnimatedGradientMeshView()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Animated logo
                Image(systemName: "wallet.pass.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(Color.accentYellow)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .rotationEffect(.degrees(rotation))
                
                // App name
                Text("RoadCost")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .opacity(opacity)
                
                Text("Online")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.7))
                    .opacity(opacity)
            }
        }
        .onAppear {
            // Fade in animation
            withAnimation(.easeOut(duration: 0.5)) {
                opacity = 1
            }
            
            // Scale pulsing animation
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                scale = 1.0
            }
            
            // Slow rotation
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

#Preview {
    SplashView()
}
