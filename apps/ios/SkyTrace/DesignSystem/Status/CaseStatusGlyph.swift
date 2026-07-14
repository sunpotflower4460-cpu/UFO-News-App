import SwiftUI

/// Draws the semantic status geometry (docs/uiux 02 §3). The same glyph appears
/// on map, rows, detail header, timeline, and widgets. Status is never conveyed
/// by colour alone — the shape differs per status, and an accessibility label is
/// always supplied.
struct CaseStatusGlyph: View {
    let status: SkyCaseStatus
    var size: CGFloat = 16
    var selected: Bool = false
    var showsUpdateIndicator: Bool = false

    var body: some View {
        let stroke = max(1.2, size / 11)
        Canvas { ctx, canvasSize in
            let rect = CGRect(origin: .zero, size: canvasSize).insetBy(dx: stroke, dy: stroke)
            let tint = status.color
            draw(status.geometry, in: rect, ctx: &ctx, tint: tint, stroke: stroke)
        }
        .frame(width: size, height: size)
        .overlay(alignment: .topTrailing) {
            if showsUpdateIndicator {
                Circle().fill(SkyColor.signalWarm)
                    .frame(width: size * 0.34, height: size * 0.34)
                    .offset(x: size * 0.12, y: -size * 0.12)
            }
        }
        .padding(selected ? size * 0.18 : 0)
        .background {
            if selected {
                Circle().stroke(status.color.opacity(0.7), lineWidth: stroke)
            }
        }
        .accessibilityHidden(true)
    }

    private func draw(_ geometry: StatusGeometry, in rect: CGRect,
                      ctx: inout GraphicsContext, tint: Color, stroke: CGFloat) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        let fill = GraphicsContext.Shading.color(tint)

        switch geometry {
        case .pointInRing:
            ctx.stroke(Path(ellipseIn: rect), with: fill, lineWidth: stroke)
            ctx.fill(dot(center, r * 0.42), with: fill)

        case .openRingTick:
            var ring = Path()
            ring.addArc(center: center, radius: r, startAngle: .degrees(-60),
                        endAngle: .degrees(240), clockwise: false)
            ctx.stroke(ring, with: fill, lineWidth: stroke)
            var tick = Path()
            tick.move(to: CGPoint(x: center.x, y: center.y - r))
            tick.addLine(to: CGPoint(x: center.x, y: center.y - r * 0.45))
            ctx.stroke(tick, with: fill, lineWidth: stroke)

        case .openRingGap:
            var ring = Path()
            ring.addArc(center: center, radius: r, startAngle: .degrees(300),
                        endAngle: .degrees(150), clockwise: false)
            ctx.stroke(ring, with: fill, lineWidth: stroke)

        case .halfFilled:
            ctx.stroke(Path(ellipseIn: rect), with: fill, lineWidth: stroke)
            var half = Path()
            half.addArc(center: center, radius: r - stroke / 2, startAngle: .degrees(90),
                        endAngle: .degrees(270), clockwise: false)
            half.closeSubpath()
            ctx.fill(half, with: fill)

        case .diamond:
            ctx.fill(diamond(center, r), with: fill)

        case .offsetArcs:
            for dx in [-r * 0.28, r * 0.28] {
                var arc = Path()
                arc.addArc(center: CGPoint(x: center.x + dx, y: center.y), radius: r * 0.85,
                           startAngle: .degrees(dx < 0 ? -50 : 130),
                           endAngle: .degrees(dx < 0 ? 50 : 230), clockwise: false)
                ctx.stroke(arc, with: fill, lineWidth: stroke)
            }

        case .diamondRevision:
            ctx.stroke(diamond(center, r), with: fill, lineWidth: stroke)
            var mark = Path()
            mark.move(to: CGPoint(x: center.x - r * 0.28, y: center.y))
            mark.addLine(to: CGPoint(x: center.x + r * 0.28, y: center.y))
            ctx.stroke(mark, with: fill, lineWidth: stroke)

        case .squareOutline:
            let side = r * 1.4
            let sq = CGRect(x: center.x - side / 2, y: center.y - side / 2, width: side, height: side)
            ctx.stroke(Path(roundedRect: sq, cornerRadius: side * 0.14), with: fill, lineWidth: stroke)
        }
    }

    private func dot(_ c: CGPoint, _ r: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2))
    }
    private func diamond(_ c: CGPoint, _ r: CGFloat) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: c.x, y: c.y - r))
        p.addLine(to: CGPoint(x: c.x + r, y: c.y))
        p.addLine(to: CGPoint(x: c.x, y: c.y + r))
        p.addLine(to: CGPoint(x: c.x - r, y: c.y))
        p.closeSubpath()
        return p
    }
}

/// Glyph + natural-language label, used in detail/header/preview contexts. At
/// large Dynamic Type the label leads and the glyph is secondary.
struct CaseStatusLabel: View {
    let status: SkyCaseStatus
    var showsUpdateIndicator: Bool = false
    @ScaledMetric(relativeTo: .footnote) private var glyphSize: CGFloat = 15

    var body: some View {
        HStack(spacing: SkySpacing.x2) {
            CaseStatusGlyph(status: status, size: glyphSize, showsUpdateIndicator: showsUpdateIndicator)
            Text(SkyStrings.t(status.labelKey))
                .font(SkyTypography.metadata.weight(.semibold))
                .foregroundStyle(status.color)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(SkyStrings.t(status.labelKey)
            + (showsUpdateIndicator ? "、" + SkyStrings.t("label.updated") : ""))
    }
}

#Preview("Status geometry") {
    ScrollView {
        VStack(alignment: .leading, spacing: SkySpacing.x4) {
            ForEach(SkyCaseStatus.allCases) { s in
                HStack(spacing: SkySpacing.x4) {
                    CaseStatusGlyph(status: s, size: 30)
                    CaseStatusGlyph(status: s, size: 22, selected: true)
                    CaseStatusLabel(status: s, showsUpdateIndicator: s == .corrected)
                }
            }
        }
        .padding()
    }
    .background(SkyColor.canvas)
}
