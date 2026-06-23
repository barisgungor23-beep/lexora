import SwiftUI

struct PremiumDetailsView: View {
    let word: Word

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Premium notes")
                    .font(.lexoraCaption)
                    .foregroundStyle(LexoraColors.secondaryText)
                    .textCase(.uppercase)
                    .tracking(1.2)

                Text("A deeper reading")
                    .font(.lexoraHeadline)
                    .foregroundStyle(LexoraColors.primaryText)
            }

            Divider()
                .overlay(LexoraColors.border)

            DetailRow(title: "Full meaning", text: word.fullMeaning)
            DetailRow(title: "Cultural note", text: word.culturalNote)
            DetailRow(title: "Origin note", text: word.originNote)
            DetailRow(title: "Usage note", text: word.usageNote)
            DetailRow(title: "Related feeling", text: word.relatedFeeling)
        }
        .lexoraCard(background: LexoraColors.cardBackgroundSoft)
    }
}

private struct DetailRow: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.lexoraCaption)
                .foregroundStyle(LexoraColors.secondaryText)
                .textCase(.uppercase)
            Text(text)
                .font(.lexoraBody)
                .foregroundStyle(LexoraColors.primaryText)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
