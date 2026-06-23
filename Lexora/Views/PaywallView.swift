import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var premium: PremiumManager

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Image(systemName: "sparkle.magnifyingglass")
                .font(.system(size: 44))
                .foregroundStyle(LexoraColors.accent)

            Text("Unlock Lexora Premium")
                .font(.lexoraTitle)

            Text("Premium expands the daily word experience without changing the calm, local-first app.")
                .font(.lexoraBody)
                .foregroundStyle(LexoraColors.secondaryText)
                .lineSpacing(4)

            VStack(alignment: .leading, spacing: 12) {
                PremiumBenefitRow(icon: "books.vertical", text: "Full word archive")
                PremiumBenefitRow(icon: "text.book.closed", text: "Deeper notes")
                PremiumBenefitRow(icon: "heart", text: "Unlimited favorites")
                PremiumBenefitRow(icon: "rectangle.inset.filled", text: "Daily word widget")
                PremiumBenefitRow(icon: "square.and.arrow.up", text: "Share as Card")
            }
            .lexoraCard(background: LexoraColors.cardBackgroundSoft, padding: 16)

            Button {
                premium.handlePurchaseTapped()
            } label: {
                Text("Purchase unavailable in Phase 1")
                    .font(.lexoraHeadline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button("Restore deferred to Phase 2") {
                premium.handleRestoreTapped()
            }
            .font(.lexoraBody)

            if let status = premium.statusMessage {
                Text(status)
                    .font(.lexoraFootnote)
                    .foregroundStyle(LexoraColors.secondaryText)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(LexoraColors.cardBackgroundSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(LexoraColors.border, lineWidth: 0.7)
                    )
            }

            Spacer()
        }
        .padding()
        .lexoraPageBackground()
        .navigationTitle("Premium")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(LexoraColors.pageBackground, for: .navigationBar)
    }
}

private struct PremiumBenefitRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.callout.weight(.semibold))
                .foregroundStyle(LexoraColors.accent)
                .frame(width: 22)

            Text(text)
                .font(.lexoraBody)
                .foregroundStyle(LexoraColors.primaryText)
        }
    }
}

struct PaywallTeaserView: View {
    var body: some View {
        NavigationLink {
            PaywallView()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "lock.fill")
                    .font(.title3)
                    .foregroundStyle(LexoraColors.accent)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Deeper notes are part of Premium")
                        .font(.lexoraHeadline)
                    Text("Open Premium to preview the full meaning, cultural note, origin note, usage note, and related feeling.")
                        .font(.lexoraSubheadline)
                        .foregroundStyle(LexoraColors.secondaryText)
                }
                Spacer()
            }
            .lexoraCard(background: LexoraColors.cardBackgroundSoft, padding: 18)
        }
        .buttonStyle(.plain)
    }
}
