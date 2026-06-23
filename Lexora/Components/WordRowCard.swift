import SwiftUI

struct WordRowCard: View {
    let word: Word
    let isLocked: Bool
    var showsFavorite: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 8) {
                    Text(word.word)
                        .font(.lexoraHeadline)
                        .foregroundStyle(LexoraColors.primaryText)
                        .lineLimit(1)

                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(LexoraColors.secondaryText)
                            .accessibilityLabel("Premium details locked")
                    }

                    if showsFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(LexoraColors.favorite)
                            .accessibilityLabel("Favorite")
                    }
                }

                Text(word.language)
                    .font(.lexoraCaption)
                    .foregroundStyle(LexoraColors.secondaryText)
                    .textCase(.uppercase)
                    .tracking(0.8)

                Text(word.shortMeaning)
                    .font(.lexoraSubheadline)
                    .foregroundStyle(LexoraColors.secondaryText)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            Text(word.category)
                .font(.lexoraFootnote)
                .foregroundStyle(LexoraColors.secondaryText)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(LexoraColors.cardBackgroundSoft)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(LexoraColors.border, lineWidth: 0.7)
                )
        }
        .padding(.vertical, 6)
    }
}
