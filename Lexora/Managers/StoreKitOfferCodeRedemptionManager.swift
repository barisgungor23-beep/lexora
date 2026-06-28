import Foundation
import StoreKit
import UIKit

@MainActor
final class StoreKitOfferCodeRedemptionManager {
    static let shared = StoreKitOfferCodeRedemptionManager()

    private init() {}

    func presentRedemptionSheet() async throws {
        guard let scene = activeWindowScene else {
            throw StoreKitOfferCodeRedemptionError.activeSceneUnavailable
        }

        try await AppStore.presentOfferCodeRedeemSheet(in: scene)
    }

    private var activeWindowScene: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
    }
}

enum StoreKitOfferCodeRedemptionError: LocalizedError {
    case activeSceneUnavailable

    var errorDescription: String? {
        switch self {
        case .activeSceneUnavailable:
            return "Offer code sheet could not be opened."
        }
    }
}
