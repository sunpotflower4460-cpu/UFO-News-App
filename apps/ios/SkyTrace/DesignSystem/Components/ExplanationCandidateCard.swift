import SwiftUI

/// A single known-phenomenon explanation candidate. "No match" is shown
/// distinctly from "ruled out".
struct ExplanationCandidateCard: View {
    let candidate: ExplanationCandidate

    var body: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x3) {
            HStack {
                Label(candidate.label, systemImage: candidate.category.systemImage)
                    .font(SkyTypography.cardHeadline)
                    .foregroundStyle(SkyColor.textPrimary)
                Spacer()
                if candidate.isExcluded {
                    SkyChip(text: SkyStrings.t("explanation.excluded"), systemImage: "xmark")
                } else {
                    Text(SkyStrings.t("explanation.matchScore", "\(candidate.matchScore)"))
                        .font(SkyTypography.metadata.weight(.semibold))
                        .foregroundStyle(SkyColor.signalGreen)
                }
            }

            if !candidate.isExcluded {
                MiniMeter(value: candidate.matchScore, role: .green,
                          label: candidate.label)
            }

            if !candidate.matchingConditions.isEmpty {
                conditionList(SkyStrings.t("explanation.matching"),
                              candidate.matchingConditions, "checkmark", .green)
            }
            if !candidate.nonMatchingConditions.isEmpty {
                conditionList(SkyStrings.t("explanation.nonMatching"),
                              candidate.nonMatchingConditions, "minus", .amber)
            }
            if let limits = candidate.dataLimitations {
                VStack(alignment: .leading, spacing: 2) {
                    Text(SkyStrings.t("explanation.limitations"))
                        .font(.caption.weight(.semibold)).foregroundStyle(SkyColor.textTertiary)
                    Text(limits).font(SkyTypography.supporting).foregroundStyle(SkyColor.textSecondary)
                }
            }
        }
        .cardSurface()
    }

    private func conditionList(_ title: String, _ items: [String],
                               _ symbol: String, _ role: SignalRole) -> some View {
        VStack(alignment: .leading, spacing: SkySpacing.x1) {
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(SkyColor.textTertiary)
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: SkySpacing.x2) {
                    Image(systemName: symbol).font(.caption2)
                        .foregroundStyle(SkyColor.signal(role)).padding(.top, 3)
                    Text(item).font(SkyTypography.supporting).foregroundStyle(SkyColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
