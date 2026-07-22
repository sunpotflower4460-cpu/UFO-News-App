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
        tabs(selection: $router.selectedTab)
            .skyTraceTopLevelTabStyle()
            .tint(SkyColor.accentPrimary)
            .background(SkyColor.canvas)
    }

    private func tabs(selection: Binding<AppTab>) -> some View {
        TabView(selection: selection) {
            NavigationStack { TodayV2View() }
                .tabItem {
                    Label(SkyStrings.t("tab.today"), systemImage: "sun.max")
                        .accessibilityIdentifier("tab.today")
                }
                .tag(AppTab.today)
            NavigationStack { MapV2View() }
                .accessibilityIdentifier("screen.map")
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
    }
}

private extension View {
    /// iPadOS can adapt automatic tabs into a sidebar representation whose
    /// controls are hidden until expanded. SkyTrace has only four peer
    /// destinations, so keep them continuously reachable as a tab bar.
    @ViewBuilder
    func skyTraceTopLevelTabStyle() -> some View {
        if #available(iOS 18.0, *) {
            tabViewStyle(.tabBarOnly)
        } else {
            self
        }
    }
}

#Preview {
    RootTabView()
        .environment(AppEnvironment.preview())
        .environment(AppSettings())
        .environment(AppRouter())
        .environment(DataRefreshController())
}
