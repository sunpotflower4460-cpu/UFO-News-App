import SwiftUI

/// V2 Today (docs/uiux 03 §3): World Sky Pulse → Daily Briefing lead → Priority
/// Case (with reason) → Since Your Last Visit → Case Stream. Global context
/// first, meaningful change before recency. Reachable from the debug Design
/// Gallery during bring-up; existing Today tab is untouched.
struct TodayV2View: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(AppSettings.self) private var settings
    @Environment(AppRouter.self) private var router
    @Environment(DataRefreshController.self) private var refresh
    @State private var model: TodayViewModel?

    var body: some View {
        Group {
            if let model {
                switch model.state {
                case .idle, .loading:
                    TodaySkeleton()
                case .loaded(let feed):
                    content(model, feed, stale: false)
                case .partial(let feed):
                    content(model, feed, stale: true)
                case .failed(_, .some(let feed)):
                    content(model, feed, stale: true)
                case .failed(_, .none):
                    ErrorStateView { Task { await model.load() } }
                }
            } else {
                TodaySkeleton()
            }
        }
        .background(SkyColor.canvas)
        .navigationTitle(SkyStrings.t("today.title"))
        // Re-runs whenever the refresh controller bumps its generation
        // (foreground return / interval poll), in addition to first appearance.
        .task(id: refresh.generation) {
            if model == nil {
                model = TodayViewModel(feedRepo: env.feedRepository, caseRepo: env.caseRepository, library: env.library)
            }
            await model?.load()
        }
    }

    private func content(_ model: TodayViewModel, _ feed: TodayFeed, stale: Bool) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: SkySpacing.x8) {
                if stale {
                    InlineBanner(kind: model.state.error == .offline ? .offline : .partial) {
                        Task { await model.refresh() }
                    }
                }
                WorldSkyPulse(date: feed.date, summary: feed.summary,
                              signals: WorldSkyPulse.signals(from: feed.topCases + feed.recentUpdates),
                              lastUpdated: feed.lastUpdatedAt,
                              updatedCount: feed.recentUpdates.count,
                              onOpenMap: { router.openMap() })
                if let fetched = refresh.lastRefreshed {
                    HStack(spacing: SkySpacing.x1) {
                        Spacer(minLength: 0)
                        StaleBadge(date: fetched)
                    }
                }
                briefingLead(feed)
                priorityCase(feed)
                sinceLastVisit(model)
                caseStream(feed)
                Text(feed.editorialNote).font(SkyTypography.supporting).italic()
                    .foregroundStyle(SkyColor.textTertiary)
            }
            .padding(.horizontal, SkySpacing.screenEdge)
            .padding(.vertical, SkySpacing.x4)
        }
        .refreshable { await model.refresh() }
    }

    // Daily Briefing — editorial lead, not a glass card.
    private func briefingLead(_ feed: TodayFeed) -> some View {
        EditorialSection(title: SkyStrings.t("briefing.title"), systemImage: "sun.horizon",
                         accent: SkyColor.signalViolet) {
            VStack(alignment: .leading, spacing: SkySpacing.x2) {
                Text(feed.briefing.headline).font(SkyTypography.cardHeadline).foregroundStyle(SkyColor.textPrimary)
                Text(feed.briefing.summary).font(SkyTypography.body).foregroundStyle(SkyColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Text(SkyStrings.t("briefing.usedCases",
                                      String(feed.briefing.usedCaseCount), String(feed.briefing.sourceCount)))
                    Spacer()
                    AIDisclosureBadge(disclosure: feed.briefing.disclosure)
                }
                .font(.caption2).foregroundStyle(SkyColor.textTertiary)
                // Everyone can open the briefing; BriefingDetailView shows the
                // free lead + Plus lock for non-subscribers (no dead CTA).
                NavigationLink { BriefingDetailView(date: feed.date) } label: {
                    Label(env.subscription.isPlus ? SkyStrings.t("action.readMore") : SkyStrings.t("briefing.readFull"),
                          systemImage: env.subscription.isPlus ? "arrow.right" : "lock.fill")
                        .font(SkyTypography.supporting.weight(.semibold))
                        .foregroundStyle(SkyColor.signalViolet)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder private func priorityCase(_ feed: TodayFeed) -> some View {
        if let lead = feed.topCases.first {
            EditorialSection(title: SkyStrings.t("today.topCases"), systemImage: "star") {
                VStack(alignment: .leading, spacing: SkySpacing.x2) {
                    if let reason = lead.priorityReason {
                        Label(reason, systemImage: "sparkles")
                            .font(SkyTypography.metadata).foregroundStyle(SkyColor.signalWarm)
                    }
                    NavigationLink { CaseDetailV2View(caseID: lead.id) } label: {
                        CaseCard(uapCase: lead, variant: .featured)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder private func sinceLastVisit(_ model: TodayViewModel) -> some View {
        let updates = (model.state.value?.recentUpdates ?? []).filter { !$0.whatChanged.isEmpty }
        if !updates.isEmpty {
            EditorialSection(title: SkyStrings.t("today.updates"), systemImage: "arrow.triangle.2.circlepath",
                             accent: SkyColor.signalWarm) {
                VStack(alignment: .leading, spacing: SkySpacing.x4) {
                    ForEach(updates) { c in
                        NavigationLink { CaseDetailV2View(caseID: c.id) } label: {
                            VStack(alignment: .leading, spacing: SkySpacing.x1) {
                                CaseStatusLabel(status: c.v2Status, showsUpdateIndicator: true)
                                Text(c.title).font(SkyTypography.supporting.weight(.semibold))
                                    .foregroundStyle(SkyColor.textPrimary).lineLimit(2)
                                if let change = c.whatChanged.first { CaseChangeRow(change: change) }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func caseStream(_ feed: TodayFeed) -> some View {
        EditorialSection(title: SkyStrings.t("research.updatedThisWeek"), systemImage: "square.stack.3d.up") {
            VStack(alignment: .leading, spacing: SkySpacing.x3) {
                ForEach(feed.topCases.dropFirst()) { c in
                    NavigationLink { CaseDetailV2View(caseID: c.id) } label: {
                        CaseCard(uapCase: c, variant: .compact)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

/// Loading skeleton for Today — a shaped placeholder instead of a lone spinner.
private struct TodaySkeleton: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SkySpacing.x6) {
                SkeletonBlock(height: 250).clipShape(RoundedRectangle(cornerRadius: SkyRadius.hero))
                SkeletonCard()
                SkeletonCard()
            }
            .padding(.horizontal, SkySpacing.screenEdge)
            .padding(.vertical, SkySpacing.x4)
        }
        .accessibilityLabel(SkyStrings.t("state.loading"))
    }
}

#Preview("Today V2") {
    NavigationStack { TodayV2View() }
        .environment(AppEnvironment.preview())
        .environment(AppSettings())
        .environment(AppRouter())
        .environment(DataRefreshController())
}
