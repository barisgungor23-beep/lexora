import Foundation
import StoreKit
import UIKit

@MainActor
final class ReviewPromptManager: ObservableObject {
    private let defaults: UserDefaults
    private let calendar: Calendar

    private let launchCountKey = "reviewPromptLaunchCount"
    private let completedPracticeCountKey = "reviewPromptCompletedPracticeCount"
    private let lastPracticeCompletionDateKey = "reviewPromptLastPracticeCompletionDate"
    private let lastPromptDateKey = "reviewPromptLastPromptDate"
    private let promptedVersionKey = "reviewPromptPromptedVersion"
    private let lastPracticeScoreKey = "reviewPromptLastPracticeScore"

    init(defaults: UserDefaults = .standard, calendar: Calendar = .current) {
        self.defaults = defaults
        self.calendar = calendar
    }

    func registerAppLaunch() {
        defaults.set(defaults.integer(forKey: launchCountKey) + 1, forKey: launchCountKey)
    }

    func requestAfterPracticeIfAppropriate(score: Int, total: Int) {
        let completionDate = Self.dayFormatter.string(from: Date())
        guard defaults.string(forKey: lastPracticeCompletionDateKey) != completionDate else {
            log("Skipped: today's Practice completion was already counted.")
            return
        }

        let completedPracticeCount = defaults.integer(forKey: completedPracticeCountKey) + 1
        defaults.set(completedPracticeCount, forKey: completedPracticeCountKey)
        defaults.set(completionDate, forKey: lastPracticeCompletionDateKey)
        defaults.set(score, forKey: lastPracticeScoreKey)

        guard total > 0 else {
            log("Skipped: Practice total was unavailable.")
            return
        }

        let requiredScore = min(7, total)
        guard score >= requiredScore else {
            log("Skipped: score \(score)/\(total) is below threshold.")
            return
        }

        guard completedPracticeCount >= 2 else {
            log("Skipped: only \(completedPracticeCount) completed Practice session.")
            return
        }

        guard defaults.integer(forKey: launchCountKey) > 1 else {
            log("Skipped: first app launch.")
            return
        }

        let appVersion = Self.appVersion
        guard defaults.string(forKey: promptedVersionKey) != appVersion else {
            log("Skipped: already requested for version \(appVersion).")
            return
        }

        if let lastPromptDate = defaults.object(forKey: lastPromptDateKey) as? Date,
           let earliestNextPrompt = calendar.date(byAdding: .day, value: 90, to: lastPromptDate),
           Date() < earliestNextPrompt {
            log("Skipped: last prompt was less than 90 days ago.")
            return
        }

        guard let scene = activeWindowScene else {
            log("Skipped: no active window scene.")
            return
        }

        SKStoreReviewController.requestReview(in: scene)
        defaults.set(Date(), forKey: lastPromptDateKey)
        defaults.set(appVersion, forKey: promptedVersionKey)
        log("Requested App Store review prompt.")
    }

    private var activeWindowScene: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
    }

    private static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private func log(_ message: String) {
        #if DEBUG
        print("ReviewPromptManager: \(message)")
        #endif
    }
}
