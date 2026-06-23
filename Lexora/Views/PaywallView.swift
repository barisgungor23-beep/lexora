import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var premium: PremiumManager
    @State private var hasAppeared = false

    private let benefits = [
        "Deeper notes",
        "Reflective stories for selected words",
        "Full word archive",
        "Unlimited favorites",
        "Share as Card",
        "Daily word widget"
    ]

    var body: some View {
        ZStack {
            PaywallBackgroundOrnaments(isActive: hasAppeared)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    PremiumHeroCard(isActive: hasAppeared)
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 18)
                        .animation(.easeOut(duration: 0.55), value: hasAppeared)

                    PremiumPreviewCard()
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 12)
                        .animation(.easeOut(duration: 0.45).delay(0.12), value: hasAppeared)

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(benefits.enumerated()), id: \.offset) { index, benefit in
                            PremiumBenefitRow(text: benefit)
                                .opacity(hasAppeared ? 1 : 0)
                                .offset(y: hasAppeared ? 0 : 10)
                                .animation(.easeOut(duration: 0.38).delay(0.08 + Double(index) * 0.045), value: hasAppeared)
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(LexoraColors.cardBackgroundSoft)
                            .shadow(color: .black.opacity(0.035), radius: 12, x: 0, y: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(LexoraColors.border, lineWidth: 0.8)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(LexoraColors.cardBackground.opacity(0.55))
                    )
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.42).delay(0.18), value: hasAppeared)

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
                    .opacity(hasAppeared ? 1 : 0)
                    .scaleEffect(hasAppeared ? 1 : 0.98)
                    .animation(.easeOut(duration: 0.42).delay(0.28), value: hasAppeared)

                    Text("RevenueCat will connect here after App Store Connect products are ready.")
                        .font(.lexoraFootnote)
                        .foregroundStyle(LexoraColors.secondaryText)
                        .lineSpacing(3)
                        .opacity(hasAppeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.35).delay(0.34), value: hasAppeared)

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
                            .opacity(hasAppeared ? 1 : 0)
                            .animation(.easeOut(duration: 0.35).delay(0.4), value: hasAppeared)
                    }
                }
                .padding()
            }
        }
        .lexoraPageBackground()
        .navigationTitle("Premium")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(LexoraColors.pageBackground, for: .navigationBar)
        .onAppear {
            withAnimation(.easeOut(duration: 0.55)) {
                hasAppeared = true
            }
        }
    }
}

private struct PremiumHeroCard: View {
    let isActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Lexora Premium")
                        .font(.lexoraTitle)
                        .foregroundStyle(LexoraColors.primaryText)

                    Text("Go deeper into the words that stay with you.")
                        .font(.lexoraBody)
                        .foregroundStyle(LexoraColors.secondaryText)
                        .lineSpacing(5)
                }

                Spacer(minLength: 16)

                Image(systemName: "book.closed")
                    .font(.title2.weight(.regular))
                    .foregroundStyle(LexoraColors.accent)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(LexoraColors.cardBackgroundSoft)
                            .shadow(color: LexoraColors.accent.opacity(0.16), radius: 10, x: 0, y: 4)
                    )
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(LexoraColors.accent.opacity(0.38), lineWidth: 0.9)
                    )
                    .scaleEffect(isActive ? 1 : 0.92)
                    .animation(.easeOut(duration: 0.55), value: isActive)
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

                Text("Premium opens richer notes, selected reflective stories, the full archive, favorites without limits, the widget, and shareable cards.")
                    .font(.lexoraSubheadline)
                    .foregroundStyle(LexoraColors.secondaryText)
                    .lineSpacing(4)
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [LexoraColors.cardBackground, LexoraColors.cardBackgroundSoft],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(LexoraColors.border, lineWidth: 0.8)
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [LexoraColors.cardBackground, Color(red: 0.948, green: 0.884, blue: 0.748)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.06), radius: 18, x: 0, y: 9)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(LexoraColors.accent.opacity(0.22), lineWidth: 1)
        )
    }
}

private struct PremiumPreviewCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("Premium preview")
                    .font(.lexoraCaption)
                    .textCase(.uppercase)
                    .tracking(1.5)
                    .foregroundStyle(LexoraColors.secondaryText)

                Spacer()

                Text("selected story")
                    .font(.lexoraCaption)
                    .textCase(.uppercase)
                    .tracking(1.1)
                    .foregroundStyle(LexoraColors.accent)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Komorebi")
                    .font(.lexoraTitle)
                    .foregroundStyle(LexoraColors.primaryText)

                Text("Sunlight filtering through trees.")
                    .font(.lexoraSubheadline)
                    .foregroundStyle(LexoraColors.secondaryText)
            }

            Rectangle()
                .fill(LexoraColors.border)
                .frame(height: 0.8)

            Text("A narrow path waited behind the house, quiet except for leaves turning in a mild wind. She walked slowly, not because the path was long, but because the light kept changing.")
                .font(.lexoraBody)
                .foregroundStyle(LexoraColors.primaryText)
                .lineSpacing(5)
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [LexoraColors.cardBackground, Color(red: 0.972, green: 0.928, blue: 0.836)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(LexoraColors.accent.opacity(0.24), lineWidth: 0.9)
        )
        .shadow(color: .black.opacity(0.04), radius: 14, x: 0, y: 6)
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

private struct PaywallBackgroundOrnaments: View {
    let isActive: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    LexoraColors.pageBackground,
                    Color(red: 0.968, green: 0.925, blue: 0.828),
                    LexoraColors.pageBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .stroke(LexoraColors.accent.opacity(0.10), lineWidth: 1)
                .frame(width: 210, height: 210)
                .offset(x: 130, y: -220)
                .opacity(isActive ? 1 : 0)
                .animation(.easeOut(duration: 0.65), value: isActive)

            Circle()
                .fill(LexoraColors.cardBackground.opacity(0.38))
                .frame(width: 150, height: 150)
                .offset(x: -145, y: 230)
                .opacity(isActive ? 1 : 0)
                .animation(.easeOut(duration: 0.65).delay(0.08), value: isActive)
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
                    Text("Unlock selected reflective stories, the full archive, widgets, and share cards.")
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
