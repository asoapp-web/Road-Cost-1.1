import SwiftUI
import UserNotifications

struct BudgetAlertsSettingsView: View {
    @AppStorage("budgetAlertsEnabled") private var alertsEnabled = true
    @AppStorage("budgetAlertThreshold") private var threshold = 0.75
    @Environment(\.dismiss) private var dismiss
    @State private var hasRequestedPermission = false
    @State private var showPermissionAlert = false
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    
    var body: some View {
        ZStack {
            Color.backgroundDark.ignoresSafeArea()
            AnimatedGradientMeshView()
                .opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Spacer()
                    Text("Budget Alerts")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding()
                .background(GlassBackground(cornerRadius: 0))
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Enable/Disable
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundStyle(Color.accentYellow)
                                Text("Enable Budget Alerts")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Spacer()
                                Toggle("", isOn: $alertsEnabled)
                                    .tint(Color.accentYellow)
                                    .onChange(of: alertsEnabled) { _, enabled in
                                        if enabled {
                                            Task {
                                                let status = await NotificationService.shared.checkAuthorizationStatus()
                                                await MainActor.run {
                                                    if status == .denied {
                                                        showPermissionAlert = true
                                                        alertsEnabled = false
                                                    } else if status == .notDetermined {
                                                        requestNotificationPermission()
                                                    }
                                                }
                                            }
                                        }
                                    }
                            }
                            
                            Text("Get notified when you're approaching or exceeding your budget limits")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .padding()
                        .background(GlassBackground())
                        
                        // Threshold
                        if alertsEnabled {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "percent")
                                        .foregroundStyle(Color.accentYellow)
                                    Text("Alert Threshold")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                }
                                
                                Text("Alert me when I've used \(Int(threshold * 100))% of my budget")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.8))
                                
                                Slider(value: $threshold, in: 0.5...1.0, step: 0.05)
                                    .tint(Color.accentYellow)
                                
                                HStack {
                                    Text("50%")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.6))
                                    Spacer()
                                    Text("100%")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                            .padding()
                            .background(GlassBackground())
                        }
                        
                        // Info
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundStyle(.blue)
                                Text("How it works")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                            
                            Text("Budget alerts will notify you when:\n• You reach the threshold percentage of your monthly budget\n• You exceed a category limit\n• You're close to your budget limit")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .padding()
                        .background(GlassBackground())
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            checkNotificationPermission()
        }
        .alert("Notification Permission Required", isPresented: $showPermissionAlert) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {
                alertsEnabled = false
            }
        } message: {
            Text("Please enable notifications in Settings to use budget alerts. Go to Settings > RoadCost > Notifications and enable them.")
        }
    }
    
    private func checkNotificationPermission() {
        Task {
            let status = await NotificationService.shared.checkAuthorizationStatus()
            await MainActor.run {
                notificationStatus = status
                if status == .denied && alertsEnabled {
                    showPermissionAlert = true
                    alertsEnabled = false
                } else if status == .notDetermined {
                    requestNotificationPermission()
                }
            }
        }
    }
    
    private func requestNotificationPermission() {
        guard !hasRequestedPermission else { return }
        hasRequestedPermission = true
        
        Task {
            let granted = await NotificationService.shared.requestAuthorization()
            await MainActor.run {
                if !granted {
                    showPermissionAlert = true
                    alertsEnabled = false
                }
            }
        }
    }
}

#Preview {
    BudgetAlertsSettingsView()
}
