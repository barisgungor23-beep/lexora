import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var repository: WordRepository
    @EnvironmentObject private var premium: PremiumManager
    @State private var selectedCategory = "All"

    private var visibleArchive: [Word] {
        premium.hasPremium ? repository.words : Array(repository.words.prefix(LexoraPremiumRules.freeExploreLimit))
    }

    private var categories: [String] {
        ["All"] + Array(Set(visibleArchive.map(\.category))).sorted()
    }

    private var filteredWords: [Word] {
        selectedCategory == "All" ? visibleArchive : visibleArchive.filter { $0.category == selectedCategory }
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
                    Text(countText)
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

                if !premium.hasPremium {
                    Section {
                        NavigationLink {
                            PaywallView()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(LexoraColors.accent)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Unlock the full archive")
                                        .font(.lexoraHeadline)
                                        .foregroundStyle(LexoraColors.primaryText)
                                    Text("Free browsing includes the first \(LexoraPremiumRules.freeExploreLimit) words.")
                                        .font(.lexoraSubheadline)
                                        .foregroundStyle(LexoraColors.secondaryText)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listRowBackground(LexoraColors.cardBackground)
                }
            }
            .font(.lexoraBody)
            .lexoraPageBackground()
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(LexoraColors.pageBackground, for: .navigationBar)
            .onChange(of: premium.hasPremium) { _, _ in
                if !categories.contains(selectedCategory) {
                    selectedCategory = "All"
                }
            }
        }
        .tint(LexoraColors.accent)
    }

    private var countText: String {
        let wordLabel = filteredWords.count == 1 ? "word" : "words"
        guard !premium.hasPremium else {
            return "\(filteredWords.count) \(wordLabel)"
        }
        return "\(filteredWords.count) \(wordLabel) shown from the free archive"
    }
}
