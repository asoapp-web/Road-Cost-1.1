import SwiftUI

struct RoadCostLoadingView: View {
    @State private var roadcostGradientOffset: CGFloat = 0
    @State private var roadcostTitleOpacity: Double = 0
    @State private var roadcostDotsScale: CGFloat = 1.0
    @State private var roadcostIconRotation: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "1a1a2e"),
                    Color(hex: "16213e"),
                    Color(hex: "0f3460"),
                    Color(hex: "1a1a2e")
                ],
                startPoint: UnitPoint(x: 0.5, y: roadcostGradientOffset),
                endPoint: UnitPoint(x: 0.5, y: roadcostGradientOffset + 1)
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                    roadcostGradientOffset = 1.0
                }
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.accentYellow.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "wallet.pass.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.accentYellow)
                        .rotationEffect(.degrees(roadcostIconRotation))
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                        roadcostIconRotation = 10
                    }
                }
                
                VStack(spacing: 8) {
                    Text("RoadCost")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Text("Your Travel Budget Companion")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .opacity(roadcostTitleOpacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
                        roadcostTitleOpacity = 1.0
                    }
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { roadcostIndex in
                        Circle()
                            .fill(Color.accentYellow)
                            .frame(width: 10, height: 10)
                            .scaleEffect(roadcostDotsScale)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(roadcostIndex) * 0.2),
                                value: roadcostDotsScale
                            )
                    }
                }
                .onAppear {
                    roadcostDotsScale = 0.5
                }
                
                Text("Preparing...")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.bottom, 50)
            }
        }
    }
}

