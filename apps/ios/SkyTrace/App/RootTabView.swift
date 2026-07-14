import SwiftUI

/// The four-tab shell: 今日 / 地図 / 探す / 設定.
///
/// V2 (Aether) screens are now the shipping tabs; the Phase 1 screens remain in
/// the codebase (TodayView/MapView/ResearchView) and their previews, so the
/// switch is reversible and non-destructive.
struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack { TodayV2View() }
                .tabItem { Label(SkyStrings.t("tab.today"), systemImage: "sun.max") }
            NavigationStack { MapV2View() }
                .tabItem { Label(SkyStrings.t("tab.map"), systemImage: "map") }
            NavigationStack { SearchV2View() }
                .tabItem { Label(SkyStrings.t("tab.research"), systemImage: "magnifyingglass") }
            SettingsView()
                .tabItem { Label(SkyStrings.t("tab.settings"), systemImage: "gearshape") }
        }
        .tint(SkyColor.accentPrimary)
        .background(SkyColor.canvas)
    }
}

#Preview {
    RootTabView()
        .environment(AppEnvironment.preview())
        .environment(AppSettings())
}
