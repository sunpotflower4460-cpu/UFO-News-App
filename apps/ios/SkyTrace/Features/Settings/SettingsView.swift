import SwiftUI

struct SettingsView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(AppSettings.self) private var settings
    @State private var paywall: PaywallContext?
    @State private var linkToOpen: IdentifiedURL?

    // Local (device-only) notification preferences for Phase 1.
    @AppStorage("notif.daily") private var notifDaily = false
    @AppStorage("notif.major") private var notifMajor = false
    @AppStorage("notif.saved") private var notifSaved = false
    @AppStorage("notif.region") private var notifRegion = false

    var body: some View {
        @Bindable var settings = settings
        NavigationStack {
            Form {
                subscriptionSection
                notificationsSection
                appearanceSection($settings)
                dataSection
                editorialSection
                legalSection
                supportSection
                aboutSection
                if env.flags.showsDeveloperTools { developerSection }
            }
            .scrollContentBackground(.hidden)
            .background(SkyColor.canvas)
            .navigationTitle(SkyStrings.t("settings.title"))
        }
        .sheet(item: $paywall) { PaywallView(context: $0) }
        .sheet(item: $linkToOpen) { SafariView(url: $0.url) }
    }

    // MARK: Sections

    private var subscriptionSection: some View {
        Section(SkyStrings.t("settings.section.subscription")) {
            HStack {
                Label(SkyStrings.t("label.plus"), systemImage: "sparkles").foregroundStyle(SkyColor.signalViolet)
                Spacer()
                Text(SkyStrings.t(env.subscription.entitlement.labelKey))
                    .foregroundStyle(SkyColor.textSecondary)
            }
            if !env.subscription.isPlus {
                Button(SkyStrings.t("paywall.cta")) { paywall = PaywallContext(trigger: .synthesis) }
                    .foregroundStyle(SkyColor.signalViolet)
            }
            Button(SkyStrings.t("settings.restore")) { Task { await env.subscription.restore() } }
            if let url = env.subscription.manageSubscriptionsURL {
                Button(SkyStrings.t("settings.manage")) { linkToOpen = IdentifiedURL(url: url) }
            }
            if let key = env.subscription.lastMessageKey {
                Text(SkyStrings.t(key)).font(.caption).foregroundStyle(SkyColor.textTertiary)
            }
        }
    }

    private var notificationsSection: some View {
        Section {
            Toggle(SkyStrings.t("settings.notif.daily"), isOn: $notifDaily)
            Toggle(SkyStrings.t("settings.notif.major"), isOn: $notifMajor)
            Toggle(SkyStrings.t("settings.notif.saved"), isOn: $notifSaved)
            Toggle(SkyStrings.t("settings.notif.region"), isOn: $notifRegion)
        } header: {
            Text(SkyStrings.t("settings.section.notifications"))
        } footer: {
            Text(SkyStrings.t("settings.notif.primer"))
        }
        .tint(SkyColor.signalCyan)
    }

    private func appearanceSection(_ settings: Bindable<AppSettings>) -> some View {
        Section(SkyStrings.t("settings.section.appearance")) {
            Picker(SkyStrings.t("settings.section.appearance"), selection: settings.appearance) {
                ForEach(AppSettings.Appearance.allCases) { Text(SkyStrings.t($0.labelKey)).tag($0) }
            }
            .pickerStyle(.segmented)
        }
    }

    private var dataSection: some View {
        Section(SkyStrings.t("settings.section.data")) {
            Button(SkyStrings.t("settings.clearCache"), role: .destructive) {
                // Phase 1 keeps only bookmarks/recent; clearing recents here.
                Haptics.light()
            }
        }
    }

    private var editorialSection: some View {
        Section(SkyStrings.t("settings.section.editorial")) {
            legalLink(.editorial); legalLink(.ai); legalLink(.scores); legalLink(.sources); legalLink(.correction)
        }
    }

    private var legalSection: some View {
        Section(SkyStrings.t("settings.section.legal")) {
            legalLink(.privacy); legalLink(.terms)
        }
    }

    private var supportSection: some View {
        Section(SkyStrings.t("settings.section.support")) {
            legalLink(.support)
        }
    }

    private var aboutSection: some View {
        Section(SkyStrings.t("settings.section.about")) {
            HStack {
                Text(SkyStrings.t("app.name")); Spacer()
                Text(AppInfo.versionString).foregroundStyle(SkyColor.textTertiary)
            }
        }
    }

    private var developerSection: some View {
        Section(SkyStrings.t("settings.section.developer")) {
            Picker(SkyStrings.t("settings.dev.dataSource"), selection: dataSourceBinding) {
                Text(SkyStrings.t("settings.dev.fixture")).tag(DataSourceMode.fixture)
                Text(SkyStrings.t("settings.dev.api")).tag(DataSourceMode.localAPI)
            }
            Menu(SkyStrings.t("settings.dev.entitlement")) {
                Button("Free") { overrideEntitlement(.free) }
                Button("Active") { overrideEntitlement(.active(expiresAt: nil)) }
                Button("Grace") { overrideEntitlement(.gracePeriod(expiresAt: nil)) }
                Button("Expired") { overrideEntitlement(.expired) }
                Button("Revoked") { overrideEntitlement(.revoked) }
            }
            Picker(SkyStrings.t("settings.dev.previewState"), selection: previewStateBinding) {
                ForEach(PreviewStateOverride.allCases) { Text($0.label).tag($0) }
            }
        }
    }

    // MARK: Helpers

    private func legalLink(_ page: LegalPage) -> some View {
        NavigationLink {
            LegalPageView(page: page)
        } label: {
            Label(SkyStrings.t(page.titleKey), systemImage: page.systemImage)
        }
    }

    private var dataSourceBinding: Binding<DataSourceMode> {
        Binding(get: { env.dataSource }, set: { env.dataSource = $0 })
    }

    private var previewStateBinding: Binding<PreviewStateOverride> {
        Binding(get: { settings.previewStateOverride }, set: { settings.previewStateOverride = $0 })
    }

    private func overrideEntitlement(_ state: EntitlementState) {
        // Debug-only: swap in a fake provider seeded with the chosen state.
        env.subscription.setProvider(FakeSubscriptionProvider(initial: state))
    }
}

enum AppInfo {
    static var versionString: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }
}

#Preview("Settings") {
    SettingsView().environment(AppEnvironment.preview()).environment(AppSettings())
}
