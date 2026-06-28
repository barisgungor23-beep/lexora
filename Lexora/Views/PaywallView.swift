import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var premium: PremiumManager
    @State private var hasAppeared = false
    @State private var selectedPackageID: LexoraPremiumPackage.ID?

    private let benefits = [
        "Deeper notes",
        "Reflective stories for selected words",
        "Review Practice answers",
        "Full word archive",
        "Unlimited favorites",
        "Widget and Share as Card"
    ]

    var body: some View {
        ZStack {
            PaywallBackgroundOrnaments(isActive: hasAppeared)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    PremiumHeroCard(isActive: hasAppeared)
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: reduceMotion || hasAppeared ? 0 : 14)
                        .animation(reduceMotion ? nil : .easeOut(duration: 0.45), value: hasAppeared)

                    PremiumPreviewCard()
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: reduceMotion || hasAppeared ? 0 : 10)
                        .animation(reduceMotion ? nil : .easeOut(duration: 0.38).delay(0.08), value: hasAppeared)

                    VStack(alignment: .leading, spacing: 11) {
                        ForEach(Array(benefits.enumerated()), id: \.offset) { index, benefit in
                            PremiumBenefitRow(text: benefit)
                                .opacity(hasAppeared ? 1 : 0)
                                .offset(y: reduceMotion || hasAppeared ? 0 : 8)
                                .animation(reduceMotion ? nil : .easeOut(duration: 0.28).delay(0.05 + Double(index) * 0.035), value: hasAppeared)
                        }
                    }
                    .padding(17)
                    .background(PaywallPalette.surfaceSoft.opacity(0.92))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(PaywallPalette.border.opacity(0.34), lineWidth: 0.8)
                    )
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: reduceMotion || hasAppeared ? 0 : 10)
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.36).delay(0.12), value: hasAppeared)

                    purchaseControls
                        .opacity(hasAppeared ? 1 : 0)
                        .scaleEffect(reduceMotion || hasAppeared ? 1 : 0.985)
                        .animation(reduceMotion ? nil : .easeOut(duration: 0.36).delay(0.18), value: hasAppeared)

                    if let status = premium.statusMessage, !status.isEmpty {
                        Text(status)
                            .font(.lexoraFootnote)
                            .foregroundStyle(PaywallPalette.mutedText)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(PaywallPalette.surfaceSoft.opacity(0.78))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(PaywallPalette.border.opacity(0.28), lineWidth: 0.7)
                            )
                            .opacity(hasAppeared ? 1 : 0)
                            .animation(reduceMotion ? nil : .easeOut(duration: 0.3).delay(0.22), value: hasAppeared)
                    }
                }
                .padding()
                .padding(.top, 6)
            }
        }
        .navigationTitle("Premium")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(PaywallPalette.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await premium.loadPremiumPackages()
            selectDefaultPackageIfNeeded()
        }
        .onChange(of: premium.availablePackages.map(\.id)) { _, _ in
            selectDefaultPackageIfNeeded()
        }
        .onAppear {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.45)) {
                hasAppeared = true
            }
        }
    }

    private var selectedPackage: LexoraPremiumPackage? {
        premium.availablePackages.first { $0.id == selectedPackageID }
    }

    private var purchaseControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            if premium.hasPremium {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal")
                        .foregroundStyle(PaywallPalette.gold)
                        .accessibilityHidden(true)

                    Text("Premium is active")
                        .font(.lexoraHeadline)
                        .foregroundStyle(PaywallPalette.ivory)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .paywallBrownCard()
            } else if premium.isLoadingPackages && premium.availablePackages.isEmpty {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(PaywallPalette.ivory)

                    Text("Loading premium options...")
                        .font(.lexoraBody)
                        .foregroundStyle(PaywallPalette.mutedText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .paywallBrownCard()
            } else if premium.availablePackages.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Premium options are unavailable right now.")
                        .font(.lexoraBody)
                        .foregroundStyle(PaywallPalette.ivory)

                    Button("Try again") {
                        Task {
                            await premium.loadPremiumPackages()
                            selectDefaultPackageIfNeeded()
                        }
                    }
                    .font(.lexoraBody)
                    .foregroundStyle(PaywallPalette.gold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .paywallBrownCard()
            } else {
                VStack(spacing: 10) {
                    ForEach(premium.availablePackages) { premiumPackage in
                        PremiumPackageRow(
                            premiumPackage: premiumPackage,
                            isSelected: premiumPackage.id == selectedPackageID
                        ) {
                            selectedPackageID = premiumPackage.id
                        }
                    }
                }

                Button {
                    guard let selectedPackage else { return }
                    Task {
                        let didActivate = await premium.purchase(selectedPackage)
                        if didActivate {
                            dismiss()
                        }
                    }
                } label: {
                    HStack {
                        if premium.isProcessingPurchase {
                            ProgressView()
                                .tint(PaywallPalette.ink)
                        }

                        Text(premium.isProcessingPurchase ? "Processing..." : "Continue")
                            .font(.lexoraHeadline)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 13)
                    .foregroundStyle(PaywallPalette.ink)
                    .background(PaywallPalette.ivory)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(PaywallPalette.gold.opacity(0.44), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .disabled(selectedPackage == nil || premium.isProcessingPurchase)
            }

            Button {
                Task {
                    let didRestore = await premium.restorePurchases()
                    if didRestore {
                        dismiss()
                    }
                }
            } label: {
                Text("Restore purchases")
                    .font(.lexoraBody)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .foregroundStyle(PaywallPalette.mutedText)
            }
            .buttonStyle(.plain)
            .disabled(premium.isProcessingPurchase)
        }
    }

    private func selectDefaultPackageIfNeeded() {
        guard selectedPackageID == nil || selectedPackage == nil else { return }
        selectedPackageID = premium.availablePackages.first { $0.kind == .annual }?.id ?? premium.availablePackages.first?.id
    }
}

