import SwiftUI

/// The four-tab shell: 今日 / 地図 / 探す / 設定.
struct RootTabView: View {
    @Environment(AppEnvironment.self) private var env

    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label(SkyStrings.t("tab.today"), systemImage: "sun.max") }
            MapView()
                .tabItem { Label(SkyStrings.t("tab.map"), systemImage: "map") }
            ResearchView()
                .tabItem { Label(SkyStrings.t("tab.research"), systemImage: "magnifyingglass") }
            SettingsView()
                .tabItem { Label(SkyStrings.t("tab.settings"), systemImage: "gearshape") }
        }
        .tint(SkyColor.signalCyan)
        .background(SkyColor.canvas)
    }
}

#Preview {
    RootTabView()
        .environment(AppEnvironment.preview())
        .environment(AppSettings())
}
