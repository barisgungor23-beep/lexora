import Foundation

final class WordRepository: ObservableObject {
    @Published private(set) var words: [Word] = []

    init() {
        loadWords()
    }

    func loadWords() {
        guard let url = Bundle.main.url(forResource: "words", withExtension: "json") else {
            words = []
            return
        }

        do {
            let data = try Data(contentsOf: url)
            words = try JSONDecoder().decode([Word].self, from: data)
        } catch {
            words = []
            print("Failed to load words.json: \(error)")
        }
    }
}
