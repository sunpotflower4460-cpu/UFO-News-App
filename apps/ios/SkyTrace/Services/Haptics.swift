import UIKit

/// Thin haptics wrapper. Used only for meaningful moments (bookmark, filter,
/// refresh complete, purchase, error) — never on ordinary taps/scrolls.
/// `@MainActor` because `UIFeedbackGenerator` is main-actor-isolated; every call
/// site is already on the main actor.
@MainActor
enum Haptics {
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func error() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
    static func light() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func selection() { UISelectionFeedbackGenerator().selectionChanged() }
}
