import SwiftUI

struct BudgetSetupView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @Binding var isPresented: Bool
    @State private var showValidationError = false
    
    private var totalBudget: Double {
        Double(viewModel.monthlyBudgetText) ?? 0
    }
    
    private var totalCategoryLimits: Double {
        ExpenseCategory.allCases.reduce(0) { sum, category in
            sum + (Double(viewModel.categoryLimits[category] ?? "") ?? 0)
        }
    }
    
    private var remainingForCategories: Double {
        max(totalBudget - totalCategoryLimits, 0)
    }
    
    private var isOverBudget: Bool {
        totalCategoryLimits > totalBudget && totalBudget > 0
    }
    
    var body: some View {
        ZStack {
            Color.backgroundDark.ignoresSafeArea()
            OrbitalCirclesView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    Spacer()
                    Text("Budget Setup")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: {
                        if isOverBudget {
                            showValidationError = true
                            hapticNotification(type: .error)
                        } else {
                            viewModel.saveBudget()
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(isOverBudget ? .red : Color.accentYellow)
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Monthly Budget Card
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "target")
                                    .font(.title2)
                                    .foregroundStyle(Color.accentYellow)
                                Text("Monthly Budget")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            
                            HStack(alignment: .center, spacing: 8) {
                                Text("$")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(Color.accentYellow)
                                
                                CustomTextField(
                                    text: $viewModel.monthlyBudgetText,
                                    placeholder: "0.00",
                                    placeholderColor: UIColor(Color.accentYellow.opacity(0.4)),
                                    textColor: .white,
                                    fontSize: 32,
                                    fontWeight: .bold,
                                    keyboardType: .decimalPad,
                                    textAlignment: .left
                                )
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.accentYellow.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .padding()
                        .background(GlassBackground())
                        
                        // Category Limits Section
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "chart.pie.fill")
                                    .foregroundStyle(Color.accentYellow)
                                Text("Category Limits")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Spacer()
                                
                                // Auto Split Button
                                Button(action: autoSplitBudget) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "wand.and.stars")
                                            .font(.caption)
                                        Text("Auto")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.accentYellow)
                                    .foregroundStyle(.white)
                                    .cornerRadius(16)
                                }
                                .disabled(totalBudget <= 0)
                                .opacity(totalBudget > 0 ? 1 : 0.5)
                            }
                            
                            // Progress indicator
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Allocated")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.6))
                                    Spacer()
                                    Text("\(totalCategoryLimits.formattedCurrency) / \(totalBudget.formattedCurrency)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundStyle(isOverBudget ? .red : .white)
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.white.opacity(0.1))
                                            .frame(height: 8)
                                        
                                        Capsule()
                                            .fill(isOverBudget ? Color.red : Color.accentYellow)
                                            .frame(width: totalBudget > 0 ? min(geometry.size.width * (totalCategoryLimits / totalBudget), geometry.size.width) : 0, height: 8)
                                            .animation(.spring(), value: totalCategoryLimits)
                                    }
                                }
                                .frame(height: 8)
                                
                                if isOverBudget {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.caption)
                                        Text("Exceeds budget by \((totalCategoryLimits - totalBudget).formattedCurrency)")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(.red)
                                } else if remainingForCategories > 0 && totalBudget > 0 {
                                    Text("\(remainingForCategories.formattedCurrency) remaining to allocate")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                            .padding(.bottom, 8)
                            
                            // Category inputs
                            ForEach(ExpenseCategory.allCases) { category in
                                categoryLimitInput(category: category)
                            }
                        }
                        .padding()
                        .background(GlassBackground())
                    }
                    .padding()
                    .padding(.bottom, 50)
                }
            }
        }
        .alert("Budget Exceeded", isPresented: $showValidationError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Category limits total (\(totalCategoryLimits.formattedCurrency)) cannot exceed the monthly budget (\(totalBudget.formattedCurrency)). Please adjust the limits.")
        }
    }
    
    private func autoSplitBudget() {
        guard totalBudget > 0 else { return }
        
        let categories = ExpenseCategory.allCases
        let categoryCount = categories.count
        
        // Use floor to avoid exceeding budget
        let perCategory = floor(totalBudget / Double(categoryCount) * 100) / 100
        
        // Calculate remaining after floor division
        var remaining = totalBudget - (perCategory * Double(categoryCount))
        
        for (index, category) in categories.enumerated() {
            if index == categoryCount - 1 {
                // Give all remaining to the last category
                let lastCategoryValue = perCategory + remaining
                viewModel.categoryLimits[category] = String(format: "%.2f", lastCategoryValue)
            } else {
                viewModel.categoryLimits[category] = String(format: "%.2f", perCategory)
            }
        }
        
        hapticFeedback()
    }
    
    private func categoryLimitInput(category: ExpenseCategory) -> some View {
        let currentValue = Double(viewModel.categoryLimits[category] ?? "") ?? 0
        let maxAllowed = totalBudget - totalCategoryLimits + currentValue
        
        return HStack(spacing: 12) {
            CategoryIconView(category: category, size: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                
                if currentValue > 0 && totalBudget > 0 {
                    Text("\((currentValue / totalBudget * 100).formattedPercentage)")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("$")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                
                CustomTextField(
                    text: Binding(
                        get: { viewModel.categoryLimits[category] ?? "" },
                        set: { newValue in
                            // Validate: don't allow exceeding budget
                            if let value = Double(newValue), totalBudget > 0 {
                                if value <= maxAllowed || newValue.isEmpty {
                                    viewModel.categoryLimits[category] = newValue
                                }
                            } else {
                                viewModel.categoryLimits[category] = newValue
                            }
                        }
                    ),
                    placeholder: "0",
                    placeholderColor: UIColor(Color.accentYellow.opacity(0.3)),
                    textColor: .white,
                    fontSize: 16,
                    fontWeight: .semibold,
                    keyboardType: .decimalPad,
                    textAlignment: .right
                )
                .frame(width: 70)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.08))
            )
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    BudgetSetupView(viewModel: BudgetViewModel(), isPresented: .constant(true))
}
