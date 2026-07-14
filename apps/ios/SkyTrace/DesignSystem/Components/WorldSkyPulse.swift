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
                    Text(SkyStrings.t("today.mergeSummary",
                                      String(summary.newReportCount), String(summary.mergedCaseCount)))
                        .font(SkyTypography.supporting).foregroundStyle(SkyColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: SkySpacing.x3) {
                        legendDot(SkyColor.statusNew, SkyStrings.t("v2.status.newReport"))
                        legendDot(SkyColor.signalWarm, SkyStrings.t("label.updated"))
                    }
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

    private func legendDot(_ color: Color, _ text: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(text).font(.caption2).foregroundStyle(SkyColor.textSecondary)
        }
    }

    private var a11ySummary: String {
        SkyStrings.t("today.heroTitle") + "。"
            + SkyStrings.t("today.mergeSummary", String(summary.newReportCount), String(summary.mergedCaseCount))
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
