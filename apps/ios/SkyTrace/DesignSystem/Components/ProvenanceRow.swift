import SwiftUI

/// Compact "出典 8 · 独立報告 2" row. Keeps the two counts visually distinct
/// because they mean different things (Editorial UX 10.2).
struct ProvenanceRow: View {
    let sourceCount: Int
    let independentCount: Int
    var body: some View {
        HStack(spacing: SkySpacing.x3) {
            Label(SkyStrings.t("label.sources", sourceCount), systemImage: "doc.text")
            Label(SkyStrings.t("label.independent", String(independentCount)), systemImage: "person.2")
        }
        .font(SkyTypography.metadata)
        .foregroundStyle(SkyColor.textSecondary)
        .accessibilityElement(children: .combine)
    }
}

/// A tiny horizontal meter used inline on cards to hint at a single score.
struct MiniMeter: View {
    let value: Int
    var role: SignalRole = .amber
    var label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: SkySpacing.x2) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(SkyColor.surfaceInteractive)
                        Capsule()
                            .fill(SkyColor.signal(role))
                            .frame(width: max(4, geo.size.width * CGFloat(value) / 100))
                    }
                }
                .frame(height: 5)
                Text("\(value)")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(SkyColor.textSecondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label) \(value)")
    }
}
