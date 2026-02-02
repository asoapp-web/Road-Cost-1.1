import SwiftUI
import Combine

struct IncomeListView: View {
    @StateObject private var viewModel = IncomeViewModel()
    @State private var showingAddIncome = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated background
                ZStack {
                    AnimatedGradientMeshView()
                }
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with balance
                    balanceHeader
                    
                    // Period filter
                    periodFilter
                    
                    // Content
                    if viewModel.filteredIncomes.isEmpty {
                        EmptyStateView(
                            icon: "arrow.down.circle",
                            title: "No Income Yet",
                            message: "Start tracking your income by adding your first entry",
                            actionTitle: "Add Income"
                        ) {
                            showingAddIncome = true
                        }
                    } else {
                        incomeList
                    }
                }
                
                // FAB
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        fabButton
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddIncome) {
                AddIncomeView(isPresented: $showingAddIncome) {
                    viewModel.loadIncomes()
                }
            }
        }
    }
    
    // MARK: - Balance Header
    
    private var balanceHeader: some View {
        VStack(spacing: 16) {
            Text("Income")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            HStack(spacing: 24) {
                VStack {
                    Text("Total Income")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Text(viewModel.totalIncome.formattedCurrency)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentYellow)
                }
                
                Divider()
                    .frame(height: 40)
                    .background(Color.white.opacity(0.3))
                
                VStack {
                    Text("Balance")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Text(viewModel.balance.formattedCurrency)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(viewModel.balance >= 0 ? .green : .red)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(GlassBackground(cornerRadius: 0))
    }
    
    // MARK: - Period Filter
    
    private var periodFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    FilterChip(
                        title: period.rawValue,
                        icon: period.icon,
                        isSelected: viewModel.selectedPeriod == period
                    ) {
                        withAnimation {
                            viewModel.selectedPeriod = period
                            viewModel.filterIncomes()
                            viewModel.calculateTotals()
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Income List
    
    private var incomeList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.filteredIncomes.enumerated()), id: \.element.id) { index, income in
                    IncomeRowView(income: income)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.05), value: viewModel.filteredIncomes.count)
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation {
                                    viewModel.deleteIncome(income)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding()
            .padding(.bottom, 100)
        }
        .refreshable {
            viewModel.loadIncomes()
        }
    }
    
    // MARK: - FAB
    
    private var fabButton: some View {
        Button(action: {
            hapticFeedback()
            showingAddIncome = true
        }) {
            Image(systemName: "plus")
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

// MARK: - Income Row View

struct IncomeRowView: View {
    let income: Income
    
    var body: some View {
        HStack(spacing: 16) {
            // Category Icon
            ZStack {
                Circle()
                    .fill(income.category.color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: income.category.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(income.category.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(income.category.displayName)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                HStack(spacing: 8) {
                    Text(income.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                    
                    if let note = income.note {
                        Text("• \(note)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            Text("+\(income.formattedAmount)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.green)
        }
        .padding()
        .background(GlassBackground())
    }
}

#Preview {
    IncomeListView()
}
