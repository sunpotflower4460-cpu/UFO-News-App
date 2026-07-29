import SwiftUI

/// News First header (directive §4.1): title, place, occurrence/report/update
/// times, and lead outlet lead first. Status is shown as a small icon-only
/// badge, never a headline-sized "未解明" banner, and no AI assessment appears
/// here at all — that only exists lower, folded into a closed disclosure.
struct NewsCaseHeader: View {
    let uapCase: UAPCase
    var onOpenMap: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x3) {
            HStack(spacing: SkySpacing.x2) {
                StatusBadge(status: uapCase.status, compact: true)
                if uapCase.hasRecentUpdate { UpdateBadge() }
                Spacer(minLength: 0)
                if uapCase.isDemo { DemoBadge() }
            }
            Text(uapCase.title)
                .font(SkyTypography.screenHero)
                .foregroundStyle(SkyColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            outletLine
            HStack(spacing: SkySpacing.x2) {
                Image(systemName: "mappin.and.ellipse").imageScale(.small)
                Text(uapCase.localityName ?? uapCase.regionName)
                Text("·")
                Text(SkyStrings.t(uapCase.locationPrecision.labelKey))
                Spacer(minLength: SkySpacing.x2)
                if uapCase.locationPrecision != .withheld {
                    Button(action: onOpenMap) {
                        Label(SkyStrings.t("action.viewOnMap"), systemImage: "map")
                            .font(SkyTypography.metadata.weight(.semibold))
                            .foregroundStyle(SkyColor.accentPrimary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .font(SkyTypography.metadata).foregroundStyle(SkyColor.textSecondary)
            HStack(alignment: .top, spacing: SkySpacing.x4) {
                if let occurred = uapCase.occurredAtStart {
                    timeChip(SkyStrings.t("label.occurred"), SkyFormat.dateOnly(occurred))
                }
                if let first = uapCase.firstReportedAt {
                    timeChip(SkyStrings.t("news.header.firstReported"), SkyFormat.dateOnly(first))
                }
                timeChip(SkyStrings.t("news.header.lastUpdated"), SkyFormat.adaptive(uapCase.updatedAt))
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder private var outletLine: some View {
        if let lead = uapCase.leadOutletName {
            Text(uapCase.additionalOutletCount > 0
                 ? SkyStrings.t("news.header.leadPlusOthers", lead, String(uapCase.additionalOutletCount))
                 : SkyStrings.t("news.header.leadOnly", lead))
                .font(SkyTypography.supporting.weight(.semibold))
                .foregroundStyle(SkyColor.accentPrimary)
        }
    }

    private func timeChip(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label).font(.caption2).foregroundStyle(SkyColor.textTertiary)
            Text(value).font(.caption.monospacedDigit()).foregroundStyle(SkyColor.textSecondary)
        }
    }
}

#Preview("News Case Header") {
    ScrollView {
        NewsCaseHeader(uapCase: DemoCases.northSeaNotable)
            .padding()
    }
    .background(SkyColor.canvas)
}
