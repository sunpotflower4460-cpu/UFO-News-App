import UIKit

/// Thin haptics wrapper. Used only for meaningful moments (bookmark, filter,
/// refresh complete, purchase, error) — never on ordinary taps/scrolls.
enum Haptics {
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func error() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
    static func light() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func selection() { UISelectionFeedbackGenerator().selectionChanged() }
}
