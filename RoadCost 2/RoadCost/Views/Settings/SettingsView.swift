import SwiftUI
import Photos
import AVFoundation

struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showingClearDataAlert = false
    @State private var showingBudget = false
    @State private var showingRecurring = false
    @State private var showingBudgetAlerts = false
    @State private var showingDailyReminder = false
    @State private var exportURL: URL? = nil
    @State private var exportItem: ExportItem? = nil
    
    @StateObject private var roadcostPhotoManager = RoadCostProfilePhotoManager.shared
    @State private var roadcostShowingPhotoSourceDialog = false
    @State private var roadcostShowingImagePicker = false
    @State private var roadcostImagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var roadcostSelectedImage: UIImage?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.backgroundDark.ignoresSafeArea()
                AnimatedGradientMeshView()
                    .opacity(0.5)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    Text("More")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(GlassBackground(cornerRadius: 0))
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            roadcostProfileSection
                            
                            planningSection
                            
                            dataSection
                            
                            notificationsSection
                            
                            aboutSection
                        }
                        .padding()
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingBudget) {
                BudgetView()
            }
            .sheet(isPresented: $showingRecurring) {
                RecurringPaymentsListView()
            }
            .sheet(isPresented: $showingBudgetAlerts) {
                BudgetAlertsSettingsView()
            }
            .sheet(isPresented: $showingDailyReminder) {
                DailyReminderSettingsView()
            }
            .alert("Clear All Data", isPresented: $showingClearDataAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will permanently delete all your expenses, incomes, and budget data. This action cannot be undone.")
            }
            .sheet(item: $exportItem) { item in
                ShareSheet(activityItems: [item.url])
            }
            .confirmationDialog("Choose Photo Source", isPresented: $roadcostShowingPhotoSourceDialog, titleVisibility: .visible) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Camera") {
                        roadcostRequestCameraPermission()
                    }
                }
                Button("Photo Library") {
                    roadcostRequestPhotoLibraryPermission()
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $roadcostShowingImagePicker) {
                RoadCostImagePicker(roadcostSelectedImage: $roadcostSelectedImage, roadcostSourceType: roadcostImagePickerSource)
            }
            .onChange(of: roadcostSelectedImage) { _, newValue in
                if let roadcostImage = newValue {
                    roadcostPhotoManager.roadcostSavePhoto(roadcostImage)
                    roadcostSelectedImage = nil
                }
            }
        }
    }
    
    // MARK: - Profile Section
    
    private var roadcostProfileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Profile Photo", icon: "person.crop.circle.fill")
            
            HStack(spacing: 20) {
                if let roadcostPhoto = roadcostPhotoManager.roadcostProfilePhoto {
                    Image(uiImage: roadcostPhoto)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.accentYellow, lineWidth: 2))
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 80, height: 80)
                        Image(systemName: "person.fill")
                            .font(.system(size: 35))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Button {
                        hapticFeedback()
                        roadcostShowingPhotoSourceDialog = true
                    } label: {
                        Text(roadcostPhotoManager.roadcostProfilePhoto == nil ? "Add Photo" : "Change Photo")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.accentYellow.opacity(0.3))
                            .cornerRadius(8)
                    }
                    
                    if roadcostPhotoManager.roadcostProfilePhoto != nil {
                        Button {
                            hapticFeedback()
                            roadcostPhotoManager.roadcostDeletePhoto()
                        } label: {
                            Text("Delete")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
        .padding()
        .background(GlassBackground())
    }
    
    private func roadcostRequestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { roadcostGranted in
            DispatchQueue.main.async {
                if roadcostGranted {
                    roadcostImagePickerSource = .camera
                    roadcostShowingImagePicker = true
                }
            }
        }
    }
    
    private func roadcostRequestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { roadcostStatus in
            DispatchQueue.main.async {
                if roadcostStatus == .authorized || roadcostStatus == .limited {
                    roadcostImagePickerSource = .photoLibrary
                    roadcostShowingImagePicker = true
                }
            }
        }
    }
    
    // MARK: - Planning Section
    
    private var planningSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Planning", icon: "calendar.badge.clock")
            
            SettingsButton(
                title: "Budget",
                subtitle: "Set monthly limits and track spending",
                icon: "target",
                iconColor: Color.accentYellow
            ) {
                showingBudget = true
            }
            
            SettingsButton(
                title: "Recurring Payments",
                subtitle: "Manage subscriptions and bills",
                icon: "repeat.circle.fill",
                iconColor: .purple
            ) {
                showingRecurring = true
            }
        }
        .padding()
        .background(GlassBackground())
    }
    
    // MARK: - Data Section
    
    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Data", icon: "externaldrive.fill")
            
            // Export CSV
            SettingsButton(
                title: "Export to CSV",
                subtitle: "Export all your data",
                icon: "square.and.arrow.up",
                iconColor: .blue
            ) {
                exportData()
            }
            
            // Clear Data
            SettingsButton(
                title: "Clear All Data",
                subtitle: "Delete all expenses, incomes, and budgets",
                icon: "trash",
                iconColor: .red
            ) {
                showingClearDataAlert = true
            }
        }
        .padding()
        .background(GlassBackground())
    }
    
    // MARK: - Notifications Section
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Notifications", icon: "bell.fill")
            
            SettingsButton(
                title: "Budget Alerts",
                subtitle: "Configure budget warnings",
                icon: "exclamationmark.triangle.fill",
                iconColor: .orange
            ) {
                showingBudgetAlerts = true
            }
            
            SettingsButton(
                title: "Daily Reminder",
                subtitle: "Set time and message",
                icon: "clock.fill",
                iconColor: .purple
            ) {
                showingDailyReminder = true
            }
        }
        .padding()
        .background(GlassBackground())
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "About", icon: "info.circle.fill")
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("RoadCost")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Version 1.0")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                Spacer()
                Image(systemName: "wallet.pass.fill")
                    .font(.largeTitle)
                    .foregroundStyle(Color.accentYellow)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
        .padding()
        .background(GlassBackground())
    }
    
    // MARK: - Helpers
    
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color.accentYellow)
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
        }
    }
    
    private func exportData() {
        // Load all data
        let expenses = DataManager.shared.loadExpenses()
        let incomes = DataManager.shared.loadIncomes()
        let savingsGoals = DataManager.shared.loadSavingsGoals()
        let savingsTransactions = DataManager.shared.loadAllSavingsTransactions()
        let recurringPayments = DataManager.shared.loadRecurringPayments()
        let budget = DataManager.shared.loadBudget()
        
        // Debug: Print data counts
        print("📊 Export Data Counts:")
        print("  Expenses: \(expenses.count)")
        print("  Incomes: \(incomes.count)")
        print("  Savings Goals: \(savingsGoals.count)")
        if !savingsGoals.isEmpty {
            for goal in savingsGoals {
                print("    - \(goal.name): \(goal.currentAmount)/\(goal.targetAmount)")
            }
        }
        print("  Savings Transactions: \(savingsTransactions.count)")
        print("  Recurring Payments: \(recurringPayments.count)")
        print("  Budget: \(budget != nil ? "Yes" : "No")")
        
        // Build CSV content with all data types
        // Always create a file, even if empty
        var csvContent = "RoadCost - Data Export\n"
        csvContent += "Export Date: \(DateFormatter.shortDate.string(from: Date()))\n"
        csvContent += "Export Time: \(DateFormatter.timeOnly.string(from: Date()))\n\n"
        
        // Expenses section
        csvContent += "=== EXPENSES ===\n"
        if !expenses.isEmpty {
            csvContent += "Date,Category,Amount,Note\n"
            for expense in expenses.sorted(by: { $0.date > $1.date }) {
                let date = DateFormatter.shortDate.string(from: expense.date)
                let category = expense.category.displayName
                let amount = String(format: "%.2f", expense.amount)
                let note = expense.note?.replacingOccurrences(of: ",", with: ";") ?? ""
                csvContent += "\(date),\(category),\(amount),\(note)\n"
            }
        } else {
            csvContent += "No expenses recorded.\n"
        }
        csvContent += "\n"
        
        // Incomes section
        csvContent += "=== INCOMES ===\n"
        if !incomes.isEmpty {
            csvContent += "Date,Category,Amount,Note\n"
            for income in incomes.sorted(by: { $0.date > $1.date }) {
                let date = DateFormatter.shortDate.string(from: income.date)
                let category = income.category.displayName
                let amount = String(format: "%.2f", income.amount)
                let note = income.note?.replacingOccurrences(of: ",", with: ";") ?? ""
                csvContent += "\(date),\(category),\(amount),\(note)\n"
            }
        } else {
            csvContent += "No incomes recorded.\n"
        }
        csvContent += "\n"
        
        // Savings Goals section
        csvContent += "=== SAVINGS GOALS ===\n"
        if !savingsGoals.isEmpty {
            csvContent += "Name,Target Amount,Current Amount,Progress %,Created Date,Deadline\n"
            for goal in savingsGoals {
                let createdDate = DateFormatter.shortDate.string(from: goal.createdAt)
                let deadline = goal.deadline != nil ? DateFormatter.shortDate.string(from: goal.deadline!) : ""
                let progress = String(format: "%.2f", goal.progress * 100)
                csvContent += "\(goal.name),\(String(format: "%.2f", goal.targetAmount)),\(String(format: "%.2f", goal.currentAmount)),\(progress),\(createdDate),\(deadline)\n"
            }
        } else {
            csvContent += "No savings goals created.\n"
        }
        csvContent += "\n"
        
        // Savings Transactions section
        csvContent += "=== SAVINGS TRANSACTIONS ===\n"
        if !savingsTransactions.isEmpty {
            csvContent += "Date,Goal Name,Type,Amount,Note\n"
            let goalMap = Dictionary(uniqueKeysWithValues: savingsGoals.map { ($0.id, $0.name) })
            for transaction in savingsTransactions.sorted(by: { $0.date > $1.date }) {
                let date = DateFormatter.shortDate.string(from: transaction.date)
                let goalName = goalMap[transaction.goalId] ?? "Unknown"
                let type = transaction.isDeposit ? "Deposit" : "Withdrawal"
                let amount = String(format: "%.2f", transaction.amount)
                let note = transaction.note?.replacingOccurrences(of: ",", with: ";") ?? ""
                csvContent += "\(date),\(goalName),\(type),\(amount),\(note)\n"
            }
        } else {
            csvContent += "No savings transactions recorded.\n"
        }
        csvContent += "\n"
        
        // Recurring Payments section
        csvContent += "=== RECURRING PAYMENTS ===\n"
        if !recurringPayments.isEmpty {
            csvContent += "Name,Category,Amount,Frequency,Start Date,Next Payment,Active\n"
            for payment in recurringPayments {
                let startDate = DateFormatter.shortDate.string(from: payment.startDate)
                let nextDate = DateFormatter.shortDate.string(from: payment.nextPaymentDate)
                let category = payment.category.displayName
                csvContent += "\(payment.name),\(category),\(String(format: "%.2f", payment.amount)),\(payment.frequency.rawValue),\(startDate),\(nextDate),\(payment.isActive ? "Yes" : "No")\n"
            }
        } else {
            csvContent += "No recurring payments configured.\n"
        }
        csvContent += "\n"
        
        // Budget section
        csvContent += "=== BUDGET ===\n"
        if let budget = budget {
            if let monthlyBudget = budget.monthlyBudget {
                csvContent += "Monthly Budget,\(String(format: "%.2f", monthlyBudget))\n"
            }
            if !budget.categoryLimits.isEmpty {
                csvContent += "Category Limits\n"
                csvContent += "Category,Limit\n"
                for (category, limit) in budget.categoryLimits {
                    csvContent += "\(category),\(String(format: "%.2f", limit))\n"
                }
            } else {
                csvContent += "No category limits set.\n"
            }
        } else {
            csvContent += "No budget configured.\n"
        }
        
        // Save to file - use documents directory for better reliability
        let dateString = DateFormatter.shortDate.string(from: Date()).replacingOccurrences(of: "/", with: "-")
        let timeString = DateFormatter.timeOnly.string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let fileName = "RoadCost_Export_\(dateString)_\(timeString).csv"
        
        // Use documents directory instead of temp directory for better reliability
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        print("📄 CSV Content Length: \(csvContent.count) characters")
        print("📁 Attempting to save file: \(fileName)")
        print("📁 File path: \(fileURL.path)")
        
        do {
            // Remove old file if exists
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            
            // Write file
            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
            
            // Verify file was created
            if FileManager.default.fileExists(atPath: fileURL.path) {
                let fileSize = try FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? Int64 ?? 0
                print("✅ File created successfully at: \(fileURL.path)")
                print("✅ File size: \(fileSize) bytes")
                
                // Set export URL and create export item
                exportURL = fileURL
                exportItem = ExportItem(url: fileURL)
                print("🔗 exportURL set to: \(exportURL?.path ?? "nil")")
                print("📦 exportItem created with URL: \(fileURL.path)")
            } else {
                print("❌ File was not created at path: \(fileURL.path)")
                // Try temp directory as fallback
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
                exportURL = tempURL
                exportItem = ExportItem(url: tempURL)
                print("🔗 exportURL set to: \(exportURL?.path ?? "nil")")
                print("✅ File created at fallback location: \(tempURL.path)")
            }
        } catch {
            print("❌ Error exporting CSV: \(error.localizedDescription)")
            print("❌ Error details: \(error)")
            // Try temp directory as last resort
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            do {
                try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
                exportURL = tempURL
                exportItem = ExportItem(url: tempURL)
                print("🔗 exportURL set to: \(exportURL?.path ?? "nil")")
                print("✅ File created at temp location: \(tempURL.path)")
            } catch {
                print("❌ Failed to create file: \(error.localizedDescription)")
            }
        }
    }
    
    private func clearAllData() {
        do {
            try DataManager.shared.clearAllData()
            RoadCostReceiptPhotoManager.shared.roadcostDeleteAllPhotos()
            roadcostPhotoManager.roadcostDeletePhoto()
            hasCompletedOnboarding = false
            hapticNotification(type: .success)
        } catch {
            print("Error clearing data: \(error)")
        }
    }
}

// MARK: - Settings Button

struct SettingsButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            hapticFeedback()
            action()
        }) {
            HStack {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .foregroundStyle(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

// MARK: - Settings Toggle Row

struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let key: String
    
    @AppStorage private var isOn: Bool
    
    init(title: String, subtitle: String, icon: String, iconColor: Color, key: String) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.key = key
        self._isOn = AppStorage(wrappedValue: true, key)
    }
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.accentYellow)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Export Item

struct ExportItem: Identifiable {
    let id = UUID()
    let url: URL
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
}
