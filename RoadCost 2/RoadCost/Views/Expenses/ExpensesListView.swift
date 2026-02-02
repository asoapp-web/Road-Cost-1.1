import SwiftUI

struct ExpensesListView: View {
    @StateObject private var viewModel = ExpensesListViewModel()
    @State private var showingAddExpense = false
    @State private var showingSearch = false
    @State private var selectedExpense: Expense?
    @Namespace private var heroNamespace
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated background
                ZStack {
                    ParticleSystemView()
                    AnimatedGradientMeshView().opacity(0.3)
                }
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with total
                    headerView
                    
                    // Filter chips
                    filterChipsView
                    
                    // Content
                    if viewModel.filteredExpenses.isEmpty {
                        EmptyStateView(
                            icon: "tray",
                            title: "No Expenses Yet",
                            message: "Start tracking your spending by adding your first expense",
                            actionTitle: "Add Expense"
                        ) {
                            showingAddExpense = true
                        }
                    } else {
                        expensesList
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
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView(
                    viewModel: AddExpenseViewModel(),
                    isPresented: $showingAddExpense
                ) {
                    viewModel.loadExpenses()
                }
            }
            .fullScreenCover(isPresented: $showingSearch) {
                SearchView()
            }
            .navigationDestination(item: $selectedExpense) { expense in
                ExpenseDetailView(expense: expense)
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                Text("Expenses")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Spacer()
                
                Button(action: { showingSearch = true }) {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            
            Text("Total: \(viewModel.getTotalAmount().formattedCurrency)")
                .font(.title2)
                .foregroundStyle(Color.accentYellow)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(GlassBackground(cornerRadius: 0))
    }
    
    // MARK: - Filter Chips
    
    private var filterChipsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Period filter
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    FilterChip(
                        title: period.rawValue,
                        icon: period.icon,
                        isSelected: viewModel.selectedPeriod == period
                    ) {
                        withAnimation {
                            viewModel.selectedPeriod = period
                            viewModel.filterAndSortExpenses()
                        }
                    }
                }
                
                Divider()
                    .frame(height: 24)
                    .background(Color.white.opacity(0.3))
                
                // Category filter
                ForEach(ExpenseCategory.allCases) { category in
                    FilterChip(
                        title: category.displayName,
                        icon: category.icon,
                        isSelected: viewModel.selectedCategory == category,
                        color: category.color
                    ) {
                        withAnimation {
                            if viewModel.selectedCategory == category {
                                viewModel.selectedCategory = nil
                            } else {
                                viewModel.selectedCategory = category
                            }
                            viewModel.filterAndSortExpenses()
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Expenses List
    
    private var expensesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.filteredExpenses.enumerated()), id: \.element.id) { index, expense in
                    ExpenseRowView(expense: expense)
                        .matchedGeometryEffect(id: expense.id, in: heroNamespace)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.05), value: viewModel.filteredExpenses.count)
                        .onTapGesture {
                            hapticFeedback()
                            selectedExpense = expense
                        }
                        .contextMenu {
                            Button {
                                hapticFeedback()
                                selectedExpense = expense
                            } label: {
                                Label("View Details", systemImage: "eye")
                            }
                            
                            Button(role: .destructive) {
                                withAnimation {
                                    viewModel.deleteExpense(expense)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    viewModel.deleteExpense(expense)
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
            viewModel.loadExpenses()
        }
    }
    
    // MARK: - FAB
    
    private var fabButton: some View {
        Button(action: {
            hapticFeedback()
            showingAddExpense = true
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

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    var color: Color = .accentYellow
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            hapticFeedback()
            action()
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color.white.opacity(0.1))
            .foregroundStyle(isSelected ? .white : .white.opacity(0.8))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? color : Color.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

#Preview {
    ExpensesListView()
}
