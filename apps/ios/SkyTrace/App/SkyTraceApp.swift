import SwiftUI

@main
struct SkyTraceApp: App {
    @State private var environment: AppEnvironment
    @State private var settings = AppSettings()
    @State private var router = AppRouter()

    init() {
        // Fixture-backed by default; real StoreKit provider drives purchases via
        // the local .storekit config. No external credentials required.
        _environment = State(initialValue: AppEnvironment())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(environment)
                .environment(settings)
                .environment(router)
                .tint(SkyColor.signalCyan)
                .preferredColorScheme(settings.appearance.colorScheme)
                .task { await environment.subscription.refresh() }
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
