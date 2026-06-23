import Foundation
import RevenueCat
import WidgetKit

enum LexoraPremiumRules {
    static let freeExploreLimit = 20
    static let freeFavoritesLimit = 5
    static let appGroupIdentifier = "group.com.baris.Lexora"
    // Shared with the widget as the effective premium state.
    static let sharedPremiumKey = "phaseOneMockPremiumEnabled"
}

@MainActor
final class PremiumManager: ObservableObject {
    static let entitlementIdentifier = "premium"

    @Published private(set) var hasPremium = false
    @Published private(set) var availablePackages: [LexoraPremiumPackage] = []
    @Published private(set) var isLoadingPackages = false
    @Published private(set) var isProcessingPurchase = false
    @Published var statusMessage: String?
    @Published var isMockPremiumEnabled: Bool {
        didSet {
            defaults.set(isMockPremiumEnabled, forKey: mockPremiumKey)
            updatePremiumState()
            #if DEBUG
            statusMessage = isMockPremiumEnabled ? "Mock premium is on for testing." : "Mock premium is off. RevenueCat entitlement state is active."
            #else
            statusMessage = nil
            #endif
        }
    }

    private let defaults: UserDefaults
    private let sharedDefaults: UserDefaults?
    private let mockPremiumKey = "phaseOneMockPremiumEnabled"
    private let revenueCatService: RevenueCatService
    private var revenueCatHasPremium: Bool

    init(defaults: UserDefaults = .standard, revenueCatService: RevenueCatService? = nil) {
        self.defaults = defaults
        self.sharedDefaults = UserDefaults(suiteName: LexoraPremiumRules.appGroupIdentifier)
        self.revenueCatService = revenueCatService ?? .shared
        self.isMockPremiumEnabled = defaults.bool(forKey: mockPremiumKey)
        self.revenueCatHasPremium = sharedDefaults?.bool(forKey: LexoraPremiumRules.sharedPremiumKey) ?? false
        updatePremiumState()
    }

    func configure() {
        revenueCatService.configureIfReady()
        updatePremiumState()
        Task {
            await refreshCustomerInfo(silent: true)
            await loadPremiumPackages(silent: true)
        }
    }

    func setMockPremium(_ isEnabled: Bool) {
        isMockPremiumEnabled = isEnabled
    }

    func loadPremiumPackages(silent: Bool = false) async {
        guard !isLoadingPackages else { return }
        isLoadingPackages = true
        defer { isLoadingPackages = false }

        do {
            availablePackages = try await revenueCatService.fetchPremiumPackages()
            if availablePackages.isEmpty && !silent {
                statusMessage = "Premium options are unavailable right now. Please try again later."
            }
        } catch {
            if !silent {
                statusMessage = friendlyMessage(for: error)
            }
        }
    }

    func purchase(_ premiumPackage: LexoraPremiumPackage) async -> Bool {
        guard !isProcessingPurchase else { return false }
        isProcessingPurchase = true
        statusMessage = nil
        defer { isProcessingPurchase = false }

        do {
            let result = try await revenueCatService.purchase(premiumPackage)
            applyRevenueCatPremiumState(revenueCatService.hasPremiumEntitlement(result.customerInfo))
            if result.userCancelled {
                statusMessage = nil
                return false
            }
            statusMessage = hasPremium ? "Premium is active." : "Purchase completed, but premium is not active yet. Please try Restore Purchases."
            return hasPremium
        } catch {
            statusMessage = friendlyMessage(for: error)
            return false
        }
    }

    func restorePurchases() async -> Bool {
        guard !isProcessingPurchase else { return false }
        isProcessingPurchase = true
        statusMessage = nil
        defer { isProcessingPurchase = false }

        do {
            let customerInfo = try await revenueCatService.restorePurchases()
            applyRevenueCatPremiumState(revenueCatService.hasPremiumEntitlement(customerInfo))
            statusMessage = hasPremium ? "Premium is active." : "No active premium purchase was found."
            return hasPremium
        } catch {
            statusMessage = friendlyMessage(for: error)
            return false
        }
    }

    func refreshCustomerInfo(silent: Bool = false) async {
        do {
            let customerInfo = try await revenueCatService.refreshCustomerInfo()
            applyRevenueCatPremiumState(revenueCatService.hasPremiumEntitlement(customerInfo))
        } catch {
            if !silent {
                statusMessage = friendlyMessage(for: error)
            }
        }
    }

    func applyDevelopmentPromoCode(_ code: String) -> Bool {
        // Local DEBUG-only testing helper. Public promo redemption should go through App Store / RevenueCat.
        let normalizedCode = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard normalizedCode == "LEXORADEV" else {
            #if DEBUG
            statusMessage = "Invalid or expired code."
            #endif
            return false
        }

        setMockPremium(true)
        #if DEBUG
        statusMessage = "Development promo applied. Mock premium is on."
        #endif
        return true
    }

    private func updatePremiumState() {
        #if DEBUG
        hasPremium = revenueCatHasPremium || isMockPremiumEnabled
        #else
        hasPremium = revenueCatHasPremium
        #endif
        sharedDefaults?.set(hasPremium, forKey: LexoraPremiumRules.sharedPremiumKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func applyRevenueCatPremiumState(_ isActive: Bool) {
        revenueCatHasPremium = isActive
        updatePremiumState()
    }

    private func friendlyMessage(for error: Error) -> String {
        if let revenueCatError = error as? ErrorCode, revenueCatError == .purchaseCancelledError {
            return ""
        }

        if let localizedError = error as? LocalizedError,
           let message = localizedError.errorDescription,
           !message.isEmpty {
            return message
        }

        return "Something went wrong. Please try again."
    }
}
