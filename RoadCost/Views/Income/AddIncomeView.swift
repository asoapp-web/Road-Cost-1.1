import SwiftUI

struct AddIncomeView: View {
    @StateObject private var viewModel = AddIncomeViewModel()
    @Binding var isPresented: Bool
    var onSave: () -> Void
    
    var body: some View {
        ZStack {
            Color.backgroundDark.ignoresSafeArea()
            AnimatedGradientMeshView()
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
                    Text("New Income")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: {
                        viewModel.saveIncome()
                        isPresented = false
                        onSave()
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(viewModel.isValid ? Color.accentYellow : .white.opacity(0.3))
                    }
                    .disabled(!viewModel.isValid)
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Amount
                        VStack(alignment: .leading) {
                            Text("Amount")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.leading)
                            
                            AmountTextField(text: $viewModel.amount)
                        }
                        
                        // Category
                        VStack(alignment: .leading) {
                            Text("Category")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.leading)
                            
                            IncomeCategoryPickerView(selection: $viewModel.selectedCategory)
                                .padding()
                                .background(GlassBackground())
                        }
                        
                        // Date
                        DatePickerView(date: $viewModel.selectedDate)
                        
                        // Note
                        VStack(alignment: .leading) {
                            Text("Note")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.leading)
                            
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundStyle(Color.accentYellow)
                                
                                CustomTextField(
                                    text: $viewModel.note,
                                    placeholder: "Income description",
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
                    }
                    .padding()
                }
            }
        }
        .onChange(of: viewModel.amount) { _, _ in
            viewModel.validateForm()
        }
    }
}

// MARK: - Income Category Picker

struct IncomeCategoryPickerView: View {
    @Binding var selection: IncomeCategory
    
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(IncomeCategory.allCases) { category in
                Button(action: {
                    withAnimation {
                        selection = category
                    }
                    hapticFeedback()
                }) {
                    VStack {
                        ZStack {
                            Circle()
                                .fill(selection == category ? category.color : category.color.opacity(0.2))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: category.icon)
                                .font(.title2)
                                .foregroundStyle(selection == category ? .white : category.color)
                        }
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: selection == category ? 2 : 0)
                        )
                        .scaleEffect(selection == category ? 1.1 : 1.0)
                        
                        Text(category.displayName)
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    AddIncomeView(isPresented: .constant(true)) {}
}
