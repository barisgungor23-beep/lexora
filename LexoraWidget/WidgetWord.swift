import Foundation

enum WidgetPremiumAccess {
    private static let appGroupIdentifier = "group.com.baris.Lexora"
    private static let sharedPremiumKey = "phaseOneMockPremiumEnabled"

    static var hasPremium: Bool {
        UserDefaults(suiteName: appGroupIdentifier)?.bool(forKey: sharedPremiumKey) ?? false
    }
}

struct WidgetWord: Codable {
    let id: String
    let word: String
    let language: String
    let pronunciation: String?
    let shortMeaning: String
    let fullMeaning: String
    let culturalNote: String
    let originNote: String
    let usageNote: String
    let relatedFeeling: String
    let category: String
    let isPremiumDetail: Bool

    static let placeholder = WidgetWord(
        id: "placeholder",
        word: "Lexora",
        language: "World words",
        pronunciation: nil,
        shortMeaning: "Discover today's word.",
        fullMeaning: "",
        culturalNote: "",
        originNote: "",
        usageNote: "",
        relatedFeeling: "",
        category: "",
        isPremiumDetail: false
    )

    static func today(date: Date = Date()) -> WidgetWord {
        let words = loadWords()
        guard !words.isEmpty else { return placeholder }

        let calendar = Calendar.current
        let referenceDate = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)) ?? Date(timeIntervalSince1970: 0)
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: referenceDate), to: calendar.startOfDay(for: date)).day ?? 0
        return words[abs(days) % words.count]
    }

    private static func loadWords() -> [WidgetWord] {
        guard let url = Bundle.main.url(forResource: "words", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let words = try? JSONDecoder().decode([WidgetWord].self, from: data) else {
            return []
        }
        return words
    }
}
