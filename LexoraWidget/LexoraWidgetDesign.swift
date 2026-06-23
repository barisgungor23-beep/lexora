import SwiftUI

enum LexoraWidgetTypography {
    private static let fontName = "Times New Roman"

    static let title = Font.custom(fontName, size: 25, relativeTo: .title)
    static let smallTitle = Font.custom(fontName, size: 20, relativeTo: .title3)
    static let body = Font.custom(fontName, size: 15, relativeTo: .callout)
    static let caption = Font.custom(fontName, size: 12, relativeTo: .caption)
}

enum LexoraWidgetColors {
    static let background = Color(red: 0.974, green: 0.958, blue: 0.926)
    static let card = Color(red: 0.996, green: 0.984, blue: 0.954)
    static let primaryText = Color(red: 0.158, green: 0.132, blue: 0.105)
    static let secondaryText = Color(red: 0.442, green: 0.384, blue: 0.309)
    static let border = Color(red: 0.842, green: 0.778, blue: 0.674)
}
