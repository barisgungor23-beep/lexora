import Foundation
import WidgetKit

enum LexoraPremiumRules {
    static let freeExploreLimit = 20
    static let freeFavoritesLimit = 5
    static let appGroupIdentifier = "group.com.baris.Lexora"
    static let sharedPremiumKey = "phaseOneMockPremiumEnabled"
}

@MainActor
final class PremiumManager: ObservableObject {
    // Phase 2 TODO: Use this entitlement identifier when RevenueCat is added.
    static let entitlementIdentifier = "premium"

    @Published private(set) var hasPremium = false
    @Published var statusMessage: String? = "Phase 1 uses local mock premium only."
    @Published var isMockPremiumEnabled: Bool {
        didSet {
            defaults.set(isMockPremiumEnabled, forKey: mockPremiumKey)
            sharedDefaults?.set(isMockPremiumEnabled, forKey: LexoraPremiumRules.sharedPremiumKey)
            updatePremiumState()
            WidgetCenter.shared.reloadAllTimelines()
            statusMessage = isMockPremiumEnabled ? "Mock premium is on for Phase 1 testing." : "Mock premium is off. Free state is active."
        }
    }

    private let defaults: UserDefaults
    private let sharedDefaults: UserDefaults?
    private let mockPremiumKey = "phaseOneMockPremiumEnabled"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.sharedDefaults = UserDefaults(suiteName: LexoraPremiumRules.appGroupIdentifier)
        self.isMockPremiumEnabled = defaults.bool(forKey: mockPremiumKey)
        self.sharedDefaults?.set(isMockPremiumEnabled, forKey: LexoraPremiumRules.sharedPremiumKey)
        self.hasPremium = isMockPremiumEnabled
    }

    func configure() {
        // Phase 1 intentionally does not configure RevenueCat, StoreKit, products, or real purchases.
        updatePremiumState()
    }

    func setMockPremium(_ isEnabled: Bool) {
        isMockPremiumEnabled = isEnabled
    }

    func handlePurchaseTapped() {
        // Phase 2 TODO: Start the real RevenueCat purchase flow here.
        statusMessage = "Purchases are deferred to Phase 2. Use Mock Premium in Settings to test premium UI."
    }

    func handleRestoreTapped() {
        // Phase 2 TODO: Call RevenueCat restorePurchases and refresh entitlementIdentifier.
        statusMessage = "Restore is deferred to Phase 2. Use Mock Premium in Settings to test premium UI."
    }

    func applyDevelopmentPromoCode(_ code: String) -> Bool {
        // Phase 2 TODO: Replace this local-only development helper with real promo/redeem logic.
        let normalizedCode = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard normalizedCode == "LEXORADEV" else {
            statusMessage = "Invalid or expired code."
            return false
        }

        setMockPremium(true)
        statusMessage = "Development promo applied. Mock premium is on."
        return true
    }

    private func updatePremiumState() {
        hasPremium = isMockPremiumEnabled
    }
}
