import SwiftUI

struct ShareCardView: View {
    let word: Word

    var body: some View {
        ZStack {
            LexoraColors.pageBackground

            RoundedRectangle(cornerRadius: 46, style: .continuous)
                .fill(LexoraColors.cardBackground)
                .padding(54)
                .overlay(
                    RoundedRectangle(cornerRadius: 46, style: .continuous)
                        .stroke(LexoraColors.border.opacity(0.78), lineWidth: 3)
                        .padding(54)
                )

            VStack(spacing: 34) {
                Text("Lexora")
                    .font(.custom("Times New Roman", size: 38))
                    .textCase(.uppercase)
                    .tracking(8)
                    .foregroundStyle(LexoraColors.secondaryText)

                Spacer(minLength: 70)

                VStack(spacing: 18) {
                    Text(word.category)
                        .font(.custom("Times New Roman", size: 28))
                        .textCase(.uppercase)
                        .tracking(5)
                        .foregroundStyle(LexoraColors.secondaryText)

                    Text(word.word)
                        .font(.custom("Times New Roman", size: 112))
                        .minimumScaleFactor(0.58)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(LexoraColors.primaryText)

                    Text(word.language)
                        .font(.custom("Times New Roman", size: 36))
                        .foregroundStyle(LexoraColors.secondaryText)

                    if let pronunciation = word.pronunciation, !pronunciation.isEmpty {
                        Text(pronunciation)
                            .font(.custom("Times New Roman", size: 34))
                            .foregroundStyle(LexoraColors.secondaryText)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(LexoraColors.cardBackgroundSoft)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(LexoraColors.border.opacity(0.78), lineWidth: 2)
                            )
                    }
                }

                Text(word.shortMeaning)
                    .font(.custom("Times New Roman", size: 44))
                    .lineSpacing(10)
                    .minimumScaleFactor(0.72)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(LexoraColors.primaryText)
                    .padding(.horizontal, 72)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 70)

                Text("word of the day")
                    .font(.custom("Times New Roman", size: 30))
                    .textCase(.uppercase)
                    .tracking(4)
                    .foregroundStyle(LexoraColors.secondaryText)
            }
            .padding(.horizontal, 72)
            .padding(.vertical, 76)
        }
        .frame(width: 1080, height: 1080)
    }
}
