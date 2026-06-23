import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var premium: PremiumManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                PremiumHeroCard()

                VStack(alignment: .leading, spacing: 12) {
                    PremiumBenefitRow(text: "Full word archive")
                    PremiumBenefitRow(text: "Deeper notes")
                    PremiumBenefitRow(text: "Reflective word stories")
                    PremiumBenefitRow(text: "Unlimited favorites")
                    PremiumBenefitRow(text: "Daily word widget")
                    PremiumBenefitRow(text: "Share as Card")
                }
                .lexoraCard(background: LexoraColors.cardBackgroundSoft, padding: 18)

                VStack(spacing: 10) {
                    Button {
                        // Phase 2 TODO: Replace with RevenueCat package purchase once ASC products exist.
                        premium.handlePurchaseTapped()
                    } label: {
                        Text("Purchases deferred to Phase 2")
                            .font(.lexoraHeadline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 2)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        // Phase 2 TODO: Replace with RevenueCat restorePurchases and entitlement sync.
                        premium.handleRestoreTapped()
                    } label: {
                        Text("Restore deferred to Phase 2")
                            .font(.lexoraBody)
                    }
                }

                Text("RevenueCat will connect here after App Store Connect products are ready.")
                    .font(.lexoraFootnote)
                    .foregroundStyle(LexoraColors.secondaryText)
                    .lineSpacing(3)

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
            }
            .padding()
        }
        .lexoraPageBackground()
        .navigationTitle("Premium")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(LexoraColors.pageBackground, for: .navigationBar)
    }
}

private struct PremiumHeroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Lexora Premium")
                        .font(.lexoraTitle)
                        .foregroundStyle(LexoraColors.primaryText)

                    Text("A deeper daily ritual for the words that stay with you.")
                        .font(.lexoraBody)
                        .foregroundStyle(LexoraColors.secondaryText)
                        .lineSpacing(5)
                }

                Spacer(minLength: 16)

                Image(systemName: "book.closed")
                    .font(.title2.weight(.regular))
                    .foregroundStyle(LexoraColors.accent)
                    .frame(width: 48, height: 48)
                    .background(LexoraColors.cardBackgroundSoft)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(LexoraColors.border, lineWidth: 0.8)
                    )
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Today")
                    .font(.lexoraCaption)
                    .foregroundStyle(LexoraColors.secondaryText)
                    .textCase(.uppercase)
                    .tracking(1.4)

                Text("one word, fully opened")
                    .font(.lexoraHeadline)
                    .foregroundStyle(LexoraColors.primaryText)

                Text("Premium expands each day with full notes, reflective stories, favorites without limits, the widget, and shareable cards.")
                    .font(.lexoraSubheadline)
                    .foregroundStyle(LexoraColors.secondaryText)
                    .lineSpacing(4)
            }
            .padding(16)
            .background(LexoraColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(LexoraColors.border, lineWidth: 0.8)
            )
        }
        .lexoraCard(background: LexoraColors.cardBackground, padding: 20)
    }
}

private struct PremiumBenefitRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: "checkmark.seal")
                .font(.callout.weight(.semibold))
                .foregroundStyle(LexoraColors.accent)
                .frame(width: 23)

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
                    Text("Unlock reflective stories, the full archive, widgets, and share cards.")
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
