import SwiftUI

@main
struct SkyTraceApp: App {
    @State private var environment: AppEnvironment
    @State private var settings: AppSettings
    @State private var router = AppRouter()
    @State private var refresh: DataRefreshController
    @Environment(\.scenePhase) private var scenePhase

    init() {
        let settings = AppSettings()
        _settings = State(initialValue: settings)

        // Fixtures are for development, previews, and deterministic UI tests.
        // Release starts on the production seam; if that seam is not configured,
        // repositories fail visibly instead of presenting demo cases as live news.
        #if DEBUG
        let source: DataSourceMode = .fixture
        #else
        let source: DataSourceMode = .localAPI
        #endif
        _environment = State(initialValue: AppEnvironment(dataSource: source))

        // The refresh controller reads live settings at poll time.
        _refresh = State(initialValue: DataRefreshController(
            isEnabled: { settings.autoRefreshEnabled },
            interval: { settings.refreshInterval.seconds }))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(environment)
                .environment(settings)
                .environment(router)
                .environment(refresh)
                .tint(SkyColor.signalCyan)
                .preferredColorScheme(settings.appearance.colorScheme)
                .task {
                    await environment.subscription.refresh()
                    environment.subscription.startObservingTransactions()
                }
                .onChange(of: scenePhase) { _, phase in
                    switch phase {
                    case .active:
                        // Returning to the foreground: refresh StoreKit and data,
                        // then resume foreground polling.
                        Task { await environment.subscription.refresh() }
                        if settings.autoRefreshEnabled { refresh.requestRefresh() }
                        refresh.startPolling()
                    case .background, .inactive:
                        refresh.stopPolling()
                    @unknown default:
                        break
                    }
                }
        }
    }
}

/// Chooses between Welcome and the main tab experience.
struct RootView: View {
    @Environment(AppSettings.self) private var settings

    var body: some View {
        if settings.hasCompletedWelcome {
            RootTabView()
        } else {
            WelcomeFlow()
        }
    }
}
