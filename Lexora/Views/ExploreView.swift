import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var repository: WordRepository
    @EnvironmentObject private var premium: PremiumManager
    @State private var selectedCategory = "All"

    private var categories: [String] {
        ["All"] + Array(Set(repository.words.map(\.category))).sorted()
    }

    private var filteredWords: [Word] {
        selectedCategory == "All" ? repository.words : repository.words.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                                .font(.lexoraBody)
                                .tag(category)
                        }
                    }
                    Text("\(filteredWords.count) \(filteredWords.count == 1 ? "word" : "words")")
                        .font(.lexoraFootnote)
                        .foregroundStyle(LexoraColors.secondaryText)
                }
                .listRowBackground(LexoraColors.cardBackground)

                ForEach(filteredWords) { word in
                    NavigationLink {
                        WordDetailView(word: word)
                    } label: {
                        WordRowCard(word: word, isLocked: word.isPremiumDetail && !premium.hasPremium)
                    }
                    .listRowBackground(LexoraColors.cardBackground)
                }
            }
            .font(.lexoraBody)
            .lexoraPageBackground()
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(LexoraColors.pageBackground, for: .navigationBar)
        }
        .tint(LexoraColors.accent)
    }
}
