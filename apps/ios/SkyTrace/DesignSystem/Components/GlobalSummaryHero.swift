import SwiftUI

/// Today's top-of-screen world overview. Never implies "every report on Earth".
struct GlobalSummaryHero: View {
    let summary: GlobalSummary
    let date: Date
    var onSelectStat: (CaseStatus?) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x3) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: SkySpacing.x1) {
                    Text(SkyStrings.t("today.heroTitle"))
                        .font(SkyTypography.sectionHeading)
                        .foregroundStyle(SkyColor.textPrimary)
                    Text(SkyStrings.t("today.mergeSummary",
                                      String(summary.newReportCount),
                                      String(summary.mergedCaseCount)))
                        .font(SkyTypography.supporting)
                        .foregroundStyle(SkyColor.textSecondary)
                }
                Spacer()
                ObservationGlyph(seed: 7)
                    .frame(width: 76, height: 76)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(SkyColor.borderSubtle, lineWidth: 1))
            }

            HStack(spacing: SkySpacing.x2) {
                stat(SkyStrings.t("today.summary.explained"), summary.likelyExplainedCount, .green, .likelyExplained)
                stat(SkyStrings.t("today.summary.insufficient"), summary.insufficientDataCount, .amber, .insufficientData)
                stat(SkyStrings.t("today.summary.notable"), summary.notableUnresolvedCount, .violet, .notableUnresolved)
            }

            Text(SkyStrings.t(summary.coverageNoteKey))
                .font(.caption2)
                .foregroundStyle(SkyColor.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .cardSurface(radius: SkyRadius.hero, padding: SkySpacing.x5)
    }

    private func stat(_ title: String, _ count: Int, _ role: SignalRole, _ status: CaseStatus) -> some View {
        Button { onSelectStat(status) } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(count)")
                    .font(SkyTypography.scoreNumber)
                    .foregroundStyle(SkyColor.signal(role))
                Text(title).font(.caption2).foregroundStyle(SkyColor.textSecondary)
                    .lineLimit(2, reservesSpace: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(SkySpacing.x3)
            .background(SkyColor.surfaceSecondary, in: RoundedRectangle(cornerRadius: SkyRadius.chip))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title) \(count)")
        .accessibilityAddTraits(.isButton)
    }
}
