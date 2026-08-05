import Foundation
import UserNotifications

/// Schedules the single daily local reminder. Copy is gentle and never guilt-based —
/// no streak-loss language, no pressure.
enum ReminderScheduler {
    static let identifier = "daily-checkin-reminder"

    static func requestAuthorizationIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        default:
            return false
        }
    }

    /// Schedules (or replaces) the daily reminder at the given time-of-day.
    static func schedule(at time: DateComponents) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "The Room"
        content.body = "A minute for yourself?"
        content.sound = .default

        var trigger = DateComponents()
        trigger.hour = time.hour
        trigger.minute = time.minute

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)
        )

        try? await center.add(request)
    }

    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
