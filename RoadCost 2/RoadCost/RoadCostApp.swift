import SwiftUI

@main
struct RoadCostApp: App {
    @StateObject private var roadcostFlowController = RoadCostFlowController.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                roadcostContentView
                    .opacity(roadcostFlowController.roadcostIsLoading ? 0 : 1)
                
                if roadcostFlowController.roadcostIsLoading {
                    RoadCostLoadingView()
                        .transition(.opacity)
                        .zIndex(10)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: roadcostFlowController.roadcostIsLoading)
        }
    }
    
    @ViewBuilder
    private var roadcostContentView: some View {
        switch roadcostFlowController.roadcostDisplayMode {
        case .preparing, .original:
            ZStack {
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(2)
                } else if !hasCompletedOnboarding {
                    OnboardingView()
                        .transition(.opacity)
                        .zIndex(1)
                } else {
                    MainTabView()
                        .transition(.opacity)
                        .zIndex(0)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSplash = false
                    }
                }
            }
        case .webContent:
            RoadCostDisplayView()
        }
    }
}
