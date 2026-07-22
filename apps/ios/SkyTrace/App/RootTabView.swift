import SwiftUI

/// The four-tab shell: 今日 / 地図 / 探す / 設定.
///
/// V2 (Aether) screens are now the shipping tabs; the Phase 1 screens remain in
/// the codebase (TodayView/MapView/ResearchView) and their previews, so the
/// switch is reversible and non-destructive.
struct RootTabView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.selectedTab) {
            NavigationStack { TodayV2View() }
                .tabItem {
                    Label(SkyStrings.t("tab.today"), systemImage: "sun.max")
                        .accessibilityIdentifier("tab.today")
                }
                .tag(AppTab.today)
            NavigationStack { MapV2View() }
                .tabItem {
                    Label(SkyStrings.t("tab.map"), systemImage: "map")
                        .accessibilityIdentifier("tab.map")
                }
                .tag(AppTab.map)
            NavigationStack { SearchV2View() }
                .tabItem {
                    Label(SkyStrings.t("tab.research"), systemImage: "magnifyingglass")
                        .accessibilityIdentifier("tab.research")
                }
                .tag(AppTab.explore)
            SettingsView()
                .tabItem {
                    Label(SkyStrings.t("tab.settings"), systemImage: "gearshape")
                        .accessibilityIdentifier("tab.settings")
                }
                .tag(AppTab.settings)
        }
        .tint(SkyColor.accentPrimary)
        .background(SkyColor.canvas)
    }
}

#Preview {
    RootTabView()
        .environment(AppEnvironment.preview())
        .environment(AppSettings())
        .environment(AppRouter())
        .environment(DataRefreshController())
}
