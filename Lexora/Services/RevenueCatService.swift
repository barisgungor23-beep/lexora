import Foundation
import RevenueCat

@MainActor
final class RevenueCatService {
    static let shared = RevenueCatService()

    private init() {}

    func configureIfReady() {
        // Phase 2 TODO: Configure Purchases with the real RevenueCat public SDK key.
        // Intentionally disabled while ASC products and RevenueCat offerings are not ready.
    }

    func refreshCustomerInfo() async {
        // Phase 2 TODO: Fetch CustomerInfo and sync the premium entitlement into PremiumManager.
    }

    func fetchOfferings() async {
        // Phase 2 TODO: Fetch RevenueCat offerings for monthly, yearly, and lifetime packages.
    }

    func purchasePlaceholder() async {
        // Phase 2 TODO: Purchase the selected RevenueCat package.
    }

    func restorePurchases() async {
        // Phase 2 TODO: Restore purchases and update the App Group premium state for the widget.
    }
}
