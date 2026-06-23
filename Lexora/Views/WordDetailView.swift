import SwiftUI

struct WordDetailView: View {
    @EnvironmentObject private var favorites: FavoritesManager
    @EnvironmentObject private var premium: PremiumManager
    @State private var favoriteLimitMessage: String?
    let word: Word

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                WordCard(
                    word: word,
                    isFavorite: favorites.isFavorite(word),
                    isHero: false,
                    onFavoriteTapped: { handleFavoriteToggle() }
                )

                if let favoriteLimitMessage {
                    Text(favoriteLimitMessage)
                        .font(.lexoraFootnote)
                        .foregroundStyle(LexoraColors.secondaryText)
                        .padding(.horizontal, 4)
                }

                if premium.hasPremium {
                    PremiumDetailsView(word: word)
                } else {
                    PaywallTeaserView()
                }
            }
            .padding()
        }
        .lexoraPageBackground()
        .navigationTitle(word.word)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(LexoraColors.pageBackground, for: .navigationBar)
    }

    private func handleFavoriteToggle() {
        let result = favorites.toggle(word, hasPremium: premium.hasPremium)
        favoriteLimitMessage = result == .blockedAtFreeLimit ? "Free can save up to \(LexoraPremiumRules.freeFavoritesLimit) words." : nil
    }
}
