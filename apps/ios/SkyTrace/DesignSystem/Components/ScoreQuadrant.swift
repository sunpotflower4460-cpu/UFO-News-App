import SwiftUI

/// The four-axis score display (2×2). No radar chart (easy to misread). Each
/// tile is tappable to reveal the reasoning, and every axis states whether a
/// higher value means "more explainable" or "stronger signal".
struct ScoreQuadrant: View {
    let scores: CaseScores
    var onSelectAxis: (ScoreAxis.Kind) -> Void = { _ in }

    private let columns = [GridItem(.flexible(), spacing: SkySpacing.x3),
                           GridItem(.flexible(), spacing: SkySpacing.x3)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: SkySpacing.x3) {
            ForEach(scores.axes) { axis in
                Button { onSelectAxis(axis.kind) } label: {
                    ScoreTile(axis: axis)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct ScoreTile: View {
    let axis: ScoreAxis
    @ScaledMetric private var dialSize: CGFloat = 44

    var body: some View {
        let tint = SkyColor.signal(axis.kind.signal)
        VStack(alignment: .leading, spacing: SkySpacing.x2) {
            HStack {
                Text(SkyStrings.t(axis.kind.titleKey))
                    .font(SkyTypography.metadata.weight(.semibold))
                    .foregroundStyle(SkyColor.textSecondary)
                Spacer()
                Image(systemName: "info.circle")
                    .font(.caption2)
                    .foregroundStyle(SkyColor.textTertiary)
            }
            HStack(alignment: .lastTextBaseline, spacing: SkySpacing.x2) {
                Text("\(axis.value)")
                    .font(SkyTypography.scoreNumber)
                    .foregroundStyle(SkyColor.textPrimary)
                Text("/100").font(.caption2).foregroundStyle(SkyColor.textTertiary)
            }
            MiniMeter(value: axis.value, role: axis.kind.signal,
                      label: SkyStrings.t(axis.kind.titleKey))
            Text(SkyStrings.t(axis.kind.higherMeansMoreExplained
                              ? "score.moreExplained" : "score.strongerSignal"))
                .font(.caption2)
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface(padding: SkySpacing.x3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(SkyStrings.t(axis.kind.titleKey)) \(axis.value)。\(SkyStrings.t(axis.kind.higherMeansMoreExplained ? "score.moreExplained" : "score.strongerSignal"))")
        .accessibilityHint(SkyStrings.t("score.learnMore"))
    }
}

/// Sheet body explaining one axis, shown when a tile is tapped.
struct ScoreExplanationSheet: View {
    let kind: ScoreAxis.Kind
    let value: Int
    let algorithmVersion: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SkySpacing.x4) {
                    HStack(alignment: .lastTextBaseline) {
                        Text("\(value)").font(.system(size: 48, weight: .semibold).monospacedDigit())
                        Text("/100").foregroundStyle(SkyColor.textTertiary)
                    }
                    .foregroundStyle(SkyColor.signal(kind.signal))
                    Text(SkyStrings.t(kind.explanationKey))
                        .font(SkyTypography.body)
                        .foregroundStyle(SkyColor.textPrimary)
                    Text("scoring \(algorithmVersion)")
                        .font(.caption2).foregroundStyle(SkyColor.textTertiary)
                }
                .padding(SkySpacing.x5)
                .readingWidth()
            }
            .background(SkyColor.canvas)
            .navigationTitle(SkyStrings.t(kind.titleKey))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(SkyStrings.t("action.close")) { dismiss() }
                }
            }
        }
    }
}

#Preview("ScoreQuadrant") {
    ScoreQuadrant(scores: CaseScores(evidenceQuality: 72, independence: 40,
                                     knownPhenomenaMatch: 88, unresolvedness: 24,
                                     algorithmVersion: "demo-1"))
        .padding()
        .background(SkyColor.canvas)
}
