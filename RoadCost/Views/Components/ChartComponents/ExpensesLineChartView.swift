import SwiftUI

struct ExpensesLineChartView: View {
    let expenses: [Expense]
    let period: TimePeriod
    
    @State private var animationProgress: CGFloat = 0
    @State private var selectedPoint: Int?
    
    var body: some View {
        GeometryReader { geometry in
            let chartData = getChartData()
            let maxAmount = chartData.map { $0.amount }.max() ?? 1
            let minAmount: Double = 0
            
            ZStack {
                // Grid lines
                VStack {
                    ForEach(0..<5) { i in
                        Spacer()
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 1)
                    }
                }
                
                // Line path
                if !chartData.isEmpty {
                    Path { path in
                        for (index, point) in chartData.enumerated() {
                            let x = geometry.size.width * CGFloat(index) / CGFloat(max(chartData.count - 1, 1))
                            let normalizedY = (point.amount - minAmount) / (maxAmount - minAmount)
                            let y = geometry.size.height * (1 - CGFloat(normalizedY))
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .trim(from: 0, to: animationProgress)
                    .stroke(
                        LinearGradient(
                            colors: [Color.accentYellow, Color.accentYellow.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )
                    
                    // Points
                    ForEach(Array(chartData.enumerated()), id: \.offset) { index, point in
                        let x = geometry.size.width * CGFloat(index) / CGFloat(max(chartData.count - 1, 1))
                        let normalizedY = (point.amount - minAmount) / (maxAmount - minAmount)
                        let y = geometry.size.height * (1 - CGFloat(normalizedY))
                        
                        Circle()
                            .fill(Color.accentYellow)
                            .frame(width: selectedPoint == index ? 12 : 8, height: selectedPoint == index ? 12 : 8)
                            .position(x: x, y: y)
                            .opacity(animationProgress)
                            .scaleEffect(animationProgress)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedPoint = selectedPoint == index ? nil : index
                                }
                                hapticFeedback()
                            }
                        
                        // Value tooltip
                        if selectedPoint == index {
                            VStack(spacing: 2) {
                                Text(point.amount.formattedCurrency)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text(point.label)
                                    .font(.caption2)
                            }
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(GlassBackground(cornerRadius: 8))
                            .position(x: x, y: max(y - 40, 30))
                        }
                    }
                }
                
                // X-axis labels
                VStack {
                    Spacer()
                    HStack {
                        ForEach(Array(getXLabels().enumerated()), id: \.offset) { _, label in
                            Text(label)
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.6))
                            if label != getXLabels().last {
                                Spacer()
                            }
                        }
                    }
                    .offset(y: 20)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animationProgress = 1.0
            }
        }
    }
    
    private func getChartData() -> [(amount: Double, label: String)] {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .day:
            // Group by hour
            let hourlyExpenses = Dictionary(grouping: expenses) { expense in
                calendar.component(.hour, from: expense.date)
            }
            return (0..<24).compactMap { hour in
                let amount = hourlyExpenses[hour]?.reduce(0) { $0 + $1.amount } ?? 0
                return (amount: amount, label: "\(hour):00")
            }.filter { $0.amount > 0 || $0.label == "0:00" || $0.label == "12:00" || $0.label == "23:00" }
            
        case .week:
            // Last 7 days
            return (0..<7).reversed().map { daysAgo in
                let date = calendar.date(byAdding: .day, value: -daysAgo, to: now)!
                let dayExpenses = expenses.filter { calendar.isDate($0.date, inSameDayAs: date) }
                let amount = dayExpenses.reduce(0) { $0 + $1.amount }
                return (amount: amount, label: DateFormatter.weekday.string(from: date))
            }
            
        case .month:
            // Group by week
            let weeklyExpenses = Dictionary(grouping: expenses) { expense in
                calendar.component(.weekOfMonth, from: expense.date)
            }
            return (1...4).map { week in
                let amount = weeklyExpenses[week]?.reduce(0) { $0 + $1.amount } ?? 0
                return (amount: amount, label: "Week \(week)")
            }
            
        case .all:
            // Group by month
            let monthlyExpenses = Dictionary(grouping: expenses) { expense in
                calendar.dateComponents([.year, .month], from: expense.date)
            }
            let sortedMonths = monthlyExpenses.keys.sorted { lhs, rhs in
                if lhs.year != rhs.year { return lhs.year! < rhs.year! }
                return lhs.month! < rhs.month!
            }
            return sortedMonths.suffix(6).map { components in
                let date = calendar.date(from: components)!
                let amount = monthlyExpenses[components]?.reduce(0) { $0 + $1.amount } ?? 0
                return (amount: amount, label: DateFormatter.dayMonth.string(from: date))
            }
        }
    }
    
    private func getXLabels() -> [String] {
        let data = getChartData()
        guard !data.isEmpty else { return [] }
        
        if data.count <= 4 {
            return data.map { $0.label }
        } else {
            // Show first, middle, and last
            return [data.first!.label, data[data.count / 2].label, data.last!.label]
        }
    }
}

#Preview {
    ZStack {
        Color.backgroundDark.ignoresSafeArea()
        
        ExpensesLineChartView(
            expenses: Expense.sampleData,
            period: .week
        )
        .frame(height: 150)
        .padding()
    }
}
