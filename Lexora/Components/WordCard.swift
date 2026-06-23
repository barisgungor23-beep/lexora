import SwiftUI

struct WordCard: View {
    let word: Word
    let isFavorite: Bool
    var isHero = false
    let onFavoriteTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: isHero ? 18 : 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(word.category)
                        .font(.lexoraCaption)
                        .foregroundStyle(LexoraColors.secondaryText)
                        .textCase(.uppercase)
                        .tracking(1.2)

                    Text(word.word)
                        .font(isHero ? .lexoraHero : .lexoraDisplay)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)

                    Text(word.language)
                        .font(.lexoraSubheadline)
                        .foregroundStyle(LexoraColors.secondaryText)
                }

                Spacer()

                Button(action: onFavoriteTapped) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title3.weight(.regular))
                        .foregroundStyle(isFavorite ? LexoraColors.favorite : LexoraColors.secondaryText)
                        .frame(width: 44, height: 44)
                        .background(LexoraColors.cardBackgroundSoft)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(LexoraColors.border, lineWidth: 0.8)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isFavorite ? "Remove favorite" : "Add favorite")
            }

            if let pronunciation = word.pronunciation, !pronunciation.isEmpty {
                Text(pronunciation)
                    .font(.lexoraCallout)
                    .foregroundStyle(LexoraColors.secondaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(LexoraColors.cardBackgroundSoft)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(LexoraColors.border, lineWidth: 0.7)
                    )
            }

            Text(word.shortMeaning)
                .font(isHero ? .lexoraTitle : .lexoraHeadline)
                .foregroundStyle(LexoraColors.primaryText)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .lexoraCard(background: isHero ? LexoraColors.cardBackground : LexoraColors.cardBackgroundSoft, padding: isHero ? 24 : 20)
    }
}
