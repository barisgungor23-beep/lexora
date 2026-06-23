import Foundation
import RevenueCat

enum LexoraPremiumPlanKind: String, CaseIterable {
    case annual
    case lifetime
    case monthly

    var title: String {
        switch self {
        case .annual:
            return "Yearly"
        case .lifetime:
            return "Lifetime"
        case .monthly:
            return "Monthly"
        }
    }

    var subtitle: String {
        switch self {
        case .annual:
            return "Best for a daily reading habit"
        case .lifetime:
            return "Keep Lexora Premium forever"
        case .monthly:
            return "A gentle way to begin"
        }
    }

    var badge: String? {
        switch self {
        case .annual:
            return "Recommended"
        case .lifetime, .monthly:
            return nil
        }
    }

    var packageType: PackageType {
        switch self {
        case .annual:
            return .annual
        case .lifetime:
            return .lifetime
        case .monthly:
            return .monthly
        }
    }
}

struct LexoraPremiumPackage: Identifiable {
    let kind: LexoraPremiumPlanKind
    fileprivate let package: Package

    var id: String { package.identifier }
    var title: String { kind.title }
    var subtitle: String { kind.subtitle }
    var badge: String? { kind.badge }
    var price: String { package.localizedPriceString }
    var productIdentifier: String { package.storeProduct.productIdentifier }
}

@MainActor
final class RevenueCatService {
    static let shared = RevenueCatService()

    static let publicSDKKey = "appl_QYGWGlkqasWCOibgZJixcbUCuEo"
    static let entitlementIdentifier = "premium"
    static let offeringIdentifier = "default"

    private init() {}

    func configureIfReady() {
        guard !Purchases.isConfigured else { return }
        Purchases.configure(withAPIKey: Self.publicSDKKey)
    }

    func refreshCustomerInfo() async throws -> CustomerInfo {
        configureIfReady()
        return try await Purchases.shared.customerInfo()
    }

    func fetchPremiumPackages() async throws -> [LexoraPremiumPackage] {
        configureIfReady()
        let offerings = try await Purchases.shared.offerings()
        guard let offering = offerings.offering(identifier: Self.offeringIdentifier) ?? offerings.current else {
            throw RevenueCatServiceError.offeringUnavailable
        }

        let packagesByType = Dictionary(grouping: offering.availablePackages, by: \.packageType)
        return LexoraPremiumPlanKind.allCases.compactMap { kind in
            guard let package = packagesByType[kind.packageType]?.first else { return nil }
            return LexoraPremiumPackage(kind: kind, package: package)
        }
    }

    func purchase(_ premiumPackage: LexoraPremiumPackage) async throws -> PurchaseResultData {
        configureIfReady()
        return try await Purchases.shared.purchase(package: premiumPackage.package)
    }

    func restorePurchases() async throws -> CustomerInfo {
        configureIfReady()
        return try await Purchases.shared.restorePurchases()
    }

    func hasPremiumEntitlement(_ customerInfo: CustomerInfo) -> Bool {
        customerInfo.entitlements[Self.entitlementIdentifier]?.isActive == true
    }
}

enum RevenueCatServiceError: LocalizedError {
    case offeringUnavailable

    var errorDescription: String? {
        switch self {
        case .offeringUnavailable:
            return "Premium options are unavailable right now. Please try again later."
        }
    }
}
