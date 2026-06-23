import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var repository: WordRepository
    @EnvironmentObject private var favorites: FavoritesManager
    @EnvironmentObject private var premium: PremiumManager

    private let dailyService = DailyWordService()

    var body: some View {
        NavigationStack {
            Group {
                if let word = dailyService.word(words: repository.words) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 22) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Today")
                                    .font(.lexoraCaption)
                                    .foregroundStyle(LexoraColors.secondaryText)
                                    .textCase(.uppercase)
                                    .tracking(1.4)

                                Text("Word of the day")
                                    .font(.lexoraTitle)
                                    .foregroundStyle(LexoraColors.primaryText)
                            }

                            WordCard(
                                word: word,
                                isFavorite: favorites.isFavorite(word),
                                isHero: true,
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
                } else {
                    ContentUnavailableView("No words found", systemImage: "text.book.closed", description: Text("Add words to words.json to begin."))
                        .font(.lexoraBody)
                        .foregroundStyle(LexoraColors.primaryText)
                        .lexoraPageBackground()
                }
            }
            .navigationTitle("Lexora")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(LexoraColors.pageBackground, for: .navigationBar)
        }
        .tint(LexoraColors.accent)
    }
}
