import Foundation

enum PracticeSessionState: Equatable {
    case notStarted
    case inProgress
    case completed
}

struct PracticeReviewItem: Identifiable, Equatable {
    let id: String
    let word: String
    let selectedAnswer: String
    let correctAnswer: String
    let isCorrect: Bool
}

private struct PracticeAttempt: Codable, Equatable {
    let date: String
    var setDate: String
    var currentQuestionIndex: Int
    var selectedAnswers: [String: Int]
    var isCompleted: Bool
    var score: Int?
}

@MainActor
final class PracticeSessionManager: ObservableObject {
    @Published private(set) var practiceSet: PracticeSet?
    @Published private(set) var attemptState: PracticeSessionState = .notStarted
    @Published private(set) var currentQuestionIndex = 0
    @Published private(set) var selectedAnswers: [String: Int] = [:]
    @Published private(set) var score: Int?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: PracticeRepository
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let storageKey = "lexoraDailyPracticeAttempt"
    private var attempt: PracticeAttempt?

    init(
        repository: PracticeRepository = PracticeRepository(),
        defaults: UserDefaults = .standard
    ) {
        self.repository = repository
        self.defaults = defaults
        loadPersistedAttempt()
        publishAttemptState()
    }

    var todayDateString: String {
        Self.dayFormatter.string(from: Date())
    }

    var currentQuestion: PracticeQuestion? {
        guard let practiceSet, currentQuestionIndex < practiceSet.questions.count else { return nil }
        return practiceSet.questions[currentQuestionIndex]
    }

    var questionCount: Int {
        practiceSet?.questions.count ?? 10
    }

    var selectedAnswerForCurrentQuestion: Int? {
        guard let currentQuestion else { return nil }
        return selectedAnswers[currentQuestion.id]
    }

    var scoreLabel: String {
        Self.scoreLabel(for: score ?? 0)
    }

    var reviewItems: [PracticeReviewItem] {
        guard let practiceSet else { return [] }

        return practiceSet.questions.map { question in
            let selectedIndex = selectedAnswers[question.id]
            let selectedAnswer = selectedIndex.flatMap { question.choices[safe: $0] } ?? "Not answered"
            let correctAnswer = question.choices[safe: question.correctIndex] ?? ""

            return PracticeReviewItem(
                id: question.id,
                word: question.word,
                selectedAnswer: selectedAnswer,
                correctAnswer: correctAnswer,
                isCorrect: selectedIndex == question.correctIndex
            )
        }
    }

