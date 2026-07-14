import SwiftUI

/// Calm contextual field for World Sky Pulse, map context, and launch continuity
/// (docs/uiux 04 §2 `AtmosphereCanvas`). Deterministic rendering (safe for
/// snapshots); no particle engine; static fallback under Reduce Motion, Reduce
/// Transparency, or Low Power. No essential information lives only here.
struct AtmosphereCanvas: View {
    /// 0.0 (deep night) … 1.0 (day). Drives the day/night wash.
    var dayFraction: Double = 0.15
    /// Deterministic signal seeds (longitude-ish positions 0…1, status colour).
    var signals: [AtmosphereSignal] = []
    var animated: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @State private var appeared = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [SkyColor.atmosphereTop, SkyColor.atmosphereBottom],
                    startPoint: .top, endPoint: .bottom
                )
                Canvas { ctx, size in
                    drawHorizon(&ctx, size)
                    drawSignals(&ctx, size)
                }
                .opacity(reduceTransparency ? 1 : 0.96)
            }
            .overlay(alignment: .top) {
                // A single, quiet day/night band near the horizon.
                LinearGradient(
                    colors: [SkyColor.signalWarm.opacity(0.0),
                             SkyColor.signalWarm.opacity(0.10 * dayFraction + 0.02)],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: geo.size.height * 0.5)
                .allowsHitTesting(false)
            }
        }
        .onAppear {
            guard animated, !reduceMotion else { appeared = true; return }
            withAnimation(SkyMotion.settle) { appeared = true }
        }
        .accessibilityHidden(true)
    }

    private func drawHorizon(_ ctx: inout GraphicsContext, _ size: CGSize) {
        var horizon = Path()
        let y = size.height * 0.86
        horizon.addArc(center: CGPoint(x: size.width / 2, y: y + size.width * 0.5),
                       radius: size.width * 0.62,
                       startAngle: .degrees(210), endAngle: .degrees(330), clockwise: false)
        ctx.stroke(horizon, with: .color(SkyColor.accentPrimary.opacity(0.28)), lineWidth: 1)
    }

    private func drawSignals(_ ctx: inout GraphicsContext, _ size: CGSize) {
        let reveal = (reduceMotion || !animated) ? 1.0 : (appeared ? 1.0 : 0.0)
        for s in signals {
            let x = size.width * CGFloat(min(max(s.x, 0.04), 0.96))
            let y = size.height * CGFloat(0.30 + 0.40 * s.y)
            let r: CGFloat = s.emphasized ? 3.4 : 2.2
            ctx.opacity = reveal
            ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                     with: .color(s.color))
            if s.emphasized {
                ctx.stroke(Path(ellipseIn: CGRect(x: x - r * 2.4, y: y - r * 2.4,
                                                  width: r * 4.8, height: r * 4.8)),
                           with: .color(s.color.opacity(0.35)), lineWidth: 1)
            }
        }
        ctx.opacity = 1
    }
}

/// One abstract signal on the atmosphere field. Never a literal map marker.
struct AtmosphereSignal: Sendable, Hashable {
    var x: Double   // 0…1 horizontal
    var y: Double   // 0…1 vertical band
    var color: Color
    var emphasized: Bool = false
}

#Preview("Atmosphere") {
    AtmosphereCanvas(
        dayFraction: 0.2,
        signals: [
            .init(x: 0.2, y: 0.3, color: SkyColor.statusNew, emphasized: true),
            .init(x: 0.55, y: 0.6, color: SkyColor.statusReview),
            .init(x: 0.78, y: 0.4, color: SkyColor.statusInsufficient),
        ]
    )
    .frame(height: 260)
    .clipShape(RoundedRectangle(cornerRadius: 22))
    .padding()
    .background(SkyColor.canvas)
}
