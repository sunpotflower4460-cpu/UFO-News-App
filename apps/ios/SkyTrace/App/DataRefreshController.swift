import SwiftUI
import Observation

/// Drives automatic data refresh across the app. Screens observe `generation`
/// (via `.task(id:)`) and re-load whenever it changes; `requestRefresh()` bumps
/// it. A foreground poll re-requests on an interval while the app is active —
/// and stays off in the background, under Low Power Mode, when the user has
/// disabled auto-refresh, or during UI-test runs.
///
/// The controller is transport-agnostic: it only signals "refresh now". The
/// actual fetch happens in each screen's ViewModel through the shared
/// repositories, so it surfaces real content automatically once the `.localAPI`
/// repository seam is backed by a live feed (Phase 2 backend).
@MainActor
@Observable
final class DataRefreshController {
    /// Bumped on every refresh request; screens key `.task(id:)` on it.
    private(set) var generation: Int = 0
    /// When the last refresh was requested — surfaced as a "last updated" hint.
    private(set) var lastRefreshed: Date?

    // Read live at poll time so changing the setting takes effect immediately.
    private let isEnabled: @MainActor () -> Bool
    private let interval: @MainActor () -> TimeInterval
    private let now: @MainActor () -> Date
    private var pollTask: Task<Void, Never>?

    init(isEnabled: @escaping @MainActor () -> Bool = { true },
         interval: @escaping @MainActor () -> TimeInterval = { 300 },
         now: @escaping @MainActor () -> Date = { Date() }) {
        self.isEnabled = isEnabled
        self.interval = interval
        self.now = now
    }

    /// Trigger a refresh now: bump the generation and stamp the time.
    func requestRefresh() {
        generation &+= 1
        lastRefreshed = now()
    }

    /// Start the foreground poll loop (idempotent). No-op during UI tests so
    /// screenshot/UITest runs stay deterministic and can reach idle.
    func startPolling() {
        guard pollTask == nil, !UITestFlags.disableAnimations else { return }
        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                try? await Task.sleep(for: .seconds(self.interval()))
                if Task.isCancelled { return }
                if self.isEnabled(), !ProcessInfo.processInfo.isLowPowerModeEnabled {
                    self.requestRefresh()
                }
            }
        }
    }

    /// Stop the poll loop (e.g. when the app leaves the foreground).
    func stopPolling() {
        pollTask?.cancel()
        pollTask = nil
    }
}
