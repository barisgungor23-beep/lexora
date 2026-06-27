import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    @Published var isEnabled: Bool {
        didSet { defaults.set(isEnabled, forKey: enabledKey) }
    }

    @Published var notificationDate: Date {
        didSet { defaults.set(notificationDate, forKey: timeKey) }
    }

    @Published var isPracticeReminderEnabled: Bool {
        didSet { defaults.set(isPracticeReminderEnabled, forKey: practiceEnabledKey) }
    }

    @Published var practiceReminderDate: Date {
        didSet { defaults.set(practiceReminderDate, forKey: practiceTimeKey) }
    }

    private let defaults: UserDefaults
    private let enabledKey = "dailyNotificationEnabled"
    private let timeKey = "dailyNotificationTime"
    private let notificationID = "lexora.daily.word"
    private let practiceEnabledKey = "practiceNotificationEnabled"
    private let practiceTimeKey = "practiceNotificationTime"
    private let practiceNotificationID = "lexora.daily.practice"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.isEnabled = defaults.bool(forKey: enabledKey)
        self.notificationDate = defaults.object(forKey: timeKey) as? Date ?? Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
        self.isPracticeReminderEnabled = defaults.bool(forKey: practiceEnabledKey)
        self.practiceReminderDate = defaults.object(forKey: practiceTimeKey) as? Date ?? Calendar.current.date(from: DateComponents(hour: 19, minute: 0)) ?? Date()
    }

    func updateSchedule(using word: Word?) async {
        if isEnabled {
            await requestAndSchedule(word: word)
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
        }
    }

    func updatePracticeReminderSchedule() async {
        if isPracticeReminderEnabled {
            await requestAndSchedulePracticeReminder()
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [practiceNotificationID])
        }
    }

    private func requestAndSchedule(word: Word?) async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            guard granted else {
                isEnabled = false
                return
            }

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])

            let content = UNMutableNotificationContent()
            content.title = "Today's word: \(word?.word ?? "Lexora")"
            content.body = word?.shortMeaning ?? "Open Lexora for today's word."
            content.sound = .default

            let components = Calendar.current.dateComponents([.hour, .minute], from: notificationDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }

    private func requestAndSchedulePracticeReminder() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            guard granted else {
                isPracticeReminderEnabled = false
                return
            }

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [practiceNotificationID])

            let content = UNMutableNotificationContent()
            content.title = "Today’s Practice"
            content.body = "10 words. One quiet challenge."
            content.sound = .default

            let components = Calendar.current.dateComponents([.hour, .minute], from: practiceReminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: practiceNotificationID, content: content, trigger: trigger)
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule Practice reminder: \(error)")
        }
    }
}
