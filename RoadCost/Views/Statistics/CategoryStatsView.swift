import SwiftUI

struct CategoryStatsView: View {
    let stats: [CategoryStat]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(stats) { stat in
                HStack {
                    CategoryIconView(category: stat.category, size: 32)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(stat.category.displayName)
                                .font(.subheadline)
                                .foregroundStyle(.white)
                            Spacer()
                            Text(stat.amount.formattedCurrency)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 6)
                                
                                Capsule()
                                    .fill(stat.color)
                                    .frame(width: geometry.size.width * stat.percentage, height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                }
            }
        }
        .padding()
        .glassCard()
    }
}
