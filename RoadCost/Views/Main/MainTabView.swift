import SwiftUI

struct MainTabView: View {
    @State private var selection = 0
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(Color.backgroundDark.opacity(0.9))
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selection) {
            ExpensesListView()
                .tabItem {
                    Label("Expenses", systemImage: "list.bullet.rectangle.fill")
                }
                .tag(0)
            
            IncomeListView()
                .tabItem {
                    Label("Income", systemImage: "arrow.down.circle.fill")
                }
                .tag(1)
            
            SavingsView()
                .tabItem {
                    Label("Savings", systemImage: "banknote.fill")
                }
                .tag(2)
            
            StatisticsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.pie.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
                .tag(4)
        }
        .accentColor(Color.accentYellow)
        .onAppear {
            // Ensure no unwanted animations on appear
        }
    }
}
