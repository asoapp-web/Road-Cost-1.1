import SwiftUI
import UserNotifications

struct DailyReminderSettingsView: View {
    @AppStorage("dailyReminderEnabled") private var reminderEnabled = false
    @AppStorage("dailyReminderHour") private var reminderHour = 20
    @AppStorage("dailyReminderMinute") private var reminderMinute = 0
    @AppStorage("dailyReminderText") private var reminderText = "Don't forget to log today's expenses!"
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTime = Date()
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
                    Text("Daily Reminder")
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
                                Text("Enable Daily Reminder")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Spacer()
                                Toggle("", isOn: $reminderEnabled)
                                    .tint(Color.accentYellow)
                                    .onChange(of: reminderEnabled) { _, enabled in
                                        if enabled {
                                            Task {
                                                let status = await NotificationService.shared.checkAuthorizationStatus()
                                                await MainActor.run {
                                                    if status == .denied {
                                                        showPermissionAlert = true
                                                        reminderEnabled = false
                                                    } else {
                                                        requestNotificationPermission {
                                                            scheduleReminder()
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            NotificationService.shared.cancelDailyReminder()
                                        }
                                    }
                            }
                            
                            Text("Get a daily reminder to track your expenses")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .padding()
                        .background(GlassBackground())
                        
                        // Time Picker - always visible
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundStyle(reminderEnabled ? Color.accentYellow : Color.accentYellow.opacity(0.5))
                                Text("Reminder Time")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                            
                            if !reminderEnabled {
                                Text("Enable reminder above to set time")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.5))
                                    .padding(.vertical, 8)
                            }
                            
                            DatePicker("", selection: Binding(
                                get: {
                                    let calendar = Calendar.current
                                    var components = DateComponents()
                                    components.hour = reminderHour
                                    components.minute = reminderMinute
                                    return calendar.date(from: components) ?? Date()
                                },
                                set: { newDate in
                                    let calendar = Calendar.current
                                    let components = calendar.dateComponents([.hour, .minute], from: newDate)
                                    reminderHour = components.hour ?? 20
                                    reminderMinute = components.minute ?? 0
                                    if reminderEnabled {
                                        scheduleReminder()
                                    }
                                }
                            ), displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .colorScheme(.dark)
                            .tint(Color.accentYellow)
                            .disabled(!reminderEnabled)
                            .opacity(reminderEnabled ? 1 : 0.6)
                        }
                        .padding()
                        .background(GlassBackground())
                        
                        // Message - always visible
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "text.bubble.fill")
                                    .foregroundStyle(reminderEnabled ? Color.accentYellow : Color.accentYellow.opacity(0.5))
                                Text("Reminder Message")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                            
                            if !reminderEnabled {
                                Text("Enable reminder above to customize message")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.5))
                                    .padding(.bottom, 4)
                            }
                            
                            HStack {
                                CustomTextField(
                                    text: $reminderText,
                                    placeholder: "Enter reminder message",
                                    placeholderColor: UIColor(Color.accentYellow.opacity(0.5)),
                                    textColor: .white,
                                    fontSize: 16,
                                    fontWeight: .regular,
                                    keyboardType: .default,
                                    textAlignment: .left
                                )
                                .disabled(!reminderEnabled)
                                .onChange(of: reminderText) { _, _ in
                                    if reminderEnabled {
                                        scheduleReminder()
                                    }
                                }
                            }
                            .padding()
                            .background(GlassBackground())
                            .opacity(reminderEnabled ? 1 : 0.6)
                        }
                        .padding()
                        .background(GlassBackground())
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            let calendar = Calendar.current
            var components = DateComponents()
            components.hour = reminderHour
            components.minute = reminderMinute
            selectedTime = calendar.date(from: components) ?? Date()
            checkNotificationPermission()
        }
        .alert("Notification Permission Required", isPresented: $showPermissionAlert) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {
                reminderEnabled = false
            }
        } message: {
            Text("Please enable notifications in Settings to use daily reminders. Go to Settings > RoadCost > Notifications and enable them.")
        }
    }
    
    private func checkNotificationPermission() {
        Task {
            let status = await NotificationService.shared.checkAuthorizationStatus()
            await MainActor.run {
                notificationStatus = status
                if status == .denied && reminderEnabled {
                    showPermissionAlert = true
                    reminderEnabled = false
                }
            }
        }
    }
    
    private func requestNotificationPermission(completion: (() -> Void)? = nil) {
        guard !hasRequestedPermission else {
            completion?()
            return
        }
        hasRequestedPermission = true
        
        Task {
            let granted = await NotificationService.shared.requestAuthorization()
            if granted {
                await MainActor.run {
                    completion?()
                }
            } else {
                await MainActor.run {
                    reminderEnabled = false
                }
            }
        }
    }
    
    private func scheduleReminder() {
        NotificationService.shared.scheduleDailyReminder(
            at: reminderHour,
            minute: reminderMinute,
            message: reminderText.isEmpty ? nil : reminderText
        )
    }
}

#Preview {
    DailyReminderSettingsView()
}
