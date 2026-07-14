import SwiftUI

/// A dimensional "observation lens": a rim-lit sphere inside concentric glow
/// rings, orbited by a single traversing light and wrapped in a soft halo.
/// It evokes an *observed, undetermined object* in the night — deliberately
/// abstract, never a literal flying saucer or alien (CLAUDE.md §2, ObservationGlyph).
///
/// Decorative and `accessibilityHidden`; no essential information lives here.
/// Motion is a slow, single orbit that stops under Reduce Motion; halos soften
/// under Reduce Transparency. Deterministic from `seed` (snapshot-safe at rest).
struct AetherOrb: View {
    var seed: Int = 0
    var animated: Bool = true
    /// Parallax offset (points) applied to the inner layers for depth on drag.
    var parallax: CGSize = .zero

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @State private var phase: Double = 0

    private var isMoving: Bool { animated && !reduceMotion && !UITestFlags.disableAnimations }

    var body: some View {
        Canvas { ctx, size in draw(&ctx, size) }
            .onAppear {
                guard isMoving else { return }
                withAnimation(.linear(duration: 26).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
            .accessibilityHidden(true)
    }

    private func draw(_ ctx: inout GraphicsContext, _ size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let m = min(size.width, size.height)
        // `field` is the frame half-extent. Every glow fades to clear by `field`
        // so nothing is clipped at the frame edge (no rectangular halo).
        let field = m * 0.5
        let R = m * 0.27               // sphere radius
        let halo = reduceTransparency ? 0.5 : 1.0
        let par = CGSize(width: parallax.width, height: parallax.height)

        // 1. Outer halo bloom — the object's glow into the night, fully faded
        //    before the frame edge.
        let bloom = Path(ellipseIn: CGRect(x: center.x - field, y: center.y - field,
                                           width: field * 2, height: field * 2))
        ctx.fill(bloom, with: .radialGradient(
            Gradient(colors: [SkyColor.aetherGlow.opacity(0.16 * halo), .clear]),
            center: center, startRadius: R * 0.7, endRadius: field))

        // 2. Concentric orbit rings — perspective ellipses give depth. Capped so
        //    the outermost stays within the frame.
        for (i, spec) in ringSpecs.enumerated() {
            let rr = min(R * spec.scale, field * 0.92)
            let rect = CGRect(x: center.x - rr, y: center.y - rr * 0.62,
                              width: rr * 2, height: rr * 1.24)
            ctx.stroke(Path(ellipseIn: rect),
                       with: .color(spec.color.opacity(spec.opacity)),
                       lineWidth: i == 0 ? 1.2 : 0.8)
        }

        // 3. The sphere itself — a radial gradient lit from the upper-left,
        //    reading as a solid dimensional body against the sky.
        let c = CGPoint(x: center.x + par.width, y: center.y + par.height)
        let sphere = Path(ellipseIn: CGRect(x: c.x - R, y: c.y - R, width: R * 2, height: R * 2))
        let lightSource = CGPoint(x: c.x - R * 0.4, y: c.y - R * 0.42)
        ctx.fill(sphere, with: .radialGradient(
            Gradient(stops: [
                .init(color: SkyColor.aetherGlow.opacity(0.55), location: 0.0),
                .init(color: SkyColor.auroraViolet.opacity(0.42), location: 0.42),
                .init(color: SkyColor.aetherZenith, location: 1.0),
            ]),
            center: lightSource, startRadius: 0, endRadius: R * 1.5))

        // 4. Rim light — a bright crescent on the lit edge.
        var rim = Path()
        rim.addArc(center: c, radius: R * 0.97,
                   startAngle: .degrees(160), endAngle: .degrees(310), clockwise: false)
        ctx.stroke(rim, with: .color(SkyColor.aetherGlow.opacity(0.7 * halo)), lineWidth: 1.4)

        // 5. Terminator shadow — a soft dark edge opposite the light.
        var shade = Path()
        shade.addArc(center: c, radius: R * 0.98,
                     startAngle: .degrees(-20), endAngle: .degrees(140), clockwise: false)
        ctx.stroke(shade, with: .color(SkyColor.aetherZenith.opacity(0.9)), lineWidth: 2)

        // 6. Deterministic star specks, kept inside the frame.
        for i in 0..<7 {
            let a = Double((seed * 47 + i * 51) % 360) * .pi / 180
            let dist = m * (0.30 + 0.17 * Double((seed + i * 13) % 7) / 7.0)
            let p = CGPoint(x: center.x + cos(a) * dist, y: center.y + sin(a) * dist * 0.7)
            let s: CGFloat = (i % 3 == 0) ? 2.0 : 1.2
            ctx.fill(Path(ellipseIn: CGRect(x: p.x, y: p.y, width: s, height: s)),
                     with: .color(SkyColor.starField.opacity(0.75)))
        }

        // 7. The traversing light — a single undetermined signal orbiting the
        //    lens, with a soft halo that also stays within the frame.
        let orbitR = R * 1.28
        let glowR = R * 0.5
        let t = (2 * Double.pi) * phase + Double(seed % 360) * .pi / 180
        let lp = CGPoint(x: center.x + cos(t) * orbitR,
                         y: center.y + sin(t) * orbitR * 0.62 + par.height)
        ctx.fill(Path(ellipseIn: CGRect(x: lp.x - glowR, y: lp.y - glowR,
                                        width: glowR * 2, height: glowR * 2)),
                 with: .radialGradient(
                    Gradient(colors: [SkyColor.statusNew.opacity(0.5 * halo), .clear]),
                    center: lp, startRadius: 0, endRadius: glowR))
        ctx.fill(Path(ellipseIn: CGRect(x: lp.x - 3, y: lp.y - 3, width: 6, height: 6)),
                 with: .color(SkyColor.statusNew))
    }

    private struct RingSpec { let scale: CGFloat; let color: Color; let opacity: Double }
    private var ringSpecs: [RingSpec] {
        [.init(scale: 1.18, color: SkyColor.accentPrimary, opacity: 0.55),
         .init(scale: 1.42, color: SkyColor.auroraCyan, opacity: 0.32),
         .init(scale: 1.62, color: SkyColor.auroraViolet, opacity: 0.20)]
    }
}

#Preview("Aether Orb") {
    AetherOrb(seed: 11)
        .frame(width: 240, height: 240)
        .padding(40)
        .background(SkyColor.canvas)
}
