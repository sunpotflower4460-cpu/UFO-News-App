import SwiftUI

/// Full Daily Briefing (Plus). Free users reaching here see the lead plus a
/// contextual lock rather than a blur.
struct BriefingDetailView: View {
    let date: Date
    @Environment(AppEnvironment.self) private var env
    @State private var briefing: DailyBriefing?
    @State private var paywall: PaywallContext?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SkySpacing.x4) {
                if let briefing {
                    header(briefing)
                    if env.subscription.isPlus {
                        ForEach(briefing.blocks) { ArticleBlockView(block: $0) }
                        tomorrow(briefing)
                    } else {
                        ForEach(briefing.blocks.prefix(2)) { ArticleBlockView(block: $0) }
                        PremiumLockView(
                            title: SkyStrings.t("briefing.readFull"),
                            unlocks: [SkyStrings.t("paywall.feature.briefing"),
                                      SkyStrings.t("paywall.feature.tracking")],
                            ctaTitle: SkyStrings.t("paywall.cta"),
                            onUnlock: { paywall = PaywallContext(trigger: .briefing) })
                    }
                } else {
                    ProgressView().frame(maxWidth: .infinity).padding()
                }
            }
            .padding(.horizontal, SkySpacing.screenEdge)
            .padding(.vertical, SkySpacing.x4)
            .readingWidth()
        }
        .background(SkyColor.canvas)
        .navigationTitle(SkyStrings.t("briefing.title"))
        .navigationBarTitleDisplayMode(.inline)
        .task { briefing = try? await env.briefingRepository.briefing(for: date) }
        .sheet(item: $paywall) { PaywallView(context: $0) }
    }

    private func header(_ b: DailyBriefing) -> some View {
        VStack(alignment: .leading, spacing: SkySpacing.x2) {
            AIDisclosureBadge(disclosure: b.disclosure)
            Text(b.headline).font(SkyTypography.screenHero).foregroundStyle(SkyColor.textPrimary)
            Text(b.summary).font(SkyTypography.body).foregroundStyle(SkyColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Text(SkyStrings.t("briefing.usedCases", String(b.usedCaseCount), String(b.sourceCount)))
                Spacer()
                Text(SkyStrings.t("briefing.readMinutes", String(b.readingMinutes)))
            }
            .font(.caption2).foregroundStyle(SkyColor.textTertiary)
            Divider().overlay(SkyColor.borderSubtle)
        }
    }

    private func tomorrow(_ b: DailyBriefing) -> some View {
        VStack(alignment: .leading, spacing: SkySpacing.x2) {
            SectionHeader(title: SkyStrings.t("briefing.tomorrow"), systemImage: "moon.stars")
            ForEach(b.tomorrowWatch, id: \.self) { item in
                HStack(alignment: .top, spacing: SkySpacing.x2) {
                    Image(systemName: "circle.fill").font(.system(size: 5))
                        .foregroundStyle(SkyColor.signalCyan).padding(.top, 6)
                    Text(item).font(SkyTypography.body).foregroundStyle(SkyColor.textPrimary)
                }
            }
        }
        .cardSurface()
    }
}

#Preview {
    NavigationStack { BriefingDetailView(date: FixtureClock.today) }
        .environment(AppEnvironment.preview(entitlement: .active(expiresAt: nil)))
        .environment(AppSettings())
}
