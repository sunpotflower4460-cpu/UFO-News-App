import SwiftUI

/// One assessment dimension row: label, qualitative level (word + compact bar,
/// never a percentage), and a short basis. Tappable for the full basis. Never
/// accepts a single global truth score (docs/uiux 04 §5 `AssessmentDimensionRow`).
struct AssessmentDimensionRow: View {
    let dimension: AssessmentDimension

    var body: some View {
        let tint = SkyColor.signal(dimension.signal)
        VStack(alignment: .leading, spacing: SkySpacing.x1) {
            HStack {
                Text(SkyStrings.t(dimension.kind.labelKey))
                    .font(SkyTypography.supporting.weight(.medium))
                    .foregroundStyle(SkyColor.textPrimary)
                Spacer()
                Text(SkyStrings.t(dimension.level.labelKey))
                    .font(SkyTypography.metadata.weight(.semibold))
                    .foregroundStyle(tint)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(SkyColor.surfaceInteractive)
                    Capsule().fill(tint)
                        .frame(width: max(6, geo.size.width * dimension.level.fraction))
                }
            }
            .frame(height: 4)
            Text(dimension.basis)
                .font(.caption2).foregroundStyle(SkyColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, SkySpacing.x1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(SkyStrings.t(dimension.kind.labelKey))、\(SkyStrings.t(dimension.level.labelKey))。\(dimension.basis)")
    }
}

/// A "What Changed" delta row: icon + kind + summary + time. Links to timeline.
struct CaseChangeRow: View {
    let change: CaseChangeEntry
    var body: some View {
        HStack(alignment: .top, spacing: SkySpacing.x3) {
            Image(systemName: change.kind.systemImage)
                .foregroundStyle(SkyColor.signalWarm).frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(SkyStrings.t(change.kind.labelKey))
                    .font(.caption.weight(.semibold)).foregroundStyle(SkyColor.signalWarm)
                Text(change.summary).font(SkyTypography.body).foregroundStyle(SkyColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(SkyFormat.dateOnly(change.changedAt))
                    .font(.caption2).foregroundStyle(SkyColor.textTertiary)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}

/// A source-linked confirmed fact (editorial list item, not a card).
struct FactStatementRow: View {
    let fact: ConfirmedFact
    var body: some View {
        HStack(alignment: .top, spacing: SkySpacing.x2) {
            Image(systemName: "checkmark.seal").font(.caption)
                .foregroundStyle(SkyColor.statusExplained).padding(.top, 2)
            VStack(alignment: .leading, spacing: 1) {
                Text(fact.text).font(SkyTypography.body).foregroundStyle(SkyColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                if !fact.sourceIDs.isEmpty {
                    Text("— " + fact.sourceIDs.map { "[\($0)]" }.joined(separator: " "))
                        .font(.caption2).foregroundStyle(SkyColor.accentSecondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}
