import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var repository: WordRepository
    @EnvironmentObject private var favorites: FavoritesManager
    @EnvironmentObject private var premium: PremiumManager

    private var favoriteWords: [Word] {
        repository.words.filter { favorites.favoriteIDs.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if favoriteWords.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "heart")
                            .font(.system(size: 34))
                            .foregroundStyle(LexoraColors.accent)

                        Text("No favorites yet")
                            .font(.lexoraTitle)

                        Text("Tap the heart on any word to keep it here for later reading.")
                            .font(.lexoraBody)
                            .foregroundStyle(LexoraColors.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(24)
                    .lexoraPageBackground()
                } else {
                    List(favoriteWords) { word in
                        NavigationLink {
                            WordDetailView(word: word)
                        } label: {
                            WordRowCard(word: word, isLocked: word.isPremiumDetail && !premium.hasPremium, showsFavorite: true)
                        }
                        .listRowBackground(LexoraColors.cardBackground)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                favorites.toggle(word)
                            } label: {
                                Label("Remove", systemImage: "heart.slash")
                            }
                        }
                    }
                    .font(.lexoraBody)
                    .lexoraPageBackground()
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(LexoraColors.pageBackground, for: .navigationBar)
        }
        .tint(LexoraColors.accent)
    }
}
