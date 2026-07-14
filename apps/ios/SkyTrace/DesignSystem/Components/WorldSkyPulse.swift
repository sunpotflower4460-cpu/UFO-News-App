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
            AtmosphereCanvas(dayFraction: 0.2, signals: signals)
            LinearGradient(colors: [.clear, SkyColor.canvas.opacity(0.55)],
                           startPoint: .center, endPoint: .bottom)
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
                    Spacer()
                    Button(action: onOpenMap) {
                        Label(SkyStrings.t("action.seeDetail"), systemImage: "map")
                            .font(SkyTypography.metadata.weight(.semibold))
                    }
                    .buttonStyle(.plain).foregroundStyle(SkyColor.accentPrimary)
                }
                StaleBadge(date: lastUpdated)
            }
            .padding(SkySpacing.x4)
        }
        .frame(height: 250)
        .clipShape(RoundedRectangle(cornerRadius: SkyRadius.hero, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: SkyRadius.hero, style: .continuous)
            .strokeBorder(SkyColor.borderSubtle, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(a11ySummary)
        .accessibilityHint(SkyStrings.t("map.altList"))
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
