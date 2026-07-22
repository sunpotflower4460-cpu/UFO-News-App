import Foundation

/// Compile-safe feature flags. Initial-release safety defaults are all-off for
/// anything sensitive or not yet connected end-to-end. UGC is unreachable in
/// Release regardless of this value.
struct FeatureFlags: Sendable {
    var ugcSubmissionEnabled = false
    var aiQAEnabled = false
    var cloudAccountEnabled = false
    var researchExportEnabled = false

    /// Notification preferences must not be exposed until delivery is connected
    /// end-to-end (APNs/local scheduling, topics, deep links, and privacy). The
    /// previous UI only stored toggles and could promise notifications that never
    /// arrived, so Release keeps the section hidden.
    var notificationsEnabled = false

    /// Whether developer-only UI may be shown. False in Release builds.
    var showsDeveloperTools: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }

    static let releaseDefaults = FeatureFlags()
}

/// Which data backend the app reads from. Fixture is available for previews and
/// explicit Debug testing; Release must not silently present fixtures as live
/// news when the production API is unavailable.
enum DataSourceMode: String, Sendable, CaseIterable, Identifiable {
    case fixture
    case localAPI
    var id: String { rawValue }
}
