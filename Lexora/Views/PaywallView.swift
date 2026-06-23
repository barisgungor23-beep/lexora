import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var premium: PremiumManager
    @State private var hasAppeared = false
    @State private var selectedPackageID: LexoraPremiumPackage.ID?

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
                            .shadow(color: .black.opacity(0.025), radius: 10, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(LexoraColors.border.opacity(0.72), lineWidth: 0.7)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(LexoraColors.cardBackground.opacity(0.55))
                    )
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.42).delay(0.18), value: hasAppeared)

                    purchaseControls
                        .opacity(hasAppeared ? 1 : 0)
                        .scaleEffect(hasAppeared ? 1 : 0.98)
                        .animation(.easeOut(duration: 0.42).delay(0.28), value: hasAppeared)

                    if let status = premium.statusMessage, !status.isEmpty {
                        Text(status)
                            .font(.lexoraFootnote)
                            .foregroundStyle(LexoraColors.secondaryText)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(LexoraColors.cardBackgroundSoft)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(LexoraColors.border.opacity(0.7), lineWidth: 0.65)
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
        .task {
            await premium.loadPremiumPackages()
            selectDefaultPackageIfNeeded()
        }
        .onChange(of: premium.availablePackages.map(\.id)) { _, _ in
            selectDefaultPackageIfNeeded()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.55)) {
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
                        .foregroundStyle(LexoraColors.accent)

                    Text("Premium is active")
                        .font(.lexoraHeadline)
                        .foregroundStyle(LexoraColors.primaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .lexoraCard(background: LexoraColors.cardBackgroundSoft, padding: 16)
            } else if premium.isLoadingPackages && premium.availablePackages.isEmpty {
                HStack(spacing: 10) {
                    ProgressView()

                    Text("Loading premium options...")
                        .font(.lexoraBody)
                        .foregroundStyle(LexoraColors.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .lexoraCard(background: LexoraColors.cardBackgroundSoft, padding: 16)
            } else if premium.availablePackages.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Premium options are unavailable right now.")
                        .font(.lexoraBody)
                        .foregroundStyle(LexoraColors.primaryText)

                    Button("Try again") {
                        Task {
                            await premium.loadPremiumPackages()
                            selectDefaultPackageIfNeeded()
                        }
                    }
                    .font(.lexoraBody)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .lexoraCard(background: LexoraColors.cardBackgroundSoft, padding: 16)
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
                                .tint(.white)
                        }

                        Text(premium.isProcessingPurchase ? "Processing..." : "Continue")
                            .font(.lexoraHeadline)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 3)
                }
                .buttonStyle(.borderedProminent)
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
            }
            .disabled(premium.isProcessingPurchase)
        }
    }

    private func selectDefaultPackageIfNeeded() {
        guard selectedPackageID == nil || selectedPackage == nil else { return }
        selectedPackageID = premium.availablePackages.first { $0.kind == .annual }?.id ?? premium.availablePackages.first?.id
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
                    .foregroundStyle(isSelected ? LexoraColors.accent : LexoraColors.secondaryText)
                    .frame(width: 26)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(premiumPackage.title)
                            .font(.lexoraHeadline)
                            .foregroundStyle(LexoraColors.primaryText)

                        if let badge = premiumPackage.badge {
                            Text(badge)
                                .font(.lexoraCaption)
                                .textCase(.uppercase)
                                .tracking(0.8)
                                .foregroundStyle(LexoraColors.accent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(LexoraColors.cardBackground)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(LexoraColors.accent.opacity(0.22), lineWidth: 0.7)
                                )
                        }
                    }

                    Text(premiumPackage.subtitle)
                        .font(.lexoraSubheadline)
                        .foregroundStyle(LexoraColors.secondaryText)
                }

                Spacer()

                Text(premiumPackage.price)
                    .font(.lexoraHeadline)
                    .foregroundStyle(LexoraColors.primaryText)
            }
            .padding(15)
            .background(isSelected ? LexoraColors.cardBackground : LexoraColors.cardBackgroundSoft)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? LexoraColors.accent.opacity(0.42) : LexoraColors.border.opacity(0.72), lineWidth: isSelected ? 1 : 0.7)
            )
            .shadow(color: .black.opacity(isSelected ? 0.035 : 0.015), radius: isSelected ? 10 : 5, x: 0, y: isSelected ? 4 : 2)
        }
        .buttonStyle(.plain)
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
                    .stroke(LexoraColors.border.opacity(0.72), lineWidth: 0.7)
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [LexoraColors.cardBackground, Color(red: 0.957, green: 0.944, blue: 0.906)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: 7)
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
                colors: [LexoraColors.cardBackground, Color(red: 0.965, green: 0.951, blue: 0.914)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(LexoraColors.accent.opacity(0.24), lineWidth: 0.9)
        )
        .shadow(color: .black.opacity(0.03), radius: 12, x: 0, y: 5)
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
                    Color(red: 0.982, green: 0.974, blue: 0.949),
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
