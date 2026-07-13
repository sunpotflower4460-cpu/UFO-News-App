import SwiftUI

/// Daily Briefing preview card. Free users get lead + table of contents (an
/// honest slice, never a full blur); Plus users get a "read full" entry.
struct DailyBriefingCard: View {
    let briefing: DailyBriefing
    let isPlus: Bool
    var onReadFull: () -> Void = {}
    var onUnlock: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x3) {
            HStack {
                Label(SkyStrings.t("briefing.title"), systemImage: "sun.horizon")
                    .font(SkyTypography.metadata.weight(.semibold))
                    .foregroundStyle(SkyColor.signalViolet)
                Spacer()
                AIDisclosureBadge(disclosure: briefing.disclosure)
            }

            Text(briefing.headline)
                .font(SkyTypography.sectionHeading)
                .foregroundStyle(SkyColor.textPrimary)

            Text(briefing.summary)
                .font(SkyTypography.body)
                .foregroundStyle(SkyColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if !briefing.tableOfContents.isEmpty {
                VStack(alignment: .leading, spacing: SkySpacing.x1) {
                    Text(SkyStrings.t("briefing.toc"))
                        .font(.caption.weight(.semibold)).foregroundStyle(SkyColor.textTertiary)
                    ForEach(briefing.tableOfContents, id: \.self) { item in
                        HStack(spacing: SkySpacing.x2) {
                            Image(systemName: "circle.fill").font(.system(size: 4))
                                .foregroundStyle(SkyColor.signalCyan)
                            Text(item).font(SkyTypography.supporting).foregroundStyle(SkyColor.textSecondary)
                        }
                    }
                }
            }

            HStack {
                Text(SkyStrings.t("briefing.usedCases",
                                  String(briefing.usedCaseCount), String(briefing.sourceCount)))
                    .font(.caption2).foregroundStyle(SkyColor.textTertiary)
                Spacer()
                Text(SkyStrings.t("briefing.readMinutes", String(briefing.readingMinutes)))
                    .font(.caption2).foregroundStyle(SkyColor.textTertiary)
            }

            if isPlus {
                Button(action: onReadFull) {
                    Label(SkyStrings.t("action.readMore"), systemImage: "arrow.right")
                        .font(SkyTypography.supporting.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(SkyColor.signalViolet)
            } else {
                Button(action: onUnlock) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text(SkyStrings.t("briefing.readFull"))
                        Spacer()
                        Image(systemName: "lock.fill").imageScale(.small)
                    }
                    .font(SkyTypography.supporting.weight(.semibold))
                    .foregroundStyle(SkyColor.signalViolet)
                    .padding(SkySpacing.x3)
                    .frame(maxWidth: .infinity)
                    .background(SkyColor.signalViolet.opacity(0.12),
                                in: RoundedRectangle(cornerRadius: SkyRadius.chip))
                }
                .buttonStyle(.plain)
            }
        }
        .cardSurface(radius: SkyRadius.hero, padding: SkySpacing.x5)
    }
}
