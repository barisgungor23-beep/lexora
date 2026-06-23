import SwiftUI

struct WordDetailView: View {
    @EnvironmentObject private var favorites: FavoritesManager
    @EnvironmentObject private var premium: PremiumManager
    let word: Word

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                WordCard(
                    word: word,
                    isFavorite: favorites.isFavorite(word),
                    isHero: false,
                    onFavoriteTapped: { favorites.toggle(word) }
                )

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
}
