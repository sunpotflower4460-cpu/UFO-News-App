import SwiftUI

/// 4pt spacing scale. Views reference these instead of magic numbers.
enum SkySpacing {
    static let x1: CGFloat = 4
    static let x2: CGFloat = 8
    static let x3: CGFloat = 12
    static let x4: CGFloat = 16
    static let x5: CGFloat = 20
    static let x6: CGFloat = 24
    static let x8: CGFloat = 32
    static let x10: CGFloat = 40

    /// Standard horizontal screen inset.
    static let screenEdge: CGFloat = 18
    /// Comfortable reading measure for long-form article bodies.
    static let readingMaxWidth: CGFloat = 680
}

/// Corner radii. Nothing so round it reads as childish.
enum SkyRadius {
    static let chip: CGFloat = 11
    static let card: CGFloat = 16
    static let hero: CGFloat = 22
    static let sheet: CGFloat = 26
}

/// Typographic roles map to Dynamic Type semantic styles so everything scales.
enum SkyTypography {
    static let screenHero = Font.largeTitle.weight(.semibold)
    static let sectionHeading = Font.title3.weight(.semibold)
    static let cardHeadline = Font.headline
    static let body = Font.body
    static let supporting = Font.subheadline
    static let metadata = Font.caption
    static let scoreNumber = Font.title2.monospacedDigit().weight(.semibold)
}
