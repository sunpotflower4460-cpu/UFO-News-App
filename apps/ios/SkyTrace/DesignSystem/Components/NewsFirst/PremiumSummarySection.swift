import SwiftUI

/// "3分でわかるまとめ" (directive §4.4) — Premium's central value is a fast,
/// readable summary of multiple news reports, not an AI verdict. Facts,
/// confirmations, and open questions stay in separate labelled groups. Free
/// readers see the opening lines plus what the full summary covers, then a
/// contextual Plus lock — never a blurred wall.
struct PremiumSummarySection: View {
    let summary: PremiumSummaryContent
    let isPlus: Bool
    var onUnlock: () -> Void

    var body: some View {
        EditorialSection(title: SkyStrings.t("news.premiumSummary.title"),
                         systemImage: "text.badge.checkmark", accent: SkyColor.signalViolet) {
            VStack(alignment: .leading, spacing: SkySpacing.x4) {
                Text(SkyStrings.t("news.premiumSummary.subtitle"))
                    .font(SkyTypography.metadata).foregroundStyle(SkyColor.textTertiary)
                group(titleKey: "news.premiumSummary.whatReported", items: summary.whatWasReported, tint: SkyColor.textPrimary)
                if isPlus {
                    if !summary.whatCanBeConfirmed.isEmpty {
                        group(titleKey: "news.premiumSummary.confirmed", items: summary.whatCanBeConfirmed, tint: SkyColor.signalCyan)
                    }
                    if !summary.stillUnknown.isEmpty {
                        group(titleKey: "news.premiumSummary.stillUnknown", items: summary.stillUnknown, tint: SkyColor.signalWarm)
                    }
                    if summary.hasFollowUp {
                        Label(SkyStrings.t("news.premiumSummary.followUp"), systemImage: "arrow.triangle.2.circlepath")
                            .font(SkyTypography.metadata).foregroundStyle(SkyColor.textTertiary)
                    }
                } else {
                    PremiumLockView(
                        title: SkyStrings.t("news.premiumSummary.title"),
                        unlocks: [SkyStrings.t("news.premiumSummary.confirmed"),
                                  SkyStrings.t("news.premiumSummary.stillUnknown")],
                        ctaTitle: SkyStrings.t("paywall.cta"),
                        onUnlock: onUnlock
                    )
                    .accessibilityIdentifier("caseDetail.premiumSummary.lock")
                }
            }
        }
        .accessibilityIdentifier("caseDetail.premiumSummary")
    }

    private func group(titleKey: String, items: [String], tint: Color) -> some View {
        VStack(alignment: .leading, spacing: SkySpacing.x1) {
            Text(SkyStrings.t(titleKey)).font(SkyTypography.supporting.weight(.semibold)).foregroundStyle(tint)
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                Text(item).font(SkyTypography.body).foregroundStyle(SkyColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview("Premium Summary — Free") {
    ScrollView {
        PremiumSummarySection(summary: DemoCases.northSeaNotable.premiumSummary, isPlus: false, onUnlock: {})
            .padding()
    }
    .background(SkyColor.canvas)
}

#Preview("Premium Summary — Plus") {
    ScrollView {
        PremiumSummarySection(summary: DemoCases.northSeaNotable.premiumSummary, isPlus: true, onUnlock: {})
            .padding()
    }
    .background(SkyColor.canvas)
}
