import SwiftUI

struct SavingsGoalDetailView: View {
    let goal: SavingsGoal
    @ObservedObject var viewModel: SavingsViewModel
    @Binding var isPresented: Bool
    
    @State private var depositAmount = ""
    @State private var withdrawAmount = ""
    @State private var showDeposit = false
    @State private var showWithdraw = false
    @State private var note = ""
    
    var body: some View {
        ZStack {
            Color.backgroundDark.ignoresSafeArea()
            ParticleSystemView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    Text(goal.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding()
                .background(GlassBackground(cornerRadius: 0))
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Progress Card
                        progressCard
                        
                        // Action Buttons
                        actionButtons
                        
                        // Deposit/Withdraw Sheets
                        if showDeposit {
                            depositSheet
                        }
                        
                        if showWithdraw {
                            withdrawSheet
                        }
                        
                        // Stats
                        statsCard
                        
                        // Transactions
                        transactionsCard
                    }
                    .padding()
                    .padding(.bottom, 50)
                }
            }
        }
    }
    
    // MARK: - Progress Card
    
    private var progressCard: some View {
        VStack(spacing: 20) {
            // Icon and progress ring
            ZStack {
                Circle()
                    .stroke(goal.color.opacity(0.2), lineWidth: 12)
                    .frame(width: 140, height: 140)
                
                Circle()
                    .trim(from: 0, to: goal.progress)
                    .stroke(goal.color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: goal.progress)
                
                VStack(spacing: 4) {
                    Image(systemName: goal.icon)
                        .font(.system(size: 36))
                        .foregroundStyle(goal.color)
                    
                    Text(goal.progress.formattedPercentage)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
            
            // Amounts
            VStack(spacing: 8) {
                HStack(alignment: .bottom, spacing: 4) {
                    Text(goal.formattedCurrent)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(goal.color)
                    
                    Text("/ \(goal.formattedTarget)")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.6))
                }
                
                if goal.remaining > 0 {
                    Text("\(goal.formattedRemaining) remaining")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                } else {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Goal completed!")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.green)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(GlassBackground())
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: {
                withAnimation {
                    showWithdraw = false
                    showDeposit.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Money")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(goal.color)
                .foregroundStyle(.white)
                .cornerRadius(14)
            }
            
            Button(action: {
                withAnimation {
                    showDeposit = false
                    showWithdraw.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "minus.circle.fill")
                    Text("Withdraw")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.1))
                .foregroundStyle(.white)
                .cornerRadius(14)
            }
            .disabled(goal.currentAmount <= 0)
            .opacity(goal.currentAmount > 0 ? 1 : 0.5)
        }
    }
    
    // MARK: - Deposit Sheet
    
    private var depositSheet: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Add Money")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }
            
            AmountTextField(text: $depositAmount)
            
            HStack {
                Image(systemName: "note.text")
                    .foregroundStyle(goal.color)
                
                CustomTextField(
                    text: $note,
                    placeholder: "Note (optional)",
                    placeholderColor: UIColor(goal.color.opacity(0.5)),
                    textColor: .white,
                    fontSize: 16,
                    fontWeight: .regular,
                    keyboardType: .default,
                    textAlignment: .left
                )
            }
            .padding()
            .background(GlassBackground())
            
            Button(action: {
                if let amount = Double(depositAmount), amount > 0 {
                    viewModel.deposit(to: goal, amount: amount, note: note.isEmpty ? nil : note)
                    depositAmount = ""
                    note = ""
                    withAnimation { showDeposit = false }
                    isPresented = false
                    hapticNotification(type: .success)
                }
            }) {
                Text("Confirm Deposit")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Double(depositAmount) ?? 0 > 0 ? goal.color : Color.gray)
                    .foregroundStyle(.white)
                    .cornerRadius(14)
            }
            .disabled((Double(depositAmount) ?? 0) <= 0)
        }
        .padding()
        .background(GlassBackground())
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    // MARK: - Withdraw Sheet
    
    private var withdrawSheet: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Withdraw Money")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text("Max: \(goal.formattedCurrent)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            AmountTextField(text: $withdrawAmount)
            
            Button(action: {
                if let amount = Double(withdrawAmount), amount > 0 {
                    viewModel.withdraw(from: goal, amount: min(amount, goal.currentAmount))
                    withdrawAmount = ""
                    withAnimation { showWithdraw = false }
                    isPresented = false
                    hapticNotification(type: .success)
                }
            }) {
                Text("Confirm Withdrawal")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Double(withdrawAmount) ?? 0 > 0 ? Color.red : Color.gray)
                    .foregroundStyle(.white)
                    .cornerRadius(14)
            }
            .disabled((Double(withdrawAmount) ?? 0) <= 0)
        }
        .padding()
        .background(GlassBackground())
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    // MARK: - Stats Card
    
    private var statsCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Statistics")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }
            
            HStack(spacing: 20) {
                StatItem(
                    icon: "calendar",
                    title: "Started",
                    value: DateFormatter.shortDate.string(from: goal.createdAt),
                    color: goal.color
                )
                
                if let days = goal.daysRemaining {
                    StatItem(
                        icon: "clock.fill",
                        title: "Days Left",
                        value: "\(days)",
                        color: days < 7 ? .red : goal.color
                    )
                }
                
                if let daily = goal.suggestedDailyAmount {
                    StatItem(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Daily Goal",
                        value: daily.formattedCurrency,
                        color: goal.color
                    )
                }
            }
        }
        .padding()
        .background(GlassBackground())
    }
    
    // MARK: - Transactions Card
    
    private var transactionsCard: some View {
        let transactions = viewModel.getTransactions(for: goal).sorted { $0.date > $1.date }
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }
            
            if transactions.isEmpty {
                Text("No transactions yet")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(transactions.prefix(5)) { transaction in
                    HStack {
                        Image(systemName: transaction.isDeposit ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                            .foregroundStyle(transaction.isDeposit ? .green : .red)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(transaction.isDeposit ? "Deposit" : "Withdrawal")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                            
                            Text(DateFormatter.shortDate.string(from: transaction.date))
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        
                        Spacer()
                        
                        Text("\(transaction.isDeposit ? "+" : "-")\(transaction.amount.formattedCurrency)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(transaction.isDeposit ? .green : .red)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .padding()
        .background(GlassBackground())
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SavingsGoalDetailView(
        goal: SavingsGoal.sampleData[0],
        viewModel: SavingsViewModel(),
        isPresented: .constant(true)
    )
}
