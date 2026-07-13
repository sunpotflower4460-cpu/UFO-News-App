import Foundation

/// Compile-safe feature flags. Initial-release safety defaults are all-off for
/// anything sensitive; UGC is unreachable in Release regardless of this value.
struct FeatureFlags: Sendable {
    var ugcSubmissionEnabled = false
    var aiQAEnabled = false
    var cloudAccountEnabled = false
    var researchExportEnabled = false

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

/// Which data backend the app reads from. Fixture is the Phase 1 default.
enum DataSourceMode: String, Sendable, CaseIterable, Identifiable {
    case fixture
    case localAPI
    var id: String { rawValue }
}
