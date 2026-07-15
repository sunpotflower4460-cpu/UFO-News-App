import SwiftUI
import Observation

/// User-facing display + preview settings persisted across launches.
@MainActor
@Observable
final class AppSettings {
    enum Appearance: String, CaseIterable, Identifiable {
        case system, dark, light
        var id: String { rawValue }
        var labelKey: String {
            switch self {
            case .system: "settings.appearance.system"
            case .dark: "settings.appearance.dark"
            case .light: "settings.appearance.light"
            }
        }
        var colorScheme: ColorScheme? {
            switch self { case .system: nil; case .dark: .dark; case .light: .light }
        }
    }

    /// How often the app auto-refreshes while in the foreground.
    enum RefreshInterval: String, CaseIterable, Identifiable {
        case min2, min5, min15
        var id: String { rawValue }
        var seconds: TimeInterval {
            switch self { case .min2: 120; case .min5: 300; case .min15: 900 }
        }
        var labelKey: String { "settings.refresh.interval.\(rawValue)" }
    }

    var appearance: Appearance {
        didSet { UserDefaults.standard.set(appearance.rawValue, forKey: Self.key) }
    }

    /// Whether the app refreshes automatically on foreground + on an interval.
    var autoRefreshEnabled: Bool {
        didSet { UserDefaults.standard.set(autoRefreshEnabled, forKey: Self.autoRefreshKey) }
    }

    /// The foreground poll cadence used when `autoRefreshEnabled` is true.
    var refreshInterval: RefreshInterval {
        didSet { UserDefaults.standard.set(refreshInterval.rawValue, forKey: Self.refreshIntervalKey) }
    }

    /// Debug: force a UI state for visual QA without changing real data.
    var previewStateOverride: PreviewStateOverride = .none
    var hasCompletedWelcome: Bool {
        didSet { UserDefaults.standard.set(hasCompletedWelcome, forKey: Self.welcomeKey) }
    }

    private static let key = "skytrace.appearance"
    private static let welcomeKey = "skytrace.welcomeDone"
    private static let autoRefreshKey = "skytrace.autoRefreshEnabled"
    private static let refreshIntervalKey = "skytrace.refreshInterval"

    init() {
        let raw = UserDefaults.standard.string(forKey: Self.key) ?? Appearance.dark.rawValue
        self.appearance = Appearance(rawValue: raw) ?? .dark
        // Auto-refresh defaults ON; the key is absent on first launch, so read
        // via object(forKey:) to distinguish "unset" (→ true) from "set false".
        let store = UserDefaults.standard
        self.autoRefreshEnabled = (store.object(forKey: Self.autoRefreshKey) as? Bool) ?? true
        self.refreshInterval = RefreshInterval(rawValue:
            store.string(forKey: Self.refreshIntervalKey) ?? "") ?? .min5
        let args = ProcessInfo.processInfo.arguments
        let uiTestSkip = args.contains("-uitest-skip-welcome")
        // Force the first-run Welcome flow for screenshot capture, clearing any
        // persisted completion so the state is deterministic across test methods.
        let uiTestShowWelcome = args.contains("-uitest-show-welcome")
        if uiTestShowWelcome { UserDefaults.standard.removeObject(forKey: Self.welcomeKey) }
        self.hasCompletedWelcome = !uiTestShowWelcome
            && (uiTestSkip || UserDefaults.standard.bool(forKey: Self.welcomeKey))
    }
}

/// Debug-only forced UI states for QA.
enum PreviewStateOverride: String, CaseIterable, Identifiable {
    case none, loading, empty, error, offline, partial
    var id: String { rawValue }
    var label: String {
        switch self {
        case .none: "Live"; case .loading: "Loading"; case .empty: "Empty"
        case .error: "Error"; case .offline: "Offline"; case .partial: "Partial"
        }
    }
}
