import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var repository: WordRepository
    @EnvironmentObject private var notifications: NotificationManager
    @EnvironmentObject private var premium: PremiumManager
    #if DEBUG
    @State private var promoCode = ""
    @State private var promoMessage: String?
    #endif

    private let dailyService = DailyWordService()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PremiumStatusBanner()
                }
                .listRowInsets(EdgeInsets(top: 14, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)

                Section("Daily notification") {
                    Toggle("Enable daily word", isOn: $notifications.isEnabled)
                    DatePicker("Time", selection: $notifications.notificationDate, displayedComponents: .hourAndMinute)

                    Button("Schedule daily word reminder") {
                        Task {
                            await notifications.updateSchedule(using: dailyService.word(words: repository.words))
                        }
                    }
                }
                .listRowBackground(LexoraColors.cardBackground)

                #if DEBUG
                Section("Promo code") {
                    TextField("Code", text: $promoCode)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()

                    Button("Apply") {
                        // DEBUG-only local testing. Public promo redemption should use App Store / RevenueCat.
                        let didApply = premium.applyDevelopmentPromoCode(promoCode)
                        promoMessage = didApply ? "Mock premium enabled." : "Invalid or expired code."
                    }

                    if let promoMessage {
                        Text(promoMessage)
                            .font(.lexoraFootnote)
                            .foregroundStyle(LexoraColors.secondaryText)
                    }
                }
                .listRowBackground(LexoraColors.cardBackground)

                Section("Phase 1 testing") {
                    Toggle("Mock premium", isOn: Binding(
                        get: { premium.isMockPremiumEnabled },
                        set: { premium.setMockPremium($0) }
                    ))

                    Text("Use this local-only toggle to check locked and unlocked premium states without making a test purchase.")
                        .font(.lexoraFootnote)
                        .foregroundStyle(LexoraColors.secondaryText)
                }
                .listRowBackground(LexoraColors.cardBackground)
                #endif

                Section("Privacy") {
                    Text("Lexora works without an account. Your favorites and preferences stay on your device, with no server, AI, or analytics.")
                        .font(.lexoraFootnote)
                        .foregroundStyle(LexoraColors.secondaryText)
                }
                .listRowBackground(LexoraColors.cardBackground)
            }
            .font(.lexoraBody)
            .lexoraPageBackground()
            .toolbarBackground(LexoraColors.pageBackground, for: .navigationBar)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: notifications.isEnabled) { _, _ in
                Task {
                    await notifications.updateSchedule(using: dailyService.word(words: repository.words))
                }
            }
            .onChange(of: notifications.notificationDate) { _, _ in
                guard notifications.isEnabled else { return }
                Task {
                    await notifications.updateSchedule(using: dailyService.word(words: repository.words))
                }
            }
        }
        .tint(LexoraColors.accent)
    }
}

private struct PremiumStatusBanner: View {
    @EnvironmentObject private var premium: PremiumManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: premium.hasPremium ? "checkmark.seal.fill" : "seal")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(LexoraColors.accent)
                    .frame(width: 34)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Lexora Premium")
                            .font(.lexoraHeadline)
                            .foregroundStyle(LexoraColors.primaryText)

                        Spacer(minLength: 12)

                        Text(premium.hasPremium ? "Active" : "Not active")
                            .font(.lexoraFootnote)
                            .foregroundStyle(LexoraColors.accent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(LexoraColors.cardBackgroundSoft.opacity(0.72))
                            .clipShape(Capsule())
                    }

                    Text(premium.hasPremium ? "Full archive, stories, widget, and sharing are unlocked." : "Unlock deeper notes, stories, the full archive, widget, and Share as Card.")
                        .font(.lexoraCallout)
                        .foregroundStyle(LexoraColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 12) {
                if !premium.hasPremium {
                    NavigationLink {
                        PaywallView()
                    } label: {
                        Label("View Premium", systemImage: "sparkle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(LexoraColors.accent)
                }

                Button {
                    Task {
                        await premium.restorePurchases()
                    }
                } label: {
                    Label("Restore", systemImage: "arrow.clockwise")
                        .frame(maxWidth: premium.hasPremium ? .infinity : nil)
                }
                .buttonStyle(.bordered)
                .tint(LexoraColors.accent)
                .disabled(premium.isProcessingPurchase)
            }

            if let status = premium.statusMessage, !status.isEmpty {
                Text(status)
                    .font(.lexoraFootnote)
                    .foregroundStyle(LexoraColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .lexoraCard(background: LexoraColors.cardBackground, padding: 18)
        .listRowSeparator(.hidden)
    }
}
