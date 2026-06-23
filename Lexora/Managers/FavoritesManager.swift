import Foundation

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

    func toggle(_ word: Word) {
        if favoriteIDs.contains(word.id) {
            favoriteIDs.remove(word.id)
        } else {
            favoriteIDs.insert(word.id)
        }
        defaults.set(Array(favoriteIDs).sorted(), forKey: key)
    }
}
