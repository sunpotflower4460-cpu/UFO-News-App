import SwiftUI

/// Premium "SNSでの目撃報告" — a swipeable stream of social-media-sourced
/// references gathered across cases. This screen deliberately does **not**
/// rank, score, or filter posts by how likely they are to "really" show a
/// UFO: every card is labelled an unverified report and links to its
/// original post, exactly like the `.social` sources already shown lower on
/// Case Detail (CLAUDE.md §2/§6; SKYTRACE_NEWS_FIRST_PRODUCTION_DIRECTIVE
/// §17 bans "UFO確率"/"AIが判定"). Populating this from real platforms
/// requires an approved Tier D provider (docs/DATA_SOURCE_REGISTRY.md) — until
/// then it only ever shows the same fixture `.social` sources already used
/// elsewhere in the app, never a separately-scraped feed.
struct SocialReportsSwipeView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var candidates: [SocialReportCandidate] = []
    @State private var didLoad = false
    @State private var linkToOpen: IdentifiedURL?
    @State private var paywall: PaywallContext?

    var body: some View {
        Group {
            if !env.subscription.isPlus {
                ScrollView {
                    PremiumLockView(
                        title: SkyStrings.t("social.title"),
                        unlocks: [SkyStrings.t("social.unlockReports"), SkyStrings.t("social.unlockOriginalLinks")],
                        ctaTitle: SkyStrings.t("paywall.cta"),
                        onUnlock: { paywall = PaywallContext(trigger: .socialReports) }
                    )
                    .padding(SkySpacing.screenEdge)
                }
            } else if !didLoad {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if candidates.isEmpty {
                EmptyStateView(messageKey: "social.empty", systemImage: "bubble.left.and.bubble.right")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                cardStack
            }
        }
        .background(SkyColor.canvas)
        .navigationTitle(SkyStrings.t("social.title"))
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
        .sheet(item: $linkToOpen) { SafariView(url: $0.url) }
        .sheet(item: $paywall) { PaywallView(context: $0) }
    }

    private func load() async {
        do {
            let all = try await env.caseRepository.allCases()
            try Task.checkCancellation()
            candidates = all.socialReportCandidates
        } catch is CancellationError {
            return
        } catch {
            candidates = []
        }
        didLoad = true
    }

    /// A horizontally paged stack — swipe left/right between reports. Each
    /// page is a full card so VoiceOver reads one report at a time.
    private var cardStack: some View {
        TabView {
            ForEach(candidates) { candidate in
                ScrollView {
                    SocialReportCard(candidate: candidate, onOpenLink: { linkToOpen = IdentifiedURL(url: $0) })
                        .padding(SkySpacing.screenEdge)
                }
                .tag(candidate.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

private struct SocialReportCard: View {
    let candidate: SocialReportCandidate
    var onOpenLink: (URL) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x4) {
            HStack(spacing: SkySpacing.x2) {
                unverifiedBadge
                if candidate.isDemo { DemoBadge() }
                Spacer(minLength: 0)
            }
            ForEach(candidate.media) { asset in
                MediaAssetView(asset: asset, onOpenSource: onOpenLink)
            }
            VStack(alignment: .leading, spacing: SkySpacing.x1) {
                HStack(spacing: SkySpacing.x2) {
                    Image(systemName: candidate.source.sourceType.systemImage).foregroundStyle(SkyColor.signalCyan)
                    Text(candidate.source.outletName)
                        .font(SkyTypography.supporting.weight(.semibold))
                        .foregroundStyle(SkyColor.textPrimary)
                }
                Text(candidate.source.title)
                    .font(SkyTypography.body).foregroundStyle(SkyColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                if let excerpt = candidate.source.allowedExcerpt, !excerpt.isEmpty {
                    Text(excerpt).font(SkyTypography.supporting).foregroundStyle(SkyColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let published = candidate.source.publishedAt {
                    Text(SkyFormat.dateOnly(published)).font(.caption2).foregroundStyle(SkyColor.textTertiary)
                }
            }
            NavigationLink { CaseDetailV2View(caseID: candidate.caseID) } label: {
                HStack(spacing: SkySpacing.x1) {
                    CaseStatusGlyph(status: SkyCaseStatus(candidate.caseStatus), size: 16)
                    Text(candidate.caseTitle).font(SkyTypography.supporting.weight(.medium)).lineLimit(2)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right").font(.caption)
                }
                .foregroundStyle(SkyColor.accentSecondary)
            }
            .buttonStyle(.plain)
            if let url = candidate.source.url {
                Button {
                    onOpenLink(url)
                } label: {
                    Label(SkyStrings.t("social.viewOriginalPost"), systemImage: "arrow.up.right.square")
                        .font(SkyTypography.supporting.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(SkyColor.accentPrimary)
                .accessibilityIdentifier("social.viewOriginal.\(candidate.id)")
            }
            Text(SkyStrings.t("social.disclosureNote"))
                .font(.caption2).foregroundStyle(SkyColor.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(SkySpacing.x4)
        .cardSurface()
        .accessibilityIdentifier("social.card.\(candidate.id)")
    }

    private var unverifiedBadge: some View {
        Label(SkyStrings.t("social.unverifiedBadge"), systemImage: "questionmark.circle")
            .font(SkyTypography.metadata.weight(.semibold))
            .foregroundStyle(SkyColor.signalAmber)
            .padding(.horizontal, SkySpacing.x2).padding(.vertical, SkySpacing.x1)
            .background(SkyColor.signalAmber.opacity(0.14), in: Capsule())
    }
}

#Preview("Social Reports — Plus") {
    NavigationStack { SocialReportsSwipeView() }
        .environment(AppEnvironment.preview(entitlement: .active(expiresAt: nil)))
        .environment(AppSettings())
}

#Preview("Social Reports — Free") {
    NavigationStack { SocialReportsSwipeView() }
        .environment(AppEnvironment.preview())
        .environment(AppSettings())
}
