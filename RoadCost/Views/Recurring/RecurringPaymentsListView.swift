import SwiftUI
import Combine

struct RecurringPaymentsListView: View {
    @StateObject private var viewModel = RecurringPaymentsViewModel()
    @State private var showingAddPayment = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.backgroundDark.ignoresSafeArea()
                ParticleSystemView()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    Text("Recurring Payments")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(GlassBackground(cornerRadius: 0))
                    
                    if viewModel.payments.isEmpty {
                        EmptyStateView(
                            icon: "repeat.circle",
                            title: "No Recurring Payments",
                            message: "Add subscriptions and regular bills to track them automatically",
                            actionTitle: "Add Payment"
                        ) {
                            showingAddPayment = true
                        }
                    } else {
                        paymentsList
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
            .sheet(isPresented: $showingAddPayment) {
                AddRecurringPaymentView(isPresented: $showingAddPayment) {
                    viewModel.loadPayments()
                }
            }
            .onAppear {
                viewModel.loadPayments()
            }
        }
    }
    
    // MARK: - Payments List
    
    private var paymentsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Monthly Total
                VStack(spacing: 8) {
                    Text("Monthly Total")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                    Text(viewModel.monthlyTotal.formattedCurrency)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentYellow)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(GlassBackground())
                
                ForEach(viewModel.payments) { payment in
                    RecurringPaymentRow(payment: payment)
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.deletePayment(payment)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                viewModel.togglePayment(payment)
                            } label: {
                                Label(
                                    payment.isActive ? "Pause" : "Resume",
                                    systemImage: payment.isActive ? "pause.circle" : "play.circle"
                                )
                            }
                        }
                }
            }
            .padding()
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - FAB
    
    private var fabButton: some View {
        Button(action: {
            hapticFeedback()
            showingAddPayment = true
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

// MARK: - Recurring Payment Row

struct RecurringPaymentRow: View {
    let payment: RecurringPayment
    
    var body: some View {
        HStack(spacing: 16) {
            // Category Icon
            CategoryIconView(category: payment.category, size: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(payment.name)
                    .font(.headline)
                    .foregroundStyle(payment.isActive ? .white : .white.opacity(0.5))
                
                HStack(spacing: 8) {
                    Image(systemName: payment.frequency.icon)
                        .font(.caption2)
                    Text(payment.frequency.displayName)
                        .font(.caption)
                    
                    Text("• Next: \(payment.formattedNextDate)")
                        .font(.caption)
                }
                .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(payment.formattedAmount)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(payment.isActive ? Color.accentYellow : Color.accentYellow.opacity(0.5))
                
                if !payment.isActive {
                    Text("Paused")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.3))
                        .cornerRadius(4)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding()
        .background(GlassBackground())
        .opacity(payment.isActive ? 1 : 0.7)
    }
}

// MARK: - ViewModel

final class RecurringPaymentsViewModel: ObservableObject {
    @Published var payments: [RecurringPayment] = []
    @Published var monthlyTotal: Double = 0
    
    private let dataManager = DataManager.shared
    
    func loadPayments() {
        payments = dataManager.loadRecurringPayments()
        calculateMonthlyTotal()
    }
    
    func calculateMonthlyTotal() {
        monthlyTotal = payments
            .filter { $0.isActive }
            .reduce(0) { total, payment in
                switch payment.frequency {
                case .daily:
                    return total + payment.amount * 30
                case .weekly:
                    return total + payment.amount * 4
                case .monthly:
                    return total + payment.amount
                case .yearly:
                    return total + payment.amount / 12
                }
            }
    }
    
    func deletePayment(_ payment: RecurringPayment) {
        do {
            try dataManager.deleteRecurringPayment(payment)
            loadPayments()
        } catch {
            print("Error deleting payment: \(error)")
        }
    }
    
    func togglePayment(_ payment: RecurringPayment) {
        var updated = payment
        updated.isActive.toggle()
        do {
            try dataManager.updateRecurringPayment(updated)
            loadPayments()
        } catch {
            print("Error updating payment: \(error)")
        }
    }
}

#Preview {
    RecurringPaymentsListView()
}
