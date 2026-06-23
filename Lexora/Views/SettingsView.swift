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

                Section("Premium") {
                    NavigationLink(premium.hasPremium ? "Premium active" : "Premium") {
                        PaywallView()
                    }

                    Button("Restore purchases") {
                        Task {
                            await premium.restorePurchases()
                        }
                    }
                    .disabled(premium.isProcessingPurchase)

                    if let status = premium.statusMessage, !status.isEmpty {
                        Text(status)
                            .font(.lexoraFootnote)
                            .foregroundStyle(LexoraColors.secondaryText)
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
