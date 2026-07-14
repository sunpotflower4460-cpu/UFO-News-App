import SwiftUI

/// Two-screen first-run experience: a quiet welcome, then a short editorial
/// policy. No forced account, notifications, or paywall (UI_UX_PLAN 9.1).
///
/// The first screen sets the tone: a dimensional night sky (AtmosphereCanvas)
/// with a luminous observation lens (AetherOrb). Atmospheric but legible —
/// motion stops under Reduce Motion, glow softens under Reduce Transparency.
struct WelcomeFlow: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0
    @State private var showPolicy = false
    @State private var bob: CGFloat = 0

    private let ambientSignals: [AtmosphereSignal] = [
        .init(x: 0.22, y: 0.28, color: SkyColor.statusNew, emphasized: true),
        .init(x: 0.62, y: 0.52, color: SkyColor.statusReview),
        .init(x: 0.80, y: 0.36, color: SkyColor.statusInsufficient),
        .init(x: 0.40, y: 0.66, color: SkyColor.statusLikelyKnown),
    ]

    var body: some View {
        ZStack {
            backdrop
            TabView(selection: $page) {
                welcome.tag(0)
                policy.tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) { bob = 10 }
        }
        .sheet(isPresented: $showPolicy) {
            NavigationStack { LegalPageView(page: .editorial) }
        }
    }

    // Shared dimensional sky behind both pages, with a focusing vignette.
    private var backdrop: some View {
        AtmosphereCanvas(dayFraction: 0.16, signals: ambientSignals,
                         parallax: CGSize(width: 0, height: -bob * 0.3))
            .ignoresSafeArea()
            .overlay {
                RadialGradient(colors: [.clear, SkyColor.aetherZenith.opacity(0.55)],
                               center: .center, startRadius: 120, endRadius: 520)
                    .ignoresSafeArea()
            }
            .overlay(alignment: .bottom) {
                LinearGradient(colors: [.clear, SkyColor.aetherZenith.opacity(0.7)],
                               startPoint: .center, endPoint: .bottom)
                    .frame(height: 260).ignoresSafeArea()
            }
            .allowsHitTesting(false)
    }

    private var welcome: some View {
        VStack(spacing: SkySpacing.x6) {
            Spacer()
            AetherOrb(seed: 11, parallax: CGSize(width: 0, height: bob))
                .frame(width: 236, height: 236)
            VStack(spacing: SkySpacing.x3) {
                Text(SkyStrings.t("app.name"))
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(SkyColor.textPrimary)
                    .shadow(color: SkyColor.aetherGlow.opacity(0.45), radius: 14)
                Text(SkyStrings.t("welcome.tagline"))
                    .font(SkyTypography.body).foregroundStyle(SkyColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SkySpacing.x6)
            }
            Spacer()
            Button {
                Haptics.light()
                withAnimation { page = 1 }
            } label: {
                Text(SkyStrings.t("action.start")).frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent).tint(SkyColor.accentPrimary)
            .controlSize(.large)
            .shadow(color: SkyColor.aetherGlow.opacity(0.35), radius: 16, y: 4)
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
            .padding(SkySpacing.x4)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: SkyRadius.card, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: SkyRadius.card, style: .continuous)
                .strokeBorder(SkyColor.borderSubtle, lineWidth: 1))
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
            .buttonStyle(.borderedProminent).tint(SkyColor.accentPrimary).controlSize(.large)
            Button(SkyStrings.t("action.viewPolicy")) { showPolicy = true }
                .frame(maxWidth: .infinity)
                .foregroundStyle(SkyColor.textSecondary)
                .padding(.bottom, SkySpacing.x8)
        }
        .padding(.horizontal, SkySpacing.x6)
    }

    private func policyRow(_ symbol: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: SkySpacing.x3) {
            Image(systemName: symbol).foregroundStyle(SkyColor.accentPrimary).frame(width: 26)
            Text(text).font(SkyTypography.body).foregroundStyle(SkyColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    WelcomeFlow().environment(AppSettings()).environment(AppEnvironment.preview())
}
