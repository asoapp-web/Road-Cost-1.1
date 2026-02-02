import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to RoadCost!",
            description: "Your personal finance manager\n\nTrack expenses, manage income, set budgets, and save for your goals - all in one beautiful app.",
            icon: "wallet.pass.fill",
            background: AnyView(AnimatedGradientMeshView()),
            features: [
                "Track every expense with categories",
                "Monitor your income and balance",
                "Set savings goals",
                "Beautiful statistics and charts"
            ]
        ),
        OnboardingPage(
            title: "Track Expenses & Income",
            description: "Record all your financial transactions\n\n• Add expenses with categories, notes, and dates\n• Track income from different sources\n• Search and filter your transactions\n• Export data to CSV",
            icon: "list.bullet.clipboard.fill",
            background: AnyView(ParticleSystemView()),
            features: [
                "Quick expense entry with FAB button",
                "9 built-in categories + custom ones",
                "Recurring payments automation",
                "Full transaction history"
            ]
        ),
        OnboardingPage(
            title: "Statistics & Insights",
            description: "Understand your spending patterns\n\n• Visual pie charts by category\n• Line charts showing trends over time\n• See where your money goes\n• Track spending by period (day/week/month)",
            icon: "chart.pie.fill",
            background: AnyView(WaveAnimationView()),
            features: [
                "Category distribution charts",
                "Time-based spending trends",
                "Top spending categories",
                "Period filters (day/week/month/all)"
            ]
        ),
        OnboardingPage(
            title: "Budget & Savings",
            description: "Take control of your finances\n\n• Set monthly budget limits\n• Configure category-specific limits\n• Auto-split budget across categories\n• Create savings goals with deadlines\n• Track progress with visual indicators",
            icon: "target",
            background: AnyView(OrbitalCirclesView()),
            features: [
                "Monthly budget tracking",
                "Category limit warnings",
                "Savings goals with progress",
                "Budget alerts and notifications"
            ]
        ),
        OnboardingPage(
            title: "Recurring Payments",
            description: "Never miss a subscription\n\n• Add recurring bills and subscriptions\n• Automatic expense creation\n• Track monthly recurring costs\n• Get reminders before due dates",
            icon: "repeat.circle.fill",
            background: AnyView(OrbitalCirclesView()),
            features: [
                "Daily, weekly, monthly, yearly",
                "Auto-create expenses",
                "Payment reminders",
                "Monthly total calculation"
            ]
        )
    ]
    
    var body: some View {
        if hasCompletedOnboarding {
            MainTabView()
        } else {
            ZStack {
                // Background - extends into safe area
                pages[currentPage].background
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .id(currentPage)
                
                VStack {
                    HStack {
                        Spacer()
                        Button("Skip") {
                            completeOnboarding()
                        }
                        .foregroundStyle(.white.opacity(0.8))
                        .padding()
                    }
                    
                    Spacer()
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 24) {
                            Image(systemName: pages[currentPage].icon)
                                .font(.system(size: 70))
                                .foregroundStyle(Color.accentYellow)
                                .padding(.top, 20)
                            
                            Text(pages[currentPage].title)
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white)
                            
                            Text(pages[currentPage].description)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white.opacity(0.9))
                                .lineSpacing(4)
                                .padding(.horizontal)
                            
                            // Features list
                            if let features = pages[currentPage].features {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(features, id: \.self) { feature in
                                        HStack(alignment: .top, spacing: 12) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color.accentYellow)
                                                .font(.subheadline)
                                            
                                            Text(feature)
                                                .font(.subheadline)
                                                .foregroundStyle(.white.opacity(0.8))
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            Spacer()
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(16)
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                    }
                    .frame(maxHeight: 500)
                    .glassCard()
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .id(currentPage)
                    
                    Spacer()
                    
                    // Controls
                    HStack {
                        // Page Indicator
                        HStack(spacing: 8) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                Circle()
                                    .fill(currentPage == index ? Color.accentYellow : Color.white.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        
                        Spacer()
                        
                        // Next Button
                        Button(action: nextPage) {
                            HStack {
                                Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.right")
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.accentYellow)
                            .cornerRadius(24)
                            .foregroundStyle(.white)
                        }
                    }
                    .padding(30)
                }
            }
            .animation(.easeInOut, value: currentPage)
        }
    }
    
    func nextPage() {
        if currentPage < pages.count - 1 {
            currentPage += 1
        } else {
            completeOnboarding()
        }
    }
    
    func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
    let background: AnyView
    let features: [String]?
    
    init(title: String, description: String, icon: String, background: AnyView, features: [String]? = nil) {
        self.title = title
        self.description = description
        self.icon = icon
        self.background = background
        self.features = features
    }
}
