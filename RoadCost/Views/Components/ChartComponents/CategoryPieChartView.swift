import SwiftUI

struct CategoryPieChartView: View {
    let stats: [CategoryStat]
    @State private var selectedSlice: UUID?
    @State private var animationProgress: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ZStack {
                // Pie slices
                ForEach(Array(stats.enumerated()), id: \.element.id) { index, stat in
                    let startAngle = angleFor(index: index, isStart: true)
                    let endAngle = angleFor(index: index, isStart: false)
                    
                    PieChartSlice(startAngle: startAngle, endAngle: endAngle)
                        .fill(stat.color)
                        .scaleEffect(selectedSlice == stat.id ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedSlice)
                        .onTapGesture {
                            withAnimation {
                                if selectedSlice == stat.id {
                                    selectedSlice = nil
                                } else {
                                    selectedSlice = stat.id
                                }
                            }
                            hapticFeedback()
                        }
                }
                .frame(width: size * 0.7, height: size * 0.7)
                .position(center)
                
                // Center hole (donut effect)
                Circle()
                    .fill(Color.backgroundDark)
                    .frame(width: size * 0.35, height: size * 0.35)
                    .position(center)
                
                // Center text
                if let selectedId = selectedSlice,
                   let stat = stats.first(where: { $0.id == selectedId }) {
                    VStack(spacing: 2) {
                        Text(stat.percentage.formattedPercentage)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Text(stat.category.displayName)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .position(center)
                } else {
                    VStack(spacing: 2) {
                        Text("\(stats.count)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Text("Categories")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .position(center)
                }
            }
            
            // Legend with icons only
            HStack(spacing: 12) {
                ForEach(stats) { stat in
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(stat.color.opacity(0.2))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: stat.category.icon)
                                .font(.system(size: 14))
                                .foregroundStyle(stat.color)
                        }
                        
                        Text(stat.percentage.formattedPercentage)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .scaleEffect(selectedSlice == stat.id ? 1.15 : 1.0)
                    .animation(.spring(response: 0.3), value: selectedSlice)
                    .onTapGesture {
                        withAnimation {
                            selectedSlice = selectedSlice == stat.id ? nil : stat.id
                        }
                        hapticFeedback()
                    }
                }
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height - 30)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animationProgress = 1.0
            }
        }
    }
    
    private func angleFor(index: Int, isStart: Bool) -> Angle {
        let total = stats.reduce(0) { $0 + $1.percentage }
        guard total > 0 else { return .degrees(0) }
        
        var angle: Double = -90 // Start from top
        
        for i in 0..<index {
            angle += (stats[i].percentage / total) * 360
        }
        
        if !isStart {
            angle += (stats[index].percentage / total) * 360
        }
        
        return .degrees(angle * animationProgress)
    }
}

#Preview {
    ZStack {
        Color.backgroundDark.ignoresSafeArea()
        
        CategoryPieChartView(stats: [
            CategoryStat(category: .food, amount: 500, percentage: 0.4),
            CategoryStat(category: .transport, amount: 300, percentage: 0.24),
            CategoryStat(category: .entertainment, amount: 200, percentage: 0.16),
            CategoryStat(category: .shopping, amount: 150, percentage: 0.12),
            CategoryStat(category: .health, amount: 100, percentage: 0.08)
        ])
        .frame(height: 200)
        .padding()
    }
}
