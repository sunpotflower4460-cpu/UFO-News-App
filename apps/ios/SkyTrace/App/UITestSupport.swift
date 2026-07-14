import Foundation

/// Launch-flag gates for deterministic UI-test / screenshot runs.
enum UITestFlags {
    /// Disables continuous (`repeatForever`) animations so XCUITest can reach
    /// quiescence — otherwise the shimmer/orbit loops block idle and cause
    /// "Timed out while acquiring background assertion". Passed by the
    /// screenshot UI tests; no effect in the shipping app.
    static let disableAnimations = ProcessInfo.processInfo.arguments.contains("-uitest-no-animations")
}
