import Foundation

enum FavoriteToggleResult {
    case added
    case removed
    case blockedAtFreeLimit
}

final class FavoritesManager: ObservableObject {
    @Published private(set) var favoriteIDs: Set<String> = []

    private let defaults: UserDefaults
    private let key = "favoriteWordIDs"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        favoriteIDs = Set(defaults.stringArray(forKey: key) ?? [])
    }

    func isFavorite(_ word: Word) -> Bool {
        favoriteIDs.contains(word.id)
    }

    @discardableResult
    func toggle(_ word: Word, hasPremium: Bool = true) -> FavoriteToggleResult {
        if favoriteIDs.contains(word.id) {
            favoriteIDs.remove(word.id)
            persist()
            return .removed
        }

        guard hasPremium || favoriteIDs.count < LexoraPremiumRules.freeFavoritesLimit else {
            return .blockedAtFreeLimit
        }

        favoriteIDs.insert(word.id)
        persist()
        return .added
    }

    func canAddFavorite(hasPremium: Bool) -> Bool {
        hasPremium || favoriteIDs.count < LexoraPremiumRules.freeFavoritesLimit
    }

    private func persist() {
        defaults.set(Array(favoriteIDs).sorted(), forKey: key)
    }
}
