import WidgetKit
import SwiftUI

struct FanhBWidgetEntry: TimelineEntry {
    let date: Date
}

struct FanhBWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> FanhBWidgetEntry {
        FanhBWidgetEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (FanhBWidgetEntry) -> Void) {
        completion(FanhBWidgetEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FanhBWidgetEntry>) -> Void) {
        completion(Timeline(entries: [FanhBWidgetEntry(date: .now)], policy: .atEnd))
    }
}

struct FanhBWidgetView: View {
    let entry: FanhBWidgetEntry

    var body: some View {
        Text("FanhB")
            .font(.caption.bold())
            .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct FanhBWidget: Widget {
    let kind = "FanhBWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FanhBWidgetProvider()) { entry in
            FanhBWidgetView(entry: entry)
        }
        .configurationDisplayName("FanhB")
        .description("See the latest drawing from your partner.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