private enum PaywallPalette {
    static let background = Color(red: 0.145, green: 0.082, blue: 0.052)
    static let backgroundLow = Color(red: 0.230, green: 0.135, blue: 0.084)
    static let surface = Color(red: 0.310, green: 0.190, blue: 0.118)
    static let surfaceSoft = Color(red: 0.245, green: 0.145, blue: 0.090)
    static let paper = Color(red: 0.965, green: 0.925, blue: 0.820)
    static let paperSoft = Color(red: 0.918, green: 0.842, blue: 0.690)
    static let ivory = Color(red: 0.985, green: 0.954, blue: 0.875)
    static let mutedText = Color(red: 0.800, green: 0.708, blue: 0.590)
    static let gold = Color(red: 0.742, green: 0.565, blue: 0.310)
    static let border = Color(red: 0.820, green: 0.650, blue: 0.365)
    static let ink = Color(red: 0.145, green: 0.095, blue: 0.060)
}

private extension View {
    func paywallBrownCard(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(PaywallPalette.surfaceSoft.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(PaywallPalette.border.opacity(0.32), lineWidth: 0.8)
            )
    }
}

private struct PremiumPackageRow: View {
    let premiumPackage: LexoraPremiumPackage
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? PaywallPalette.gold : PaywallPalette.mutedText)
                    .frame(width: 26)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(premiumPackage.title)
                            .font(.lexoraHeadline)
                            .foregroundStyle(isSelected ? PaywallPalette.ink : PaywallPalette.ivory)

                        if let badge = premiumPackage.badge {
                            Text(badge)
                                .font(.lexoraCaption)
                                .textCase(.uppercase)
                                .tracking(0.8)
                                .foregroundStyle(isSelected ? PaywallPalette.ink : PaywallPalette.ivory)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(isSelected ? PaywallPalette.paperSoft : PaywallPalette.gold.opacity(0.28))
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(PaywallPalette.gold.opacity(0.34), lineWidth: 0.7)
                                )
                        }
                    }

                    Text(premiumPackage.subtitle)
                        .font(.lexoraSubheadline)
                        .foregroundStyle(isSelected ? PaywallPalette.ink.opacity(0.72) : PaywallPalette.mutedText)
                }

                Spacer()

                Text(premiumPackage.price)
                    .font(.lexoraHeadline)
                    .foregroundStyle(isSelected ? PaywallPalette.ink : PaywallPalette.ivory)
            }
            .padding(15)
            .background(isSelected ? PaywallPalette.paper : PaywallPalette.surface.opacity(0.88))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(isSelected ? PaywallPalette.gold.opacity(0.78) : PaywallPalette.border.opacity(0.26), lineWidth: isSelected ? 1.25 : 0.75)
            )
            .shadow(color: .black.opacity(isSelected ? 0.22 : 0.10), radius: isSelected ? 14 : 8, x: 0, y: isSelected ? 7 : 4)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

