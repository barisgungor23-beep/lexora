import Foundation

enum PracticeRepositoryError: LocalizedError {
    case missingFallbackResource
    case invalidCatalog(String)

    var errorDescription: String? {
        switch self {
        case .missingFallbackResource:
            return "fallback-practice.json could not be found."
        case .invalidCatalog(let message):
            return message
        }
    }
}

struct PracticeRepository {
    static let remoteCatalogURL = URL(string: "https://barisgungor23-beep.github.io/lexora/docs/practice/daily-practice.json")!

    private let decoder: JSONDecoder
    private let calendar: Calendar

    init(decoder: JSONDecoder = JSONDecoder(), calendar: Calendar = .current) {
        self.decoder = decoder
        self.calendar = calendar
    }

    func loadBundledFallbackCatalog() throws -> PracticeCatalog {
        guard let url = Bundle.main.url(forResource: "fallback-practice", withExtension: "json") else {
            throw PracticeRepositoryError.missingFallbackResource
        }

        let data = try Data(contentsOf: url)
        let catalog = try decoder.decode(PracticeCatalog.self, from: data)
        try validate(catalog)
        return catalog
    }

    func fetchRemoteCatalog() async throws -> PracticeCatalog {
        let (data, _) = try await URLSession.shared.data(from: Self.remoteCatalogURL)
        let catalog = try decoder.decode(PracticeCatalog.self, from: data)
        try validate(catalog)
        return catalog
    }

    func bestAvailableCatalog() async -> PracticeCatalog? {
        if let remote = try? await fetchRemoteCatalog() {
            return remote
        }

        return try? loadBundledFallbackCatalog()
    }

    func practiceSet(for date: Date = Date(), in catalog: PracticeCatalog) -> PracticeSet? {
        let today = Self.dayFormatter.string(from: date)

        if let exactSet = catalog.sets.first(where: { $0.date == today }) {
            return exactSet
        }

        return catalog.sets.sorted { $0.date < $1.date }.last
    }

    func validate(_ catalog: PracticeCatalog, knownWordIDs: Set<String>? = nil) throws {
        guard catalog.version > 0 else {
            throw PracticeRepositoryError.invalidCatalog("Practice catalog version must be present and greater than zero.")
        }

        guard !catalog.updatedAt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw PracticeRepositoryError.invalidCatalog("Practice catalog updatedAt must be present.")
        }

        guard !catalog.sets.isEmpty else {
            throw PracticeRepositoryError.invalidCatalog("Practice catalog must include at least one set.")
        }

        var setDates = Set<String>()
        var questionIDs = Set<String>()

        for set in catalog.sets {
            guard Self.isValidDateString(set.date) else {
                throw PracticeRepositoryError.invalidCatalog("Practice set date must use YYYY-MM-DD: \(set.date)")
            }

            guard setDates.insert(set.date).inserted else {
                throw PracticeRepositoryError.invalidCatalog("Practice set dates must be unique: \(set.date)")
            }

            guard set.questions.count == 10 else {
                throw PracticeRepositoryError.invalidCatalog("Practice set \(set.date) must include exactly 10 questions.")
            }

            var wordIDsInSet = Set<String>()

            for question in set.questions {
                guard !question.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    throw PracticeRepositoryError.invalidCatalog("Practice question id must be present.")
                }

                guard questionIDs.insert(question.id).inserted else {
                    throw PracticeRepositoryError.invalidCatalog("Practice question ids must be unique: \(question.id)")
                }

                guard !question.wordId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                      !question.word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                      !question.language.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                      !question.question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    throw PracticeRepositoryError.invalidCatalog("Practice question \(question.id) has an empty required field.")
                }

                guard wordIDsInSet.insert(question.wordId).inserted else {
                    throw PracticeRepositoryError.invalidCatalog("Practice set \(set.date) repeats wordId \(question.wordId).")
                }

                guard knownWordIDs?.contains(question.wordId) ?? true else {
                    throw PracticeRepositoryError.invalidCatalog("Practice question \(question.id) references unknown wordId \(question.wordId).")
                }

                guard question.choices.count == 4 else {
                    throw PracticeRepositoryError.invalidCatalog("Practice question \(question.id) must include exactly 4 choices.")
                }

                guard question.choices.allSatisfy({ !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
                    throw PracticeRepositoryError.invalidCatalog("Practice question \(question.id) includes an empty choice.")
                }

                guard question.correctIndex >= 0, question.correctIndex < question.choices.count else {
                    throw PracticeRepositoryError.invalidCatalog("Practice question \(question.id) has an invalid correctIndex.")
                }
            }
        }
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static func isValidDateString(_ value: String) -> Bool {
        dayFormatter.date(from: value) != nil
    }
}
