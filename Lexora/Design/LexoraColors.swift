import SwiftUI
import UIKit

enum LexoraColors {
    static let pageBackground = Color(light: 0xF3EAD8, dark: 0x17130E)
    static let cardBackground = Color(light: 0xFBF4E6, dark: 0x211B14)
    static let cardBackgroundSoft = Color(light: 0xF7EEDC, dark: 0x2A2218)
    static let primaryText = Color(light: 0x2D241A, dark: 0xF4E8D4)
    static let secondaryText = Color(light: 0x6F604C, dark: 0xC8B99E)
    static let border = Color(light: 0xD8C7A9, dark: 0x4A3C2B)
    static let accent = Color(light: 0x8A5A2B, dark: 0xD3A46B)
    static let favorite = Color(light: 0x9F4F45, dark: 0xE09A8C)
}

extension Color {
    init(light: UInt, dark: UInt) {
        self.init(uiColor: UIColor { traitCollection in
            let value = traitCollection.userInterfaceStyle == .dark ? dark : light
            return UIColor(
                red: CGFloat((value >> 16) & 0xFF) / 255,
                green: CGFloat((value >> 8) & 0xFF) / 255,
                blue: CGFloat(value & 0xFF) / 255,
                alpha: 1
            )
        })
    }
}
