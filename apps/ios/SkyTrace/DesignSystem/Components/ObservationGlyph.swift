import SwiftUI

/// Abstract observatory-style visual used where article imagery isn't rights-
/// cleared. A quiet orbit + a single undetermined signal — never a flying
/// saucer or green alien. Respects Reduce Motion (static when reduced).
struct ObservationGlyph: View {
    var seed: Int = 0
    var animated: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var sweep = false

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let r = min(size.width, size.height) * 0.36

            // Horizon arc
            var horizon = Path()
            horizon.addArc(center: CGPoint(x: center.x, y: size.height * 0.92),
                           radius: size.width * 0.7,
                           startAngle: .degrees(200), endAngle: .degrees(340), clockwise: false)
            context.stroke(horizon, with: .color(SkyColor.signalCyan.opacity(0.35)), lineWidth: 1)

            // Orbit ellipse
            let orbitRect = CGRect(x: center.x - r, y: center.y - r * 0.55,
                                   width: r * 2, height: r * 1.1)
            context.stroke(Path(ellipseIn: orbitRect),
                           with: .color(SkyColor.signalViolet.opacity(0.5)), lineWidth: 1)

            // Fixed reference dots (deterministic from seed)
            for i in 0..<5 {
                let a = Double((seed * 37 + i * 53) % 360) * .pi / 180
                let p = CGPoint(x: center.x + cos(a) * r * 1.3,
                                y: center.y + sin(a) * r * 0.8)
                context.fill(Path(ellipseIn: CGRect(x: p.x, y: p.y, width: 2, height: 2)),
                             with: .color(SkyColor.textTertiary.opacity(0.7)))
            }

            // The undetermined signal on the orbit
            let angle = Double((seed * 61) % 360) * .pi / 180
            let sp = CGPoint(x: center.x + cos(angle) * r,
                             y: center.y + sin(angle) * r * 0.55)
            context.fill(Path(ellipseIn: CGRect(x: sp.x - 3, y: sp.y - 3, width: 6, height: 6)),
                         with: .color(SkyColor.signalAmber))
            context.stroke(Path(ellipseIn: CGRect(x: sp.x - 7, y: sp.y - 7, width: 14, height: 14)),
                           with: .color(SkyColor.signalAmber.opacity(0.4)), lineWidth: 1)
        }
        .background(
            LinearGradient(colors: [SkyColor.canvasElevated, SkyColor.surfaceSecondary],
                           startPoint: .top, endPoint: .bottom)
        )
        .accessibilityHidden(true)
    }
}

#Preview {
    ObservationGlyph(seed: 3)
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: SkyRadius.hero))
        .padding()
        .background(SkyColor.canvas)
}
