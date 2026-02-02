import SwiftUI
import Combine

struct SavingsView: View {
    @StateObject private var viewModel = SavingsViewModel()
    @State private var showAddGoal = false
    @State private var selectedGoal: SavingsGoal?
    @State private var showDepositSheet = false
    @State private var depositAmount = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.backgroundDark.ignoresSafeArea()
                ParticleSystemView()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    if viewModel.goals.isEmpty {
                        emptyState
                    } else {
                        goalsList
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
            .sheet(isPresented: $showAddGoal) {
                AddSavingsGoalView(isPresented: $showAddGoal) { goal in
                    viewModel.addGoal(goal)
                }
            }
            .sheet(item: $selectedGoal) { goal in
                SavingsGoalDetailView(goal: goal, viewModel: viewModel, isPresented: Binding(
                    get: { selectedGoal != nil },
                    set: { if !$0 { selectedGoal = nil } }
                ))
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("Savings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            HStack(spacing: 8) {
                Image(systemName: "banknote.fill")
                    .font(.title2)
                    .foregroundStyle(Color.accentYellow)
                
                Text(viewModel.totalSavings.formattedCurrency)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.accentYellow)
            }
            
            Text("Total saved across all goals")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(GlassBackground(cornerRadius: 0))
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.accentYellow.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "banknote.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.accentYellow)
            }
            
            Text("Start Saving!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            Text("Create savings goals and track your progress\ntowards your dreams")
                .font(.body)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button(action: { showAddGoal = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create First Goal")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(Color.accentYellow)
                .foregroundStyle(.white)
                .cornerRadius(25)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Goals List
    
    private var goalsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.goals) { goal in
                    SavingsGoalCard(goal: goal)
                        .onTapGesture {
                            selectedGoal = goal
                            hapticFeedback()
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.deleteGoal(goal)
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
            viewModel.loadGoals()
        }
    }
    
    // MARK: - FAB
    
    private var fabButton: some View {
        Button(action: {
            hapticFeedback()
            showAddGoal = true
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

// MARK: - Savings Goal Card

struct SavingsGoalCard: View {
    let goal: SavingsGoal
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(goal.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: goal.icon)
                        .font(.title2)
                        .foregroundStyle(goal.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name)
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    HStack(spacing: 4) {
                        Text(goal.formattedCurrent)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(goal.color)
                        
                        Text("/ \(goal.formattedTarget)")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                
                Spacer()
                
                // Progress percentage
                ZStack {
                    Circle()
                        .stroke(goal.color.opacity(0.2), lineWidth: 4)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: goal.progress)
                        .stroke(goal.color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                    
                    Text(goal.progress.formattedPercentage)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(goal.color)
                        .frame(width: geometry.size.width * goal.progress, height: 8)
                }
            }
            .frame(height: 8)
            
            // Deadline info
            if let days = goal.daysRemaining {
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text("\(days) days remaining")
                        .font(.caption)
                    
                    Spacer()
                    
                    if let daily = goal.suggestedDailyAmount {
                        Text("Save \(daily.formattedCurrency)/day")
                            .font(.caption)
                            .foregroundStyle(goal.color)
                    }
                }
                .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding()
        .background(GlassBackground())
    }
}

#Preview {
    SavingsView()
}
