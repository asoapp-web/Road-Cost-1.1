import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Budget Notifications
    
    func scheduleBudgetWarning(percentage: Double, budget: Double, spent: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Budget Alert"
        content.body = "You've used \(Int(percentage * 100))% of your monthly budget (\(spent.formattedCurrency) of \(budget.formattedCurrency))"
        content.sound = .default
        content.categoryIdentifier = "BUDGET_WARNING"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "budget-warning-\(Int(percentage * 100))",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling budget notification: \(error)")
            }
        }
    }
    
    func scheduleCategoryLimitWarning(category: ExpenseCategory, percentage: Double, limit: Double, spent: Double) {
        let content = UNMutableNotificationContent()
        content.title = "\(category.displayName) Budget Alert"
        content.body = "You've used \(Int(percentage * 100))% of your \(category.displayName) limit (\(spent.formattedCurrency) of \(limit.formattedCurrency))"
        content.sound = .default
        content.categoryIdentifier = "CATEGORY_LIMIT_WARNING"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "category-limit-\(category.rawValue)-\(Int(percentage * 100))",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling category limit notification: \(error)")
            }
        }
    }
    
    // MARK: - Daily Reminder
    
    func scheduleDailyReminder(at hour: Int = 20, minute: Int = 0, message: String? = nil) {
        // Remove existing daily reminders
        cancelDailyReminder()
        
        let content = UNMutableNotificationContent()
        content.title = "Track Your Expenses"
        content.body = message ?? "Don't forget to log today's expenses!"
        content.sound = .default
        content.categoryIdentifier = "DAILY_REMINDER"
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily-reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily reminder: \(error)")
            }
        }
    }
    
    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-reminder"])
    }
    
    // MARK: - Recurring Payment Reminder
    
    func scheduleRecurringPaymentReminder(payment: RecurringPayment, daysBefore: Int = 1) {
        let content = UNMutableNotificationContent()
        content.title = "Upcoming Payment"
        content.body = "\(payment.name) (\(payment.formattedAmount)) is due tomorrow"
        content.sound = .default
        content.categoryIdentifier = "RECURRING_PAYMENT"
        
        guard let reminderDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: payment.nextPaymentDate) else {
            return
        }
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "recurring-\(payment.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling recurring payment reminder: \(error)")
            }
        }
    }
    
    // MARK: - Cancel All
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
