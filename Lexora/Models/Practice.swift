import Foundation

struct PracticeCatalog: Codable, Equatable {
    let version: Int
    let updatedAt: String
    let sets: [PracticeSet]
}

struct PracticeSet: Identifiable, Codable, Equatable {
    let date: String
    let questions: [PracticeQuestion]

    var id: String { date }
}

struct PracticeQuestion: Identifiable, Codable, Equatable {
    let id: String
    let wordId: String
    let word: String
    let language: String
    let question: String
    let choices: [String]
    let correctIndex: Int
}

