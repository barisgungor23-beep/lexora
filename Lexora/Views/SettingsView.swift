import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var repository: WordRepository
    @EnvironmentObject private var notifications: NotificationManager
    @EnvironmentObject private var premium: PremiumManager
    @EnvironmentObject private var appearance: AppearanceManager
    @State private var promoCode = ""
    @State private var promoMessage: String?

    private let dailyService = DailyWordService()

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Mode", selection: $appearance.selection) {
                        ForEach(AppearanceOption.allCases) { option in
                            Text(option.title)
                                .tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .listRowBackground(LexoraColors.cardBackground)

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
                    NavigationLink("Premium") {
                        PaywallView()
                    }

                    Button("Restore purchases (Phase 2)") {
                        premium.handleRestoreTapped()
                    }

                    if let status = premium.statusMessage {
                        Text(status)
                            .font(.lexoraFootnote)
                            .foregroundStyle(LexoraColors.secondaryText)
                    }
                }
                .listRowBackground(LexoraColors.cardBackground)

                Section("Promo code") {
                    TextField("Code", text: $promoCode)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()

                    Button("Apply") {
                        // Phase 1 local-only testing. Real promo redemption belongs in Phase 2 or later.
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

                #if DEBUG
                Section("Phase 1 testing") {
                    Toggle("Mock premium", isOn: Binding(
                        get: { premium.isMockPremiumEnabled },
                        set: { premium.setMockPremium($0) }
                    ))

                    Text("Use this local-only toggle to check locked and unlocked premium states before RevenueCat is added in Phase 2.")
                        .font(.lexoraFootnote)
                        .foregroundStyle(LexoraColors.secondaryText)
                }
                .listRowBackground(LexoraColors.cardBackground)
                #endif

                Section("Privacy") {
                    Text("Lexora has no account, no server, no AI, and no analytics in this MVP.")
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
