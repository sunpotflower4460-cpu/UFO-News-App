import SwiftUI

/// Two-screen first-run experience: a quiet welcome, then a short editorial
/// policy. No forced account, notifications, or paywall (UI_UX_PLAN 9.1).
struct WelcomeFlow: View {
    @Environment(AppSettings.self) private var settings
    @State private var page = 0
    @State private var showPolicy = false

    var body: some View {
        ZStack {
            SkyColor.canvas.ignoresSafeArea()
            TabView(selection: $page) {
                welcome.tag(0)
                policy.tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
        }
        .sheet(isPresented: $showPolicy) {
            NavigationStack { LegalPageView(page: .editorial) }
        }
    }

    private var welcome: some View {
        VStack(spacing: SkySpacing.x6) {
            Spacer()
            ObservationGlyph(seed: 11, animated: true)
                .frame(width: 180, height: 180)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(SkyColor.borderSubtle, lineWidth: 1))
            VStack(spacing: SkySpacing.x3) {
                Text(SkyStrings.t("app.name"))
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(SkyColor.textPrimary)
                Text(SkyStrings.t("welcome.tagline"))
                    .font(SkyTypography.body).foregroundStyle(SkyColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SkySpacing.x6)
            }
            Spacer()
            Button {
                withAnimation { page = 1 }
            } label: {
                Text(SkyStrings.t("action.start")).frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent).tint(SkyColor.signalCyan)
            .controlSize(.large)
            .padding(.horizontal, SkySpacing.x6)
            .padding(.bottom, SkySpacing.x10)
        }
    }

    private var policy: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x5) {
            Spacer()
            Text(SkyStrings.t("welcome.policyTitle"))
                .font(SkyTypography.screenHero).foregroundStyle(SkyColor.textPrimary)
            VStack(alignment: .leading, spacing: SkySpacing.x4) {
                policyRow("checkmark.shield", SkyStrings.t("welcome.policy1"))
                policyRow("link", SkyStrings.t("welcome.policy2"))
                policyRow("lock.open", SkyStrings.t("welcome.policy3"))
            }
            Text(SkyStrings.t("welcome.center"))
                .font(SkyTypography.supporting).italic()
                .foregroundStyle(SkyColor.textTertiary)
            Spacer()
            Button {
                Haptics.light()
                settings.hasCompletedWelcome = true
            } label: {
                Text(SkyStrings.t("action.continue")).frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent).tint(SkyColor.signalCyan).controlSize(.large)
            Button(SkyStrings.t("action.viewPolicy")) { showPolicy = true }
                .frame(maxWidth: .infinity)
                .foregroundStyle(SkyColor.textSecondary)
                .padding(.bottom, SkySpacing.x8)
        }
        .padding(.horizontal, SkySpacing.x6)
    }

    private func policyRow(_ symbol: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: SkySpacing.x3) {
            Image(systemName: symbol).foregroundStyle(SkyColor.signalCyan).frame(width: 26)
            Text(text).font(SkyTypography.body).foregroundStyle(SkyColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    WelcomeFlow().environment(AppSettings()).environment(AppEnvironment.preview())
}
