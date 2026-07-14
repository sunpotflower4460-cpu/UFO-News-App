import SwiftUI
import WidgetKit

/// Widget entry + timeline, and the Small / Medium / Lock-screen content views
/// (docs/uiux 03 §11). Glanceable, not a miniature feed; deep-links to content;
/// no alarm language; tint/monochrome-safe; distinction never by colour alone.
///
/// NOTE: the widget *extension target* (its `@main WidgetBundle`, Info.plist and
/// capability) must be added in Xcode — see docs/MANUAL_ACTIONS.md. The content
/// views below are defined in the app target so they compile and preview now,
/// and the extension simply references them.
struct SkyWidgetEntry: TimelineEntry {
    let date: Date
    let headline: String
    let newCount: Int
    let updatedCount: Int
    let statuses: [SkyCaseStatus]
}

struct SkyWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SkyWidgetEntry { Self.sample }
    func getSnapshot(in context: Context, completion: @escaping (SkyWidgetEntry) -> Void) {
        completion(Self.sample)
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SkyWidgetEntry>) -> Void) {
        // Fixture-backed; production reads the cached Today feed.
        completion(Timeline(entries: [Self.sample], policy: .after(Self.sample.date.addingTimeInterval(3600))))
    }

    static var sample: SkyWidgetEntry {
        let feed = DemoFeed.feed()
        return SkyWidgetEntry(
            date: feed.lastUpdatedAt,
            headline: feed.briefing.headline,
            newCount: feed.summary.newReportCount,
            updatedCount: feed.recentUpdates.count,
            statuses: Array(feed.topCases.prefix(4)).map(\.v2Status)
        )
    }
}

// MARK: - Content views (reused by the extension and the debug gallery)

struct SkyWidgetSmall: View {
    let entry: SkyWidgetEntry
    var body: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x1) {
            HStack(spacing: SkySpacing.x1) {
                ForEach(Array(entry.statuses.prefix(4).enumerated()), id: \.offset) { _, s in
                    CaseStatusGlyph(status: s, size: 14)
                }
            }
            Spacer(minLength: 0)
            Text("\(entry.newCount)").font(.system(.title, design: .rounded).weight(.semibold))
                .foregroundStyle(SkyColor.textPrimary)
            Text(SkyStrings.t("today.summary.reports"))
                .font(.caption2).foregroundStyle(SkyColor.textSecondary)
            Text(SkyStrings.t("state.stale", SkyFormat.relative(entry.date)))
                .font(.system(size: 8)).foregroundStyle(SkyColor.textTertiary)
        }
    }
}

struct SkyWidgetMedium: View {
    let entry: SkyWidgetEntry
    var body: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x2) {
            Text(SkyStrings.t("today.heroTitle"))
                .font(.caption.weight(.semibold)).foregroundStyle(SkyColor.textSecondary)
            Text(entry.headline).font(.subheadline.weight(.semibold))
                .foregroundStyle(SkyColor.textPrimary).lineLimit(2)
            Spacer(minLength: 0)
            HStack(spacing: SkySpacing.x4) {
                metric("\(entry.newCount)", SkyStrings.t("today.summary.reports"))
                metric("\(entry.updatedCount)", SkyStrings.t("label.updated"))
                Spacer()
                HStack(spacing: SkySpacing.x1) {
                    ForEach(Array(entry.statuses.prefix(4).enumerated()), id: \.offset) { _, s in
                        CaseStatusGlyph(status: s, size: 15)
                    }
                }
            }
        }
    }
    private func metric(_ v: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(v).font(.title3.weight(.semibold).monospacedDigit()).foregroundStyle(SkyColor.textPrimary)
            Text(label).font(.caption2).foregroundStyle(SkyColor.textSecondary)
        }
    }
}

struct SkyWidgetLockInline: View {
    let entry: SkyWidgetEntry
    var body: some View {
        // Monochrome-safe; text carries the meaning.
        Text("新\(entry.newCount)・更\(entry.updatedCount)")
    }
}

// MARK: - Widget configuration (NO @main here — extension provides the bundle)

struct SkyTodayWidget: Widget {
    let kind = "SkyTodayWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SkyWidgetProvider()) { entry in
            SkyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("SkyTrace")
        .description(SkyStrings.t("today.heroTitle"))
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryInline, .accessoryRectangular])
    }
}

struct SkyWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SkyWidgetEntry
    var body: some View {
        Group {
            switch family {
            case .systemSmall: SkyWidgetSmall(entry: entry)
            case .systemMedium: SkyWidgetMedium(entry: entry)
            case .accessoryRectangular:
                VStack(alignment: .leading) {
                    Text(entry.headline).font(.caption2).lineLimit(2)
                    Text("新\(entry.newCount)・更\(entry.updatedCount)").font(.caption2)
                }
            default: SkyWidgetLockInline(entry: entry)
            }
        }
        .containerBackground(SkyColor.canvasElevated, for: .widget)
    }
}

#Preview("Widget · Small", as: .systemSmall) {
    SkyTodayWidget()
} timeline: {
    SkyWidgetProvider.sample
}

#Preview("Widget · Medium", as: .systemMedium) {
    SkyTodayWidget()
} timeline: {
    SkyWidgetProvider.sample
}
