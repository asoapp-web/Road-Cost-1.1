import SwiftUI

struct AddSavingsGoalView: View {
    @StateObject private var viewModel = AddSavingsGoalViewModel()
    @Binding var isPresented: Bool
    var onSave: (SavingsGoal) -> Void
    
    var body: some View {
        ZStack {
            Color.backgroundDark.ignoresSafeArea()
            AnimatedGradientMeshView()
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
                    Text("New Savings Goal")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: save) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(viewModel.isValid ? Color.accentYellow : .white.opacity(0.3))
                    }
                    .disabled(!viewModel.isValid)
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Goal Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Goal Name")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.leading)
                            
                            HStack {
                                Image(systemName: "textformat")
                                    .foregroundStyle(Color.accentYellow)
                                
                                CustomTextField(
                                    text: $viewModel.name,
                                    placeholder: "e.g., New iPhone, Vacation",
                                    placeholderColor: UIColor(Color.accentYellow.opacity(0.5)),
                                    textColor: .white,
                                    fontSize: 17,
                                    fontWeight: .medium,
                                    keyboardType: .default,
                                    textAlignment: .left
                                )
                            }
                            .padding()
                            .background(GlassBackground())
                        }
                        
                        // Target Amount
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Amount")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.leading)
                            
                            AmountTextField(text: $viewModel.targetAmount)
                        }
                        
                        // Icon Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose Icon")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.leading)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                                ForEach(SavingsGoal.presetIcons, id: \.self) { icon in
                                    Button(action: {
                                        viewModel.selectedIcon = icon
                                        hapticFeedback()
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(viewModel.selectedIcon == icon ? Color(hex: viewModel.selectedColor) : Color.white.opacity(0.1))
                                                .frame(width: 50, height: 50)
                                            
                                            Image(systemName: icon)
                                                .font(.title3)
                                                .foregroundStyle(viewModel.selectedIcon == icon ? .white : .white.opacity(0.7))
                                        }
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: viewModel.selectedIcon == icon ? 2 : 0)
                                        )
                                    }
                                }
                            }
                            .padding()
                            .background(GlassBackground())
                        }
                        
                        // Color Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose Color")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.leading)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                                ForEach(SavingsGoal.presetColors, id: \.self) { colorHex in
                                    Button(action: {
                                        viewModel.selectedColor = colorHex
                                        hapticFeedback()
                                    }) {
                                        Circle()
                                            .fill(Color(hex: colorHex))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: viewModel.selectedColor == colorHex ? 3 : 0)
                                            )
                                            .scaleEffect(viewModel.selectedColor == colorHex ? 1.1 : 1.0)
                                    }
                                }
                            }
                            .padding()
                            .background(GlassBackground())
                        }
                        
                        // Deadline Toggle
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle(isOn: $viewModel.hasDeadline) {
                                HStack {
                                    Image(systemName: "calendar.badge.clock")
                                        .foregroundStyle(Color.accentYellow)
                                    Text("Set Deadline")
                                        .foregroundStyle(.white)
                                }
                            }
                            .tint(Color.accentYellow)
                            
                            if viewModel.hasDeadline {
                                DatePicker("", selection: $viewModel.deadline, in: Date()..., displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .colorScheme(.dark)
                                    .tint(Color.accentYellow)
                            }
                        }
                        .padding()
                        .background(GlassBackground())
                        
                        // Preview
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Preview")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                            
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: viewModel.selectedColor).opacity(0.2))
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: viewModel.selectedIcon)
                                        .font(.title)
                                        .foregroundStyle(Color(hex: viewModel.selectedColor))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(viewModel.name.isEmpty ? "Goal Name" : viewModel.name)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    
                                    if let amount = Double(viewModel.targetAmount), amount > 0 {
                                        Text("Target: \(amount.formattedCurrency)")
                                            .font(.subheadline)
                                            .foregroundStyle(Color(hex: viewModel.selectedColor))
                                    }
                                }
                                
                                Spacer()
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
    }
    
    private func save() {
        let goal = viewModel.createGoal()
        onSave(goal)
        isPresented = false
    }
}

#Preview {
    AddSavingsGoalView(isPresented: .constant(true)) { _ in }
}
