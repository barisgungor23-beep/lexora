import SwiftUI
import UIKit

enum LexoraWidgetTypography {
    private static let fontName = "Times New Roman"

    static let title = Font.custom(fontName, size: 25, relativeTo: .title)
    static let smallTitle = Font.custom(fontName, size: 20, relativeTo: .title3)
    static let body = Font.custom(fontName, size: 15, relativeTo: .callout)
    static let caption = Font.custom(fontName, size: 12, relativeTo: .caption)
}

enum LexoraWidgetColors {
    static let background = Color(widgetLight: 0xF3EAD8, dark: 0x17130E)
    static let card = Color(widgetLight: 0xFBF4E6, dark: 0x211B14)
    static let primaryText = Color(widgetLight: 0x2D241A, dark: 0xF4E8D4)
    static let secondaryText = Color(widgetLight: 0x6F604C, dark: 0xC8B99E)
    static let border = Color(widgetLight: 0xD8C7A9, dark: 0x4A3C2B)
}

extension Color {
    init(widgetLight light: UInt, dark: UInt) {
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
