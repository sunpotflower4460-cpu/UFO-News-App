import Foundation
import UserNotifications
import Observation

/// OS notification authorization state, mapped to the four cases the UI needs.
enum NotificationAuthorizationState: Sendable, Equatable {
    case notDetermined
    case denied
    case authorized
    case provisional

    init(_ status: UNAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notDetermined
        case .denied: self = .denied
        case .authorized, .ephemeral: self = .authorized
        case .provisional: self = .provisional
        @unknown default: self = .notDetermined
        }
    }

    var labelKey: String {
        switch self {
        case .notDetermined: "notif.state.notDetermined"
        case .denied: "notif.state.denied"
        case .authorized: "notif.state.authorized"
        case .provisional: "notif.state.provisional"
        }
    }

    /// Whether per-topic toggles should be active.
    var allowsToggles: Bool { self == .authorized || self == .provisional }
}

/// Thin wrapper over `UNUserNotificationCenter` so Settings toggles reflect the
/// real OS permission instead of pretending. Value is explained before the
/// request (CLAUDE.md §9): the primer footer precedes any prompt.
@MainActor
@Observable
final class NotificationService {
    private(set) var state: NotificationAuthorizationState = .notDetermined

    func refresh() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        state = NotificationAuthorizationState(settings.authorizationStatus)
    }

    /// Requests authorization when undetermined, then reports the resulting state.
    @discardableResult
    func requestIfNeeded() async -> NotificationAuthorizationState {
        if state == .notDetermined {
            _ = try? await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        }
        await refresh()
        return state
    }
}
