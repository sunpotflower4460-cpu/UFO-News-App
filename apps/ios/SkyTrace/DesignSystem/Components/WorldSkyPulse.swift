import SwiftUI

/// Today's atmospheric hero (docs/uiux 03 §3.1 / 04 §4). Establishes global
/// context before detail: date, one-line world summary, abstract signal field,
/// a new/updated legend, last-updated time, and a map action. Never implies it
/// covers every report on Earth (coverage note). Has a grouped accessibility
/// summary and a list action for the map.
struct WorldSkyPulse: View {
    let date: Date
    let summary: GlobalSummary
    let signals: [AtmosphereSignal]
    let lastUpdated: Date
    var updatedCount: Int = 0
    var onOpenMap: () -> Void = {}

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Parallax: the sky drifts slightly as the hero scrolls, adding depth.
            GeometryReader { geo in
                AtmosphereCanvas(dayFraction: 0.2, signals: signals,
                                 parallax: CGSize(width: 0, height: geo.frame(in: .global).minY * 0.06))
            }
            LinearGradient(colors: [.clear, SkyColor.aetherZenith.opacity(0.66)],
                           startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: SkySpacing.x2) {
                // The world summary is one VoiceOver element…
                VStack(alignment: .leading, spacing: SkySpacing.x2) {
                    Text(SkyFormat.dateOnly(date))
                        .font(SkyTypography.metadata).foregroundStyle(SkyColor.textSecondary)
                    Text(SkyStrings.t("today.heroTitle"))
                        .font(SkyTypography.sectionHeading).foregroundStyle(SkyColor.textPrimary)
                    // Three labelled metrics — a number alone isn't context.
                    HStack(alignment: .top, spacing: SkySpacing.x5) {
                        metric(summary.newReportCount, SkyStrings.t("pulse.metric.new"), SkyColor.statusNew)
                        metric(summary.mergedCaseCount, SkyStrings.t("pulse.metric.merged"), SkyColor.accentPrimary)
                        metric(updatedCount, SkyStrings.t("pulse.metric.updated"), SkyColor.signalWarm)
                    }
                    Text(SkyStrings.t(summary.coverageNoteKey))
                        .font(SkyTypography.metadata).foregroundStyle(SkyColor.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                    StaleBadge(date: lastUpdated)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(a11ySummary)

                // …and "地図で見る" is a separate, reachable button.
                Button(action: onOpenMap) {
                    Label(SkyStrings.t("action.viewOnMap"), systemImage: "map")
                        .font(SkyTypography.metadata.weight(.semibold))
                }
                .buttonStyle(.plain).foregroundStyle(SkyColor.accentPrimary)
                .accessibilityLabel(SkyStrings.t("action.viewOnMap"))
            }
            .padding(SkySpacing.x4)
        }
        .frame(height: 250)
        .clipShape(RoundedRectangle(cornerRadius: SkyRadius.hero, style: .continuous))
        // Rim light on the top edge → a lit, dimensional pane.
        .overlay(RoundedRectangle(cornerRadius: SkyRadius.hero, style: .continuous)
            .strokeBorder(
                LinearGradient(colors: [SkyColor.aetherGlow.opacity(0.5), SkyColor.borderSubtle, .clear],
                               startPoint: .top, endPoint: .bottom),
                lineWidth: 1))
        .shadow(color: SkyColor.aetherZenith.opacity(0.6), radius: 18, y: 10)
    }

    private func metric(_ value: Int, _ label: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(value)").font(SkyTypography.scoreNumber).foregroundStyle(SkyColor.textPrimary)
            Text(label).font(SkyTypography.metadata).foregroundStyle(color)
        }
    }

    private var a11ySummary: String {
        SkyStrings.t("today.heroTitle") + "。"
            + SkyStrings.t("pulse.metric.new") + " \(summary.newReportCount)。"
            + SkyStrings.t("pulse.metric.merged") + " \(summary.mergedCaseCount)。"
            + SkyStrings.t("pulse.metric.updated") + " \(updatedCount)。"
            + SkyStrings.t(summary.coverageNoteKey)
    }

    /// Builds abstract signals from cases by normalising lat/lon into the field.
    static func signals(from cases: [UAPCase]) -> [AtmosphereSignal] {
        cases.prefix(12).map { c in
            AtmosphereSignal(
                x: (c.longitude + 180) / 360,
                y: 1 - (c.latitude + 90) / 180,
                color: c.v2Status.color,
                emphasized: c.hasRecentUpdate
            )
        }
    }
}
