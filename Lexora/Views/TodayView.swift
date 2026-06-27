import SwiftUI
import UIKit

struct TodayView: View {
    @EnvironmentObject private var repository: WordRepository
    @EnvironmentObject private var favorites: FavoritesManager
    @EnvironmentObject private var premium: PremiumManager
    @EnvironmentObject private var practice: PracticeSessionManager
    @State private var shareCardItem: ShareCardItem?
    @State private var shareErrorMessage: String?
    @State private var favoriteLimitMessage: String?

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
                                onFavoriteTapped: { handleFavoriteToggle(for: word) }
                            )

                            NavigationLink {
                                PracticeView()
                            } label: {
                                DailyPracticeCard()
                            }
                            .buttonStyle(.plain)

                            if let favoriteLimitMessage {
                                Text(favoriteLimitMessage)
                                    .font(.lexoraFootnote)
                                    .foregroundStyle(LexoraColors.secondaryText)
                                    .padding(.horizontal, 4)
                            }

                            if premium.hasPremium {
                                Button {
                                    shareCard(for: word)
                                } label: {
                                    ShareCardActionLabel(isLocked: false)
                                }
                                .buttonStyle(.plain)
                            } else {
                                NavigationLink {
                                    PaywallView()
                                } label: {
                                    ShareCardActionLabel(isLocked: true)
                                }
                                .buttonStyle(.plain)
                            }

                            if let shareErrorMessage {
                                Text(shareErrorMessage)
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
        .task {
            await practice.loadPracticeIfNeeded()
        }
        .sheet(item: $shareCardItem) { item in
            ShareSheet(activityItems: [item.image])
        }
    }

    @MainActor
    private func shareCard(for word: Word) {
        shareErrorMessage = nil

        guard let image = ShareCardRenderer.image(for: word) else {
            shareErrorMessage = "Could not create the share card. Please try again."
            return
        }

        shareCardItem = ShareCardItem(image: image)
    }

    private func handleFavoriteToggle(for word: Word) {
        let result = favorites.toggle(word, hasPremium: premium.hasPremium)
        favoriteLimitMessage = result == .blockedAtFreeLimit ? "Free can save up to \(LexoraPremiumRules.freeFavoritesLimit) words." : nil
    }
}

private struct DailyPracticeCard: View {
    @EnvironmentObject private var practice: PracticeSessionManager

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: iconName)
                .font(.title3.weight(.semibold))
                .foregroundStyle(LexoraColors.accent)
                .frame(width: 34, height: 34)
                .background(LexoraColors.cardBackground)
                .clipShape(Circle())
                .overlay(Circle().stroke(LexoraColors.border.opacity(0.72), lineWidth: 0.8))

            VStack(alignment: .leading, spacing: 5) {
                Text("Today’s Practice")
                    .font(.lexoraHeadline)
                    .foregroundStyle(LexoraColors.primaryText)

                Text(subtitle)
                    .font(.lexoraFootnote)
                    .foregroundStyle(LexoraColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                if practice.attemptState == .completed {
                    Text(practice.scoreLabel)
                        .font(.lexoraCallout)
                        .foregroundStyle(LexoraColors.accent)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 10)

            Text(buttonTitle)
                .font(.lexoraSubheadline)
                .foregroundStyle(LexoraColors.accent)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(LexoraColors.cardBackground)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(LexoraColors.border.opacity(0.72), lineWidth: 0.8))
        }
        .lexoraCard(background: LexoraColors.cardBackgroundSoft, padding: 16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Today’s Practice, \(subtitle), \(buttonTitle)")
    }

    private var subtitle: String {
        if practice.isLoading && practice.practiceSet == nil {
            return "Preparing today’s word practice."
        }

        switch practice.attemptState {
        case .notStarted:
            return "10 words. One quiet challenge."
        case .inProgress:
            return "Continue today’s word practice."
        case .completed:
            return "Today’s score: \(practice.score ?? 0)/\(practice.questionCount)"
        }
    }

    private var buttonTitle: String {
        switch practice.attemptState {
        case .notStarted:
            return "Start"
        case .inProgress:
            return "Continue"
        case .completed:
            return "View Result"
        }
    }

    private var iconName: String {
        switch practice.attemptState {
        case .notStarted:
            return "book.closed"
        case .inProgress:
            return "pencil"
        case .completed:
            return "checkmark.seal"
        }
    }
}

private struct ShareCardItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

private struct ShareCardActionLabel: View {
    let isLocked: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isLocked ? "lock.fill" : "square.and.arrow.up")
                .font(.callout.weight(.semibold))
            VStack(alignment: .leading, spacing: 3) {
                Text("Share as Card")
                    .font(.lexoraHeadline)
                if isLocked {
                    Text("Premium unlocks vintage share cards.")
                        .font(.lexoraFootnote)
                        .foregroundStyle(LexoraColors.secondaryText)
                }
            }
            Spacer()
        }
        .foregroundStyle(LexoraColors.accent)
        .lexoraCard(background: LexoraColors.cardBackgroundSoft, padding: 16)
    }
}