private struct PremiumHeroCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 9) {
                    Text("Lexora Premium")
                        .font(.lexoraTitle)
                        .foregroundStyle(PaywallPalette.ivory)

                    Text("Go deeper into the words that stay with you.")
                        .font(.lexoraBody)
                        .foregroundStyle(PaywallPalette.mutedText)
                        .lineSpacing(5)
                }

                Spacer(minLength: 12)

                Image(systemName: "book.closed")
                    .font(.title2.weight(.regular))
                    .foregroundStyle(PaywallPalette.gold)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(PaywallPalette.surface))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(PaywallPalette.gold.opacity(0.46), lineWidth: 0.9)
                    )
                    .scaleEffect(reduceMotion || isActive ? 1 : 0.94)
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.45), value: isActive)
                    .accessibilityHidden(true)
            }

            Rectangle()
                .fill(PaywallPalette.border.opacity(0.34))
                .frame(height: 0.8)
                .accessibilityHidden(true)

            Text("Premium opens richer notes, selected reflective stories, Practice answer review, the full archive, favorites without limits, the widget, and shareable cards.")
                .font(.lexoraSubheadline)
                .foregroundStyle(PaywallPalette.mutedText)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [PaywallPalette.surface.opacity(0.98), PaywallPalette.surfaceSoft.opacity(0.94)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(PaywallPalette.border.opacity(0.36), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.22), radius: 18, x: 0, y: 9)
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
                    .foregroundStyle(PaywallPalette.ink.opacity(0.64))

                Spacer()

                Text("selected story")
                    .font(.lexoraCaption)
                    .textCase(.uppercase)
                    .tracking(1.1)
                    .foregroundStyle(PaywallPalette.gold)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Komorebi")
                    .font(.lexoraTitle)
                    .foregroundStyle(PaywallPalette.ink)

                Text("Sunlight filtering through trees.")
                    .font(.lexoraSubheadline)
                    .foregroundStyle(PaywallPalette.ink.opacity(0.68))
            }

            Rectangle()
                .fill(PaywallPalette.border.opacity(0.56))
                .frame(height: 0.8)
                .accessibilityHidden(true)

            Text("A narrow path waited behind the house, quiet except for leaves turning in a mild wind. She walked slowly, not because the path was long, but because the light kept changing.")
                .font(.lexoraBody)
                .foregroundStyle(PaywallPalette.ink)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [PaywallPalette.paper, PaywallPalette.paperSoft],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(PaywallPalette.gold.opacity(0.42), lineWidth: 0.9)
        )
        .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 7)
    }
}

private struct PremiumBenefitRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: "checkmark.seal")
                .font(.callout.weight(.semibold))
                .foregroundStyle(PaywallPalette.gold)
                .frame(width: 23)
                .accessibilityHidden(true)

            Text(text)
                .font(.lexoraBody)
                .foregroundStyle(PaywallPalette.ivory)
        }
    }
}

private struct PaywallBackgroundOrnaments: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isActive: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    PaywallPalette.background,
                    PaywallPalette.backgroundLow,
                    PaywallPalette.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            PaywallPalette.gold.opacity(0.10),
                            .clear,
                            PaywallPalette.gold.opacity(0.06)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea()
                .accessibilityHidden(true)

            Circle()
                .stroke(PaywallPalette.gold.opacity(0.12), lineWidth: 1)
                .frame(width: 230, height: 230)
                .offset(x: 132, y: -226)
                .opacity(isActive ? 1 : 0)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.55), value: isActive)
                .accessibilityHidden(true)

            Circle()
                .stroke(PaywallPalette.border.opacity(0.10), lineWidth: 1)
                .frame(width: 180, height: 180)
                .offset(x: -148, y: 250)
                .opacity(isActive ? 1 : 0)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.55).delay(0.06), value: isActive)
                .accessibilityHidden(true)
        }
        .accessibilityHidden(true)
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
