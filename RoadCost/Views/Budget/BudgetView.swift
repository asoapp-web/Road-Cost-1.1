import SwiftUI
import Combine

struct BudgetView: View {
    @StateObject private var viewModel = BudgetViewModel()
    @State private var showingSetup = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated background
                ZStack {
                    ParticleSystemView()
                    OrbitalCirclesView().opacity(0.3)
                }
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Main Budget Progress
                            if let monthly = viewModel.budget?.monthlyBudget {
                                mainBudgetCard(monthly: monthly)
                            } else {
                                noBudgetCard
                            }
                            
                            // Recurring Payments Section
                            recurringPaymentsSection
                            
                            // Category Limits
                            if !(viewModel.budget?.categoryLimits.isEmpty ?? true) {
                                categoryLimitsSection
                            }
                            
                            // Warnings
                            if !viewModel.warnings.isEmpty {
                                warningsSection
                            }
                        }
                        .padding()
                        .padding(.bottom, 100)
                    }
                }
                
                // Setup Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        setupButton
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSetup) {
                BudgetSetupView(viewModel: viewModel, isPresented: $showingSetup)
            }
            .onAppear {
                viewModel.loadBudget()
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        Text("Budget")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(GlassBackground(cornerRadius: 0))
    }
    
    // MARK: - Main Budget Card
    
    private func mainBudgetCard(monthly: Double) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Monthly Budget")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(monthly.formattedCurrency)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentYellow)
                }
                Spacer()
                Image(systemName: "target")
                    .font(.largeTitle)
                    .foregroundStyle(Color.accentYellow)
            }
            
            // Progress Bar
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 12)
                        
                        Capsule()
                            .fill(progressColor)
                            .frame(width: geometry.size.width * viewModel.getProgress(), height: 12)
                            .animation(.spring(), value: viewModel.getProgress())
                    }
                }
                .frame(height: 12)
                
                HStack {
                    Text("Spent: \(viewModel.currentMonthSpending.formattedCurrency)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                    Text("Remaining: \(viewModel.getRemaining().formattedCurrency)")
                        .font(.caption)
                        .foregroundStyle(progressColor)
                }
            }
        }
        .padding()
        .background(GlassBackground())
    }
    
    private var progressColor: Color {
        let progress = viewModel.getProgress()
        if progress >= 1.0 {
            return .red
        } else if progress >= 0.75 {
            return .orange
        } else {
            return Color.accentYellow
        }
    }
    
    // MARK: - No Budget Card
    
    private var noBudgetCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 50))
                .foregroundStyle(Color.accentYellow.opacity(0.6))
            
            Text("No Budget Set")
                .font(.headline)
                .foregroundStyle(.white)
            
            Text("Set up a monthly budget to track your spending")
                .font(.body)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button(action: { showingSetup = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Set Up Budget")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.accentYellow)
                .cornerRadius(24)
                .foregroundStyle(.white)
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(GlassBackground())
    }
    
    // MARK: - Recurring Payments Section
    
    private var recurringPaymentsSection: some View {
        let recurringPayments = DataManager.shared.loadRecurringPayments().filter { $0.isActive }
        let monthlyRecurring = recurringPayments.reduce(0.0) { total, payment in
            switch payment.frequency {
            case .daily: return total + payment.amount * 30
            case .weekly: return total + payment.amount * 4
            case .monthly: return total + payment.amount
            case .yearly: return total + payment.amount / 12
            }
        }
        
        guard monthlyRecurring > 0 else { return AnyView(EmptyView()) }
        
        return AnyView(
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "repeat.circle.fill")
                        .foregroundStyle(Color.accentYellow)
                    Text("Monthly Recurring Payments")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    Text(monthlyRecurring.formattedCurrency)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentYellow)
                }
                
                Text("These automatic payments are included in your budget calculations")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                
                ForEach(recurringPayments.prefix(3)) { payment in
                    HStack {
                        CategoryIconView(category: payment.category, size: 32)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(payment.name)
                                .font(.subheadline)
                                .foregroundStyle(.white)
                            Text(payment.frequency.displayName)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        Text(payment.formattedAmount)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding()
            .background(GlassBackground())
        )
    }
    
    // MARK: - Category Limits Section
    
    private var categoryLimitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Limits")
                .font(.headline)
                .foregroundStyle(.white)
            
            ForEach(ExpenseCategory.allCases) { category in
                if let limit = viewModel.budget?.getLimit(for: category) {
                    categoryLimitRow(category: category, limit: limit)
                }
            }
        }
        .padding()
        .background(GlassBackground())
    }
    
    private func categoryLimitRow(category: ExpenseCategory, limit: Double) -> some View {
        let spent = viewModel.categorySpending[category] ?? 0
        let progress = viewModel.getCategoryProgress(for: category)
        
        return VStack(spacing: 8) {
            HStack {
                CategoryIconView(category: category, size: 32)
                
                VStack(alignment: .leading) {
                    Text(category.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                    Text("\(spent.formattedCurrency) / \(limit.formattedCurrency)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                Spacer()
                
                Text(progress.formattedPercentage)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(progress >= 1.0 ? .red : (progress >= 0.75 ? .orange : .white))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(category.color)
                        .frame(width: geometry.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
    
    // MARK: - Warnings Section
    
    private var warningsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text("Warnings")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            
            ForEach(viewModel.warnings) { warning in
                HStack {
                    Image(systemName: warning.isOverBudget ? "xmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundStyle(warning.isOverBudget ? .red : .orange)
                    
                    Text(warning.message)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.2))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(GlassBackground())
    }
    
    // MARK: - Setup Button
    
    private var setupButton: some View {
        Button(action: {
            hapticFeedback()
            showingSetup = true
        }) {
            Image(systemName: "slider.horizontal.3")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(Color.accentYellow)
                .clipShape(Circle())
                .shadow(color: Color.accentYellow.opacity(0.4), radius: 10, x: 0, y: 5)
        }
        .padding(24)
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    BudgetView()
}
