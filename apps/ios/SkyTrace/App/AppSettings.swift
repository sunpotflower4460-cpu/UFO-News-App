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

    var appearance: Appearance {
        didSet { UserDefaults.standard.set(appearance.rawValue, forKey: Self.key) }
    }

    /// Debug: force a UI state for visual QA without changing real data.
    var previewStateOverride: PreviewStateOverride = .none
    var hasCompletedWelcome: Bool {
        didSet { UserDefaults.standard.set(hasCompletedWelcome, forKey: Self.welcomeKey) }
    }

    private static let key = "skytrace.appearance"
    private static let welcomeKey = "skytrace.welcomeDone"

    init() {
        let raw = UserDefaults.standard.string(forKey: Self.key) ?? Appearance.dark.rawValue
        self.appearance = Appearance(rawValue: raw) ?? .dark
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
