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

    private let defaults: UserDefaults
    private let enabledKey = "dailyNotificationEnabled"
    private let timeKey = "dailyNotificationTime"
    private let notificationID = "lexora.daily.word"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.isEnabled = defaults.bool(forKey: enabledKey)
        self.notificationDate = defaults.object(forKey: timeKey) as? Date ?? Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    }

    func updateSchedule(using word: Word?) async {
        if isEnabled {
            await requestAndSchedule(word: word)
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
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
}
