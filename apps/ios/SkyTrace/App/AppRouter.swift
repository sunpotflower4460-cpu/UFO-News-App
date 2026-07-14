import SwiftUI
import Observation

/// The four shipping tabs. Used as the `TabView` selection so code can navigate
/// across tabs (e.g. Today's "地図で見る" CTA → Map).
enum AppTab: Hashable, Sendable {
    case today
    case map
    case explore
    case settings
}

/// App-level navigation state. Owns the selected tab and any cross-tab focus
/// request (e.g. focus a specific case on the Map after a tap elsewhere).
/// Injected once at the app root; screens read it from the environment.
@MainActor
@Observable
final class AppRouter {
    var selectedTab: AppTab = .today
    /// When set, the Map should focus this case (and clear the request).
    var mapFocusCaseID: String?

    /// Switch to the Map tab, optionally focusing a specific case.
    func openMap(focus caseID: String? = nil) {
        mapFocusCaseID = caseID
        selectedTab = .map
    }
}
