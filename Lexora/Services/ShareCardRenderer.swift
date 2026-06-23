import SwiftUI
import UIKit

enum ShareCardRenderer {
    static let imageSize = CGSize(width: 1080, height: 1080)

    @MainActor
    static func image(for word: Word) -> UIImage? {
        let card = ShareCardView(word: word)
            .frame(width: imageSize.width, height: imageSize.height)

        let renderer = ImageRenderer(content: card)
        renderer.proposedSize = ProposedViewSize(imageSize)
        renderer.scale = 1
        renderer.isOpaque = true

        return renderer.uiImage
    }
}
