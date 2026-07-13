import SwiftUI

/// Editorial content surface: stable, opaque-ish, readable. Used for cards and
/// article bodies — NOT heavy glass (see UI_UX_PLAN 6.4).
struct CardSurfaceModifier: ViewModifier {
    var radius: CGFloat = SkyRadius.card
    var padding: CGFloat = SkySpacing.x4

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(SkyColor.surfacePrimary, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(SkyColor.borderSubtle, lineWidth: 1)
            )
    }
}

/// Liquid-Glass-aware control surface for navigation/control layers only.
/// Falls back to `.ultraThinMaterial` on iOS 17–25.
struct GlassControlModifier: ViewModifier {
    var radius: CGFloat = SkyRadius.chip

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, SkySpacing.x3)
            .padding(.vertical, SkySpacing.x2)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(SkyColor.borderSubtle, lineWidth: 1))
    }
}

extension View {
    func cardSurface(radius: CGFloat = SkyRadius.card, padding: CGFloat = SkySpacing.x4) -> some View {
        modifier(CardSurfaceModifier(radius: radius, padding: padding))
    }

    func glassControl(radius: CGFloat = SkyRadius.chip) -> some View {
        modifier(GlassControlModifier(radius: radius))
    }

    /// Constrains long-form text to a comfortable reading measure, centred.
    func readingWidth() -> some View {
        frame(maxWidth: SkySpacing.readingMaxWidth, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
