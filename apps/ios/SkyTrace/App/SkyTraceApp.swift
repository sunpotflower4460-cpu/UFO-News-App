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
                    // `scenePhase` may already be active when this view is first
                    // installed, in which case `onChange` does not fire. Start the
                    // idempotent poller here as well so cold launches refresh too.
                    refresh.startPolling()
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

/// Chooses between Welcome and the main tab experience, with a brief launch
/// title shown over it on cold start.
struct RootView: View {
    @Environment(AppSettings.self) private var settings
    @State private var showLaunch = true

    var body: some View {
        ZStack {
            Group {
                if settings.hasCompletedWelcome {
                    RootTabView()
                } else {
                    WelcomeFlow()
                }
            }
            if showLaunch {
                LaunchTitleView()
                    .transition(.opacity)
                    .zIndex(1)
                    .task {
                        // A brief brand moment on launch, then reveal the app.
                        try? await Task.sleep(nanoseconds: 1_200_000_000)
                        withAnimation(.easeOut(duration: 0.5)) { showLaunch = false }
                    }
            }
        }
    }
}

/// The launch title: the SkyTrace mark and tagline over an atmospheric backdrop,
/// shown briefly on cold start and then faded out by `RootView`. Decorative — the
/// mark is hidden from VoiceOver; the name is a header and the tagline is read.
struct LaunchTitleView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [SkyColor.aetherZenith, SkyColor.canvas, SkyColor.atmosphereBottom],
                           startPoint: .top, endPoint: .bottom)
            RadialGradient(colors: [SkyColor.aetherGlow.opacity(0.28), .clear],
                           center: UnitPoint(x: 0.5, y: 0.36), startRadius: 4, endRadius: 240)
            VStack(spacing: SkySpacing.x3) {
                ZStack {
                    Circle().stroke(SkyColor.aetherGlow.opacity(0.4), lineWidth: 1)
                        .frame(width: 96, height: 96)
                    Circle().stroke(SkyColor.accentPrimary, lineWidth: 1.5)
                        .frame(width: 62, height: 62)
                    Circle().fill(SkyColor.aetherGlow).frame(width: 8, height: 8)
                        .shadow(color: SkyColor.aetherGlow.opacity(0.7), radius: 10)
                }
                .scaleEffect(appeared || reduceMotion ? 1 : 0.92)
                .accessibilityHidden(true)
                Text(SkyStrings.t("app.name"))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(SkyColor.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text(SkyStrings.t("welcome.tagline"))
                    .font(SkyTypography.supporting)
                    .foregroundStyle(SkyColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SkySpacing.x8)
            }
            .opacity(appeared || reduceMotion ? 1 : 0)
            .offset(y: appeared || reduceMotion ? 0 : 8)
        }
        .ignoresSafeArea()
        .task {
            guard !reduceMotion else { return }
            withAnimation(.easeOut(duration: 0.7)) { appeared = true }
        }
    }
}
