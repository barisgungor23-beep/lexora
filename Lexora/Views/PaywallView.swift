import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var premium: PremiumManager

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Image(systemName: "sparkle.magnifyingglass")
                .font(.system(size: 44))
                .foregroundStyle(LexoraColors.accent)

            Text("Unlock deeper word details")
                .font(.lexoraTitle)

            Text("Premium will show full meaning, cultural notes, origin notes, usage notes, and the related feeling for each word.")
                .font(.lexoraBody)
                .foregroundStyle(LexoraColors.secondaryText)
                .lineSpacing(4)

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
