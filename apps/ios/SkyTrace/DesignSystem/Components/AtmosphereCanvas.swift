import SwiftUI
import Foundation

/// Calm contextual field for World Sky Pulse, map context, and launch continuity
/// (docs/uiux 04 §2 `AtmosphereCanvas`). Deterministic rendering (safe for
/// snapshots); no particle engine. Adds dimensional depth — a deep zenith
/// gradient, a quiet starfield, an aurora wash, and glow around emphasised
/// signals — while staying non-sensational. Static fallback under Reduce
/// Motion, Reduce Transparency, or Low Power. No essential information lives
/// only here.
struct AtmosphereCanvas: View {
    /// 0.0 (deep night) … 1.0 (day). Drives the day/night wash.
    var dayFraction: Double = 0.15
    /// Deterministic signal seeds (longitude-ish positions 0…1, status colour).
    var signals: [AtmosphereSignal] = []
    var animated: Bool = true
    /// Parallax offset (points) shifting the star + signal layers for depth.
    var parallax: CGSize = .zero

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @State private var appeared = false

    private var isMoving: Bool {
        animated && !reduceMotion && !ProcessInfo.processInfo.isLowPowerModeEnabled
            && !UITestFlags.disableAnimations
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Deep vertical sky: near-black zenith down to the horizon wash.
                LinearGradient(
                    colors: [SkyColor.aetherZenith, SkyColor.atmosphereTop, SkyColor.atmosphereBottom],
                    startPoint: .top, endPoint: .bottom
                )
                Canvas { ctx, size in
                    drawStars(&ctx, size)
                    drawAurora(&ctx, size)
                    drawHorizon(&ctx, size)
                    drawSignals(&ctx, size)
                }
                .opacity(reduceTransparency ? 1 : 0.98)
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
            guard isMoving else { appeared = true; return }
            withAnimation(SkyMotion.settle) { appeared = true }
        }
        .accessibilityHidden(true)
    }

    // Deterministic starfield — a quiet depth cue, never information.
    private func drawStars(_ ctx: inout GraphicsContext, _ size: CGSize) {
        guard !reduceTransparency else { return }
        let count = 46
        for i in 0..<count {
            // Simple deterministic hash → stable positions across renders.
            let hx = Double((i &* 2654435761) % 1000) / 1000.0
            let hy = Double((i &* 40503 &+ 17) % 1000) / 1000.0
            let x = size.width * CGFloat(hx) + parallax.width * 0.4
            let y = size.height * CGFloat(hy * 0.82) + parallax.height * 0.4
            let bright = (i % 5 == 0) ? 0.9 : (i % 3 == 0 ? 0.55 : 0.30)
            let s: CGFloat = (i % 7 == 0) ? 1.8 : 1.0
            ctx.fill(Path(ellipseIn: CGRect(x: x, y: y, width: s, height: s)),
                     with: .color(SkyColor.starField.opacity(bright)))
        }
    }

    // Two soft aurora blooms near the horizon — paired hues, low opacity.
    private func drawAurora(_ ctx: inout GraphicsContext, _ size: CGSize) {
        guard !reduceTransparency else { return }
        let band = size.height * 0.62
        let blooms: [(CGFloat, Color)] = [(0.32, SkyColor.auroraViolet), (0.70, SkyColor.auroraCyan)]
        for (fx, color) in blooms {
            let cx = size.width * fx + parallax.width * 0.2
            let rect = CGRect(x: cx - size.width * 0.5, y: band - size.height * 0.28,
                              width: size.width, height: size.height * 0.5)
            ctx.fill(Path(ellipseIn: rect), with: .radialGradient(
                Gradient(colors: [color.opacity(0.16), .clear]),
                center: CGPoint(x: cx, y: band), startRadius: 0, endRadius: size.width * 0.5))
        }
    }

    private func drawHorizon(_ ctx: inout GraphicsContext, _ size: CGSize) {
        var horizon = Path()
        let y = size.height * 0.86
        horizon.addArc(center: CGPoint(x: size.width / 2, y: y + size.width * 0.5),
                       radius: size.width * 0.62,
                       startAngle: .degrees(210), endAngle: .degrees(330), clockwise: false)
        ctx.stroke(horizon, with: .color(SkyColor.accentPrimary.opacity(0.30)), lineWidth: 1)
    }

    private func drawSignals(_ ctx: inout GraphicsContext, _ size: CGSize) {
        let reveal = isMoving ? (appeared ? 1.0 : 0.0) : 1.0
        for s in signals {
            let x = size.width * CGFloat(min(max(s.x, 0.04), 0.96)) + parallax.width
            let y = size.height * CGFloat(0.30 + 0.40 * s.y) + parallax.height
            let r: CGFloat = s.emphasized ? 3.4 : 2.2
            // Glow halo around emphasised signals — a luminous "observed" point.
            if s.emphasized && !reduceTransparency {
                ctx.fill(Path(ellipseIn: CGRect(x: x - r * 4, y: y - r * 4, width: r * 8, height: r * 8)),
                         with: .radialGradient(
                            Gradient(colors: [s.color.opacity(0.42 * reveal), .clear]),
                            center: CGPoint(x: x, y: y), startRadius: 0, endRadius: r * 4))
            }
            ctx.opacity = reveal
            ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                     with: .color(s.color))
            if s.emphasized {
                ctx.stroke(Path(ellipseIn: CGRect(x: x - r * 2.4, y: y - r * 2.4,
                                                  width: r * 4.8, height: r * 4.8)),
                           with: .color(s.color.opacity(0.35)), lineWidth: 1)
            }
            ctx.opacity = 1
        }
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