    func loadPracticeIfNeeded() async {
        guard practiceSet == nil else {
            resetIfNeededForNewDay()
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let catalog = await repository.bestAvailableCatalog()
        let loadedSet = catalog.flatMap { repository.practiceSet(for: Date(), in: $0) } ?? Self.safeLocalFallbackSet
        practiceSet = loadedSet
        resetIfNeededForNewDay()
    }

    func startOrContinue() {
        guard let practiceSet else { return }
        resetIfNeededForNewDay()

        if attempt == nil {
            attempt = PracticeAttempt(
                date: todayDateString,
                setDate: practiceSet.date,
                currentQuestionIndex: 0,
                selectedAnswers: [:],
                isCompleted: false,
                score: nil
            )
            saveAttempt()
        }

        publishAttemptState()
    }

    func selectAnswer(_ index: Int) {
        guard let question = currentQuestion, attemptState != .completed else { return }
        selectedAnswers[question.id] = index
        attempt?.selectedAnswers = selectedAnswers
        saveAttempt()
    }

    func advance() {
        guard let practiceSet, attemptState != .completed else { return }

        if currentQuestionIndex >= practiceSet.questions.count - 1 {
            completeAttempt()
            return
        }

        currentQuestionIndex += 1
        self.attempt?.currentQuestionIndex = currentQuestionIndex
        saveAttempt()
        publishAttemptState()
    }

    static func scoreLabel(for score: Int) -> String {
        switch score {
        case 0...3:
            return "Beginning the archive"
        case 4...6:
            return "Careful observer"
        case 7...8:
            return "Word keeper"
        default:
            return "Lexora scholar"
        }
    }

    private func resetIfNeededForNewDay() {
        guard let attempt else {
            publishAttemptState()
            return
        }

        if attempt.date != todayDateString {
            self.attempt = nil
            selectedAnswers = [:]
            currentQuestionIndex = 0
            score = nil
            publishAttemptState()
        }
    }

    private func completeAttempt() {
        guard let practiceSet else { return }

        let finalScore = practiceSet.questions.reduce(0) { total, question in
            total + (selectedAnswers[question.id] == question.correctIndex ? 1 : 0)
        }

        score = finalScore
        currentQuestionIndex = min(currentQuestionIndex, max(practiceSet.questions.count - 1, 0))
        attempt?.currentQuestionIndex = currentQuestionIndex
        attempt?.selectedAnswers = selectedAnswers
        attempt?.isCompleted = true
        attempt?.score = finalScore
        saveAttempt()
        publishAttemptState()
    }

    private func loadPersistedAttempt() {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? decoder.decode(PracticeAttempt.self, from: data) else {
            return
        }

        attempt = decoded
    }

    private func saveAttempt() {
        guard let attempt, let data = try? encoder.encode(attempt) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private func publishAttemptState() {
        guard let attempt, attempt.date == todayDateString else {
            attemptState = .notStarted
            currentQuestionIndex = 0
            selectedAnswers = [:]
            score = nil
            return
        }

        currentQuestionIndex = attempt.currentQuestionIndex
        selectedAnswers = attempt.selectedAnswers
        score = attempt.score
        attemptState = attempt.isCompleted ? .completed : .inProgress
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let safeLocalFallbackSet = PracticeSet(
        date: "fallback",
        questions: [
            PracticeQuestion(id: "safe-1", wordId: "petrichor", word: "Petrichor", language: "English", question: "What does this word most closely describe?", choices: ["The smell after rain on dry earth", "A quiet winter sunrise", "A letter kept for years", "The sound of distant bells"], correctIndex: 0),
            PracticeQuestion(id: "safe-2", wordId: "komorebi", word: "Komorebi", language: "Japanese", question: "What image is commonly associated with this word?", choices: ["Sunlight filtering through leaves", "A path across fresh snow", "A room before dawn", "The first page of a book"], correctIndex: 0),
            PracticeQuestion(id: "safe-3", wordId: "hiraeth", word: "Hiraeth", language: "Welsh", question: "Which feeling fits this word best?", choices: ["A deep longing for home or place", "Sudden joy after good news", "Calm focus before work", "Fear of losing time"], correctIndex: 0),
            PracticeQuestion(id: "safe-4", wordId: "meraki", word: "Meraki", language: "Greek", question: "What does this word often suggest?", choices: ["Doing something with soul and care", "Walking without a destination", "Remembering a childhood sound", "Waiting through a storm"], correctIndex: 0),
            PracticeQuestion(id: "safe-5", wordId: "sobremesa", word: "Sobremesa", language: "Spanish", question: "When might this word be used?", choices: ["Lingering in conversation after a meal", "Packing before a long journey", "Reading beside a window", "Finding a familiar street"], correctIndex: 0),
            PracticeQuestion(id: "safe-6", wordId: "gezellig", word: "Gezellig", language: "Dutch", question: "Which mood does this word often carry?", choices: ["Warmth, comfort, and easy togetherness", "A solemn public ceremony", "A restless urge to travel", "The sharpness of cold air"], correctIndex: 0),
            PracticeQuestion(id: "safe-7", wordId: "ubuntu", word: "Ubuntu", language: "Nguni languages", question: "What is this word commonly connected with?", choices: ["Shared humanity and connection", "A private garden at night", "A brief moment of surprise", "The silence before music"], correctIndex: 0),
            PracticeQuestion(id: "safe-8", wordId: "saudade", word: "Saudade", language: "Portuguese", question: "Which phrase best fits this word?", choices: ["Tender longing for someone or something absent", "A celebration after harvest", "A small act of courage", "The feeling of entering a new city"], correctIndex: 0),
            PracticeQuestion(id: "safe-9", wordId: "firgun", word: "Firgun", language: "Hebrew", question: "What can this word describe?", choices: ["Generous happiness for another person's joy", "A careful morning routine", "The ache of unfinished work", "A quiet moment by the sea"], correctIndex: 0),
            PracticeQuestion(id: "safe-10", wordId: "mamihlapinatapai", word: "Mamihlapinatapai", language: "Yaghan", question: "What kind of moment is often associated with this word?", choices: ["A shared look when both people hope the other will act", "A song remembered from childhood", "A peaceful walk after rain", "A promise made at sunrise"], correctIndex: 0)
        ]
    )
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
