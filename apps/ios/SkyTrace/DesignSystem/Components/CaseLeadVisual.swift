import SwiftUI

/// A generated "lead visual" for a case header (V3 §5.1): an atmospheric sky
/// tinted by the case's status, with the status glyph as a dimensional focal
/// motif. Gives each case a recognizable, non-sensational hero without relying
/// on unlicensed photography (CLAUDE.md §7). The status *shape* — not colour
/// alone — distinguishes cases at a glance. Purely decorative, so it is hidden
/// from VoiceOver; the header states status/title/location in text below it.
struct CaseLeadVisual: View {
    let status: SkyCaseStatus
    var height: CGFloat = 172
    var dayFraction: Double = 0.18
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        ZStack {
            AtmosphereCanvas(dayFraction: dayFraction, signals: [
                .init(x: 0.28, y: 0.34, color: status.color, emphasized: true),
                .init(x: 0.72, y: 0.56, color: status.color.opacity(0.7)),
            ])
            // Soft focal halo behind the glyph for depth and mystery.
            if !reduceTransparency {
                Circle()
                    .fill(RadialGradient(colors: [status.color.opacity(0.32), .clear],
                                         center: .center, startRadius: 2, endRadius: 100))
                    .frame(width: 200, height: 200)
                    .blur(radius: 10)
            }
            // Focal status glyph — the case's signature shape, given depth.
            CaseStatusGlyph(status: status, size: 76)
                .shadow(color: status.color.opacity(0.5), radius: 12, y: 4)
                .shadow(color: .black.opacity(0.22), radius: 2, y: 1)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: SkyRadius.hero))
        .overlay(
            RoundedRectangle(cornerRadius: SkyRadius.hero)
                .strokeBorder(SkyColor.separator.opacity(0.4), lineWidth: 0.5)
        )
        .accessibilityHidden(true)
    }
}

#Preview("Case Lead Visual") {
    ScrollView {
        VStack(spacing: SkySpacing.x4) {
            ForEach(SkyCaseStatus.allCases) { s in
                CaseLeadVisual(status: s)
            }
        }
        .padding()
    }
    .background(SkyColor.canvas)
}
