import SwiftUI

enum LexoraWidgetTypography {
    private static let fontName = "Times New Roman"

    static let title = Font.custom(fontName, size: 25, relativeTo: .title)
    static let smallTitle = Font.custom(fontName, size: 20, relativeTo: .title3)
    static let body = Font.custom(fontName, size: 15, relativeTo: .callout)
    static let caption = Font.custom(fontName, size: 12, relativeTo: .caption)
}

enum LexoraWidgetColors {
    static let background = Color(red: 0.973, green: 0.965, blue: 0.937)
    static let card = Color(red: 1.000, green: 0.994, blue: 0.976)
    static let primaryText = Color(red: 0.145, green: 0.129, blue: 0.108)
    static let secondaryText = Color(red: 0.373, green: 0.353, blue: 0.314)
    static let border = Color(red: 0.725, green: 0.694, blue: 0.631)
}
