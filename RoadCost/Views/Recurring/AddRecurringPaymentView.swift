import SwiftUI

struct AddRecurringPaymentView: View {
    @Binding var isPresented: Bool
    var onSave: () -> Void
    
    @State private var name = ""
    @State private var amount = ""
    @State private var selectedCategory: ExpenseCategory = .other
    @State private var selectedFrequency: PaymentFrequency = .monthly
    @State private var startDate = Date()
    
    private var isValid: Bool {
        !name.isEmpty && Double(amount) != nil && Double(amount)! > 0
    }
    
    var body: some View {
        ZStack {
            Color.backgroundDark.ignoresSafeArea()
            OrbitalCirclesView()
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    Spacer()
                    Text("New Recurring Payment")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: save) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(isValid ? Color.accentYellow : .white.opacity(0.3))
                    }
                    .disabled(!isValid)
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Name
                        VStack(alignment: .leading) {
                            Text("Name")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.leading)
                            
                            HStack {
                                Image(systemName: "text.cursor")
                                    .foregroundStyle(Color.accentYellow)
                                
                                CustomTextField(
                                    text: $name,
                                    placeholder: "e.g., Netflix, Gym",
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
                        
                        // Amount
                        VStack(alignment: .leading) {
                            Text("Amount")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.leading)
                            
                            AmountTextField(text: $amount)
                        }
                        
                        // Category
                        VStack(alignment: .leading) {
                            Text("Category")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.leading)
                            
                            CategoryPickerView(selection: $selectedCategory)
                                .padding()
                                .background(GlassBackground())
                        }
                        
                        // Frequency
                        VStack(alignment: .leading) {
                            Text("Frequency")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.leading)
                            
                            FrequencyPickerView(selection: $selectedFrequency)
                                .padding()
                                .background(GlassBackground())
                        }
                        
                        // Start Date
                        DatePickerView(date: $startDate)
                    }
                    .padding()
                }
            }
        }
    }
    
    private func save() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        
        let payment = RecurringPayment(
            amount: amountValue,
            category: selectedCategory,
            name: name,
            startDate: startDate,
            frequency: selectedFrequency
        )
        
        do {
            try DataManager.shared.saveRecurringPayment(payment)
            onSave()
            isPresented = false
        } catch {
            print("Error saving recurring payment: \(error)")
        }
    }
}

// MARK: - Frequency Picker

struct FrequencyPickerView: View {
    @Binding var selection: PaymentFrequency
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(PaymentFrequency.allCases, id: \.self) { frequency in
                Button(action: {
                    withAnimation {
                        selection = frequency
                    }
                    hapticFeedback()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: frequency.icon)
                            .font(.title3)
                        Text(frequency.displayName)
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selection == frequency ? Color.accentYellow : Color.white.opacity(0.1))
                    .foregroundStyle(selection == frequency ? .white : .white.opacity(0.7))
                    .cornerRadius(12)
                }
            }
        }
    }
}

#Preview {
    AddRecurringPaymentView(isPresented: .constant(true)) {}
}
