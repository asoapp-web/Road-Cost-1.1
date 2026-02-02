import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var searchResults: [SearchResult] = []
    
    private let dataManager = DataManager.shared
    
    var body: some View {
        ZStack {
            Color.backgroundDark.ignoresSafeArea()
            AnimatedGradientMeshView()
                .opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search Header
                HStack(spacing: 12) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.accentYellow)
                        
                        CustomTextField(
                            text: $searchText,
                            placeholder: "Search expenses & incomes...",
                            placeholderColor: UIColor(Color.accentYellow.opacity(0.6)),
                            textColor: .white,
                            fontSize: 17,
                            fontWeight: .regular,
                            keyboardType: .default,
                            textAlignment: .left
                        )
                    }
                    .padding()
                    .background(GlassBackground())
                }
                .padding()
                
                // Results
                if searchText.isEmpty {
                    emptySearchState
                } else if searchResults.isEmpty {
                    noResultsState
                } else {
                    resultsList
                }
            }
        }
        .onChange(of: searchText) { _, newValue in
            performSearch(query: newValue)
        }
    }
    
    // MARK: - Empty State
    
    private var emptySearchState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(Color.accentYellow.opacity(0.5))
            
            Text("Search Your Finances")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            
            Text("Find expenses and incomes by amount, category, or notes")
                .font(.body)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var noResultsState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.4))
            
            Text("No Results")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            
            Text("Try a different search term")
                .font(.body)
                .foregroundStyle(.white.opacity(0.6))
            
            Spacer()
        }
    }
    
    // MARK: - Results List
    
    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(searchResults) { result in
                    SearchResultRow(result: result)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Search Logic
    
    private func performSearch(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        let lowercasedQuery = query.lowercased()
        var results: [SearchResult] = []
        
        // Search expenses
        let expenses = dataManager.loadExpenses()
        for expense in expenses {
            if matchesQuery(expense: expense, query: lowercasedQuery) {
                results.append(SearchResult(
                    id: expense.id,
                    type: .expense,
                    amount: expense.amount,
                    categoryName: expense.category.displayName,
                    categoryIcon: expense.category.icon,
                    categoryColor: expense.category.color,
                    date: expense.date,
                    note: expense.note
                ))
            }
        }
        
        // Search incomes
        let incomes = dataManager.loadIncomes()
        for income in incomes {
            if matchesQuery(income: income, query: lowercasedQuery) {
                results.append(SearchResult(
                    id: income.id,
                    type: .income,
                    amount: income.amount,
                    categoryName: income.category.displayName,
                    categoryIcon: income.category.icon,
                    categoryColor: income.category.color,
                    date: income.date,
                    note: income.note
                ))
            }
        }
        
        searchResults = results.sorted { $0.date > $1.date }
    }
    
    private func matchesQuery(expense: Expense, query: String) -> Bool {
        if expense.category.displayName.lowercased().contains(query) { return true }
        if expense.note?.lowercased().contains(query) == true { return true }
        if String(format: "%.2f", expense.amount).contains(query) { return true }
        return false
    }
    
    private func matchesQuery(income: Income, query: String) -> Bool {
        if income.category.displayName.lowercased().contains(query) { return true }
        if income.note?.lowercased().contains(query) == true { return true }
        if String(format: "%.2f", income.amount).contains(query) { return true }
        return false
    }
}

// MARK: - Search Result

struct SearchResult: Identifiable {
    let id: UUID
    let type: TransactionType
    let amount: Double
    let categoryName: String
    let categoryIcon: String
    let categoryColor: Color
    let date: Date
    let note: String?
    
    enum TransactionType {
        case expense
        case income
    }
}

// MARK: - Search Result Row

struct SearchResultRow: View {
    let result: SearchResult
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(result.categoryColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: result.categoryIcon)
                    .font(.system(size: 22))
                    .foregroundStyle(result.categoryColor)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(result.categoryName)
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    Text(result.type == .expense ? "Expense" : "Income")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(result.type == .expense ? Color.red.opacity(0.3) : Color.green.opacity(0.3))
                        .cornerRadius(4)
                        .foregroundStyle(result.type == .expense ? .red : .green)
                }
                
                HStack(spacing: 8) {
                    Text(DateFormatter.shortDate.string(from: result.date))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                    
                    if let note = result.note {
                        Text("• \(note)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            // Amount
            Text(result.type == .expense ? "-\(result.amount.formattedCurrency)" : "+\(result.amount.formattedCurrency)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(result.type == .expense ? Color.accentYellow : .green)
        }
        .padding()
        .background(GlassBackground())
    }
}

#Preview {
    SearchView()
}
