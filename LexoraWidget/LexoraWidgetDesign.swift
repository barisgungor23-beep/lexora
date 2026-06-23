import SwiftUI

enum LexoraWidgetTypography {
    private static let fontName = "Times New Roman"

    static let title = Font.custom(fontName, size: 25, relativeTo: .title)
    static let smallTitle = Font.custom(fontName, size: 20, relativeTo: .title3)
    static let body = Font.custom(fontName, size: 15, relativeTo: .callout)
    static let caption = Font.custom(fontName, size: 12, relativeTo: .caption)
}

enum LexoraWidgetColors {
    static let background = Color(red: 0.953, green: 0.918, blue: 0.847)
    static let card = Color(red: 0.984, green: 0.957, blue: 0.902)
    static let primaryText = Color(red: 0.176, green: 0.141, blue: 0.102)
    static let secondaryText = Color(red: 0.435, green: 0.376, blue: 0.298)
    static let border = Color(red: 0.847, green: 0.780, blue: 0.663)
}
