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

    // MARK: - Aether Editorial System (V2 tokens)
    // Values from docs/uiux/02_DESIGN_SYSTEM_SPEC.md §2.2 / §2.3.

    /// Atmosphere layer (World Sky Pulse, map context, launch continuity).
    static let atmosphereTop = dynamic(dark: 0x0B1621, light: 0xEAF4F8)
    static let atmosphereBottom = dynamic(dark: 0x091018, light: 0xF8FAF7)
    /// Raised/selected editorial surface.
    static let surfaceElevated = dynamic(dark: 0x182631, light: 0xE5EEF1)
    static let separator = dynamic(dark: 0x2A3945, light: 0xCBD7DC)

    /// Primary atmospheric accent (controls, links, selection).
    static let accentPrimary = dynamic(dark: 0x5FD4C8, light: 0x087A73)
    /// Secondary accent (location, map, secondary links).
    static let accentSecondary = dynamic(dark: 0x78BDF2, light: 0x176FA3)
    /// Warm signal: time, meaningful change, historic note.
    static let signalWarm = dynamic(dark: 0xE2C17B, light: 0x8B651C)

    static let error = signalRed
    static let warning = dynamic(dark: 0xF1B765, light: 0x8A5A00)
    static let success = dynamic(dark: 0x73D39B, light: 0x257A4E)

    // MARK: - Aether depth (dimensional sky: launch/Welcome + World Sky Pulse)
    // Adds atmosphere and a quiet sense of the observed unknown, without
    // sensationalism. Decorative only — never the sole carrier of information.

    /// Deepest sky, near the zenith. Sits above `atmosphereTop`.
    static let aetherZenith = dynamic(dark: 0x04070E, light: 0xDCEAF2)
    /// Aurora wash near the horizon (paired hues, kept low-opacity in use).
    static let auroraViolet = dynamic(dark: 0x6E5CC8, light: 0x8E7BE0)
    static let auroraCyan = dynamic(dark: 0x3FA9C9, light: 0x6FC2DA)
    /// Distant starfield points (decorative; deterministic).
    static let starField = dynamic(dark: 0xCED8EC, light: 0x9AA9C4)
    /// Luminous halo around an emphasised/observed signal.
    static let aetherGlow = dynamic(dark: 0x7FE6DC, light: 0x2FB6AA)

    // Status colours (paired with geometry + label; never the sole carrier).
    static let statusNew = dynamic(dark: 0x8CD9FF, light: 0x1E7FB8)
    static let statusReview = dynamic(dark: 0x78BDF2, light: 0x176FA3)
    static let statusInsufficient = dynamic(dark: 0xF1B765, light: 0x8A5A00)
    static let statusLikelyKnown = dynamic(dark: 0x9FD9B4, light: 0x2C7C57)
    static let statusExplained = dynamic(dark: 0x73D39B, light: 0x257A4E)
    static let statusDisputed = dynamic(dark: 0xEF9292, light: 0xC0453F)
    static let statusCorrected = dynamic(dark: 0xE2C17B, light: 0x8B651C)
    static let statusArchived = dynamic(dark: 0x7C8995, light: 0x687985)

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
