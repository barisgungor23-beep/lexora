import SwiftUI

struct LexoraCardModifier: ViewModifier {
    var background: Color = LexoraColors.cardBackground
    var padding: CGFloat = 20

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(LexoraColors.border.opacity(0.82), lineWidth: 0.8)
            )
            .shadow(color: .black.opacity(0.035), radius: 10, x: 0, y: 4)
    }
}

struct LexoraPageBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(LexoraColors.pageBackground.ignoresSafeArea())
            .scrollContentBackground(.hidden)
            .foregroundStyle(LexoraColors.primaryText)
            .tint(LexoraColors.accent)
    }
}

extension View {
    func lexoraCard(background: Color = LexoraColors.cardBackground, padding: CGFloat = 20) -> some View {
        modifier(LexoraCardModifier(background: background, padding: padding))
    }

    func lexoraPageBackground() -> some View {
        modifier(LexoraPageBackgroundModifier())
    }
}
