import SwiftUI

enum LexoraTypography {
    private static let fontName = "Times New Roman"

    static let hero = Font.custom(fontName, size: 52, relativeTo: .largeTitle)
    static let display = Font.custom(fontName, size: 42, relativeTo: .largeTitle)
    static let title = Font.custom(fontName, size: 28, relativeTo: .title)
    static let headline = Font.custom(fontName, size: 19, relativeTo: .headline)
    static let body = Font.custom(fontName, size: 17, relativeTo: .body)
    static let callout = Font.custom(fontName, size: 16, relativeTo: .callout)
    static let subheadline = Font.custom(fontName, size: 15, relativeTo: .subheadline)
    static let caption = Font.custom(fontName, size: 13, relativeTo: .caption)
    static let footnote = Font.custom(fontName, size: 12, relativeTo: .footnote)
}

extension Font {
    static var lexoraHero: Font { LexoraTypography.hero }
    static var lexoraDisplay: Font { LexoraTypography.display }
    static var lexoraTitle: Font { LexoraTypography.title }
    static var lexoraHeadline: Font { LexoraTypography.headline }
    static var lexoraBody: Font { LexoraTypography.body }
    static var lexoraCallout: Font { LexoraTypography.callout }
    static var lexoraSubheadline: Font { LexoraTypography.subheadline }
    static var lexoraCaption: Font { LexoraTypography.caption }
    static var lexoraFootnote: Font { LexoraTypography.footnote }
}
