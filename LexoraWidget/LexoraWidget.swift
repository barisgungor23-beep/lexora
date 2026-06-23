import SwiftUI
import WidgetKit

struct LexoraEntry: TimelineEntry {
    let date: Date
    let word: WidgetWord
}

struct LexoraProvider: TimelineProvider {
    func placeholder(in context: Context) -> LexoraEntry {
        LexoraEntry(date: Date(), word: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (LexoraEntry) -> Void) {
        completion(LexoraEntry(date: Date(), word: WidgetWord.today()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LexoraEntry>) -> Void) {
        let entry = LexoraEntry(date: Date(), word: WidgetWord.today())
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())) ?? Date().addingTimeInterval(86_400)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct LexoraWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: LexoraEntry

    var body: some View {
        VStack(alignment: .leading, spacing: family == .systemSmall ? 7 : 10) {
            Text("Today")
                .font(LexoraWidgetTypography.caption)
                .foregroundStyle(LexoraWidgetColors.secondaryText)
                .textCase(.uppercase)
                .tracking(1)
                .lineLimit(1)

            Text(entry.word.word)
                .font(family == .systemSmall ? LexoraWidgetTypography.smallTitle : LexoraWidgetTypography.title)
                .foregroundStyle(LexoraWidgetColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            HStack(spacing: 6) {
                Text(entry.word.language)
                    .font(LexoraWidgetTypography.caption)
                    .foregroundStyle(LexoraWidgetColors.secondaryText)
                    .lineLimit(1)

                if family != .systemSmall, let pronunciation = entry.word.pronunciation {
                    Text("-")
                        .font(LexoraWidgetTypography.caption)
                        .foregroundStyle(LexoraWidgetColors.secondaryText)

                    Text(pronunciation)
                        .font(LexoraWidgetTypography.caption)
                        .foregroundStyle(LexoraWidgetColors.secondaryText)
                        .lineLimit(1)
                }
            }

            if family != .systemSmall {
                Rectangle()
                    .fill(LexoraWidgetColors.border)
                    .frame(height: 0.7)
            }

            Text(entry.word.shortMeaning)
                .font(family == .systemSmall ? LexoraWidgetTypography.caption : LexoraWidgetTypography.body)
                .foregroundStyle(LexoraWidgetColors.primaryText)
                .lineLimit(family == .systemSmall ? 3 : 5)
                .minimumScaleFactor(0.88)
        }
        .padding(family == .systemSmall ? 4 : 6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(LexoraWidgetColors.card.opacity(0.82))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(LexoraWidgetColors.border, lineWidth: 0.8)
        )
        .containerBackground(LexoraWidgetColors.background, for: .widget)
    }
}

struct LexoraWidget: Widget {
    let kind = "LexoraWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LexoraProvider()) { entry in
            LexoraWidgetView(entry: entry)
        }
        .configurationDisplayName("Lexora")
        .description("Today's word from Lexora.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct LexoraWidgetBundle: WidgetBundle {
    var body: some Widget {
        LexoraWidget()
    }
}
