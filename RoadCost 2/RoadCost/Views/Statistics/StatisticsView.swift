import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    
    var body: some View {
        ZStack {
            // Background
            ZStack {
                WaveAnimationView()
                AnimatedGradientMeshView().opacity(0.3)
            }
            .ignoresSafeArea()
            
            VStack {
                // Header
                Text("Statistics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.top)
                
                // Period Selector
                Picker("Period", selection: $viewModel.selectedPeriod) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue)
                            .foregroundStyle(.white)
                            .tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .tint(Color.accentYellow)
                .colorScheme(.dark)
                .padding()
                .onAppear {
                    // Customize segmented control appearance
                    UISegmentedControl.appearance().setTitleTextAttributes([
                        .foregroundColor: UIColor.white
                    ], for: .normal)
                    UISegmentedControl.appearance().setTitleTextAttributes([
                        .foregroundColor: UIColor.black
                    ], for: .selected)
                    UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.accentYellow)
                    UISegmentedControl.appearance().backgroundColor = UIColor(Color.overlayDark)
                }
                .onChange(of: viewModel.selectedPeriod) { _, _ in
                    viewModel.loadStatistics()
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Total
                        VStack {
                            Text("Total Spent")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                            Text(viewModel.totalAmount.formattedCurrency)
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(Color.accentYellow)
                        }
                        .frame(maxWidth: .infinity)
                        .glassCard()
                        
                        // Pie Chart
                        if !viewModel.categoryStats.isEmpty {
                            VStack {
                                Text("Distribution")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                CategoryPieChartView(stats: viewModel.categoryStats)
                                    .frame(height: 200)
                                    .padding(.vertical)
                            }
                            .padding()
                            .glassCard()
                        }
                        
                        // Line Chart
                        VStack {
                            Text("Trends")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ExpensesLineChartView(expenses: viewModel.expenses, period: viewModel.selectedPeriod)
                                .frame(height: 150)
                                .padding(.vertical)
                        }
                        .padding()
                        .glassCard()
                        
                        // Category List
                        if !viewModel.categoryStats.isEmpty {
                            CategoryStatsView(stats: viewModel.categoryStats)
                        }
                    }
                    .padding()
                    .padding(.bottom, 80)
                }
            }
        }
        .onAppear {
            viewModel.loadStatistics()
        }
    }
}
