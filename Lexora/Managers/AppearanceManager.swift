import SwiftUI

enum AppearanceOption: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system:
            "System"
        case .light:
            "Light"
        case .dark:
            "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            nil
        case .light:
            .light
        case .dark:
            .dark
        }
    }
}

@MainActor
final class AppearanceManager: ObservableObject {
    @Published var selection: AppearanceOption {
        didSet {
            defaults.set(selection.rawValue, forKey: key)
        }
    }

    private let defaults: UserDefaults
    private let key = "appearanceSelection"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let storedValue = defaults.string(forKey: key)
        self.selection = storedValue.flatMap(AppearanceOption.init(rawValue:)) ?? .system
    }
}
