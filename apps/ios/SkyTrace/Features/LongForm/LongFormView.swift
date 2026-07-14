import SwiftUI

/// Long-form synthesis reading (docs/uiux 03 §8): header metadata + AI
/// disclosure, stable Editorial Surface at a comfortable reading width, inline
/// citations, caveats, and revision note. Free readers get the lead + a
/// contextual Plus lock (facts/corrections stay free). Reachable from Case
/// Detail V2 and the debug Design Gallery.
struct LongFormView: View {
    let article: SynthesizedArticle
    @Environment(AppEnvironment.self) private var env
    @State private var paywall: PaywallContext?

    private var isPlus: Bool { env.subscription.isPlus }

    var body: some View {
        ScrollView {
            EditorialSurface {
                VStack(alignment: .leading, spacing: SkySpacing.x5) {
                    header
                    Divider().overlay(SkyColor.separator)
                    let free = article.blocks.filter { !$0.isPremiumGated }
                    let gated = article.blocks.filter { $0.isPremiumGated }
                    ForEach(free) { ArticleBlockView(block: $0) }
                    if isPlus {
                        ForEach(gated) { ArticleBlockView(block: $0) }
                        if let note = article.correctionNote { correction(note) }
                    } else if !gated.isEmpty {
                        PremiumLockView(
                            title: SkyStrings.t("briefing.readFull"),
                            unlocks: [SkyStrings.t("paywall.feature.synthesis"),
                                      SkyStrings.t("paywall.feature.evidence")],
                            ctaTitle: SkyStrings.t("paywall.cta"),
                            onUnlock: { paywall = PaywallContext(trigger: .synthesis) })
                    }
                    disclosureFooter
                }
            }
            .padding(.horizontal, SkySpacing.screenEdge)
            .padding(.vertical, SkySpacing.x4)
        }
        .background(SkyColor.canvas)
        .navigationTitle(SkyStrings.t("case.article"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $paywall) { PaywallView(context: $0) }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x2) {
            AIDisclosureBadge(disclosure: article.disclosure)
            Text(article.headline).font(SkyTypography.screenHero).foregroundStyle(SkyColor.textPrimary)
            Text(article.dek).font(SkyTypography.body).foregroundStyle(SkyColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: SkySpacing.x3) {
                Label(SkyStrings.t("briefing.readMinutes", String(article.readingMinutes)), systemImage: "clock")
                Label("v\(article.versionNumber)", systemImage: "clock.arrow.circlepath")
                Text(SkyStrings.t("briefing.generatedAt", SkyFormat.dateOnly(article.generatedAt)))
            }
            .font(.caption2).foregroundStyle(SkyColor.textTertiary)
        }
    }

    private func correction(_ note: String) -> some View {
        HStack(alignment: .top, spacing: SkySpacing.x2) {
            Image(systemName: "pencil.and.outline").foregroundStyle(SkyColor.signalWarm)
            Text(note).font(SkyTypography.supporting).foregroundStyle(SkyColor.signalWarm)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(SkySpacing.x3)
        .background(SkyColor.signalWarm.opacity(0.10), in: RoundedRectangle(cornerRadius: SkyRadius.chip))
    }

    private var disclosureFooter: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x1) {
            Divider().overlay(SkyColor.separator)
            Text(SkyStrings.t("ai.disclosureNote"))
                .font(.caption2).foregroundStyle(SkyColor.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
            Text("\(article.modelLabel) · \(article.promptVersion)")
                .font(.caption2).foregroundStyle(SkyColor.textTertiary)
        }
    }
}

#Preview("Long-form") {
    NavigationStack { LongFormView(article: DemoArticles.northSea) }
        .environment(AppEnvironment.preview(entitlement: .active(expiresAt: nil)))
        .environment(AppSettings())
}
