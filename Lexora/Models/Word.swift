import Foundation

struct Word: Identifiable, Codable, Hashable {
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
}
