import SwiftUI
import UIKit

/// Semantic colour tokens. Views MUST use these — never inline `Color(red:…)`.
///
/// Dark is the brand's primary world; Light is a fully re-designed surface set
/// (not a naïve inversion). Each token adapts via a `UIColor` trait provider so
/// a single call site works in both appearances.
enum SkyColor {

    // MARK: Canvas & surfaces
    static let canvas = dynamic(dark: 0x070B14, light: 0xF3F6FB)
    static let canvasElevated = dynamic(dark: 0x0A101B, light: 0xFFFFFF)
    static let surfacePrimary = dynamic(dark: 0x0E1623, light: 0xFFFFFF)
    static let surfaceSecondary = dynamic(dark: 0x131E2D, light: 0xEEF2F8)
    static let surfaceInteractive = dynamic(dark: 0x182638, light: 0xE4EAF3)

    static let borderSubtle = dynamicA(dark: (0xFFFFFF, 0.10), light: (0x0B1220, 0.10))

    // MARK: Text
    static let textPrimary = dynamic(dark: 0xF4F7FB, light: 0x121821)
    static let textSecondary = dynamic(dark: 0xA9B5C7, light: 0x4C5A6E)
    static let textTertiary = dynamic(dark: 0x728096, light: 0x76839A)

    // MARK: Signals
    static let signalCyan = dynamic(dark: 0x8CD9FF, light: 0x1E7FB8)
    static let signalViolet = dynamic(dark: 0xA895FF, light: 0x6A4FCF)
    static let signalAmber = dynamic(dark: 0xF4C56B, light: 0xB07A12)
    static let signalGreen = dynamic(dark: 0x79D4A3, light: 0x1F8A5B)
    static let signalRed = dynamic(dark: 0xEF9292, light: 0xC0453F)

    /// Maps a semantic signal role to its token.
    static func signal(_ role: SignalRole) -> Color {
        switch role {
        case .cyan: signalCyan
        case .violet: signalViolet
        case .amber: signalAmber
        case .green: signalGreen
        case .red: signalRed
        case .neutral: textSecondary
        }
    }

    // MARK: - Builders

    private static func dynamic(dark: Int, light: Int) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? uiColor(dark, 1) : uiColor(light, 1)
        })
    }

    private static func dynamicA(dark: (Int, Double), light: (Int, Double)) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? uiColor(dark.0, dark.1) : uiColor(light.0, light.1)
        })
    }

    private static func uiColor(_ hex: Int, _ alpha: Double) -> UIColor {
        UIColor(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
}
