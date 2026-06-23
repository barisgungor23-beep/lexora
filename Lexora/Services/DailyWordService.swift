import Foundation

struct DailyWordService {
    private let calendar: Calendar
    private let referenceDate: Date

    init(calendar: Calendar = .current) {
        self.calendar = calendar
        self.referenceDate = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1)) ?? Date(timeIntervalSince1970: 0)
    }

    func word(for date: Date = Date(), words: [Word]) -> Word? {
        guard !words.isEmpty else { return nil }
        let start = calendar.startOfDay(for: referenceDate)
        let today = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: start, to: today).day ?? 0
        let index = abs(days) % words.count
        return words[index]
    }
}
