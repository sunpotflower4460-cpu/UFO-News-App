import SwiftUI

/// Motion tokens (docs/uiux 05). Motion explains structure/change — never
/// decoration. All durations short; callers must degrade under Reduce Motion.
enum SkyMotion {
    static let quick: Animation = .easeInOut(duration: 0.20)
    static let standard: Animation = .easeInOut(duration: 0.28)
    static let gentle: Animation = .easeInOut(duration: 0.35)
    /// A slow, one-shot atmospheric settle (orbit line, day/night). Not looping.
    static let settle: Animation = .easeOut(duration: 0.9)

    /// Returns the animation, or `nil` when Reduce Motion is on (caller falls
    /// back to an instant/crossfade change).
    static func respecting(_ reduceMotion: Bool, _ animation: Animation) -> Animation? {
        reduceMotion ? nil : animation
    }
}
