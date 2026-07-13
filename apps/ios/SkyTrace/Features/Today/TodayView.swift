import SwiftUI

struct TodayView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(AppSettings.self) private var settings
    @State private var model: TodayViewModel?
    @State private var paywall: PaywallContext?
    @State private var showBriefing = false

    var body: some View {
        NavigationStack {
            Group {
                if let model {
                    content(model)
                } else {
                    Color.clear
                }
            }
            .background(SkyColor.canvas)
            .navigationTitle(SkyStrings.t("today.title"))
            .skyDestinations()
        }
        .task {
            if model == nil {
                model = TodayViewModel(feedRepo: env.feedRepository,
                                       caseRepo: env.caseRepository, library: env.library)
            }
            await model?.load(forceState: settings.previewStateOverride)
        }
        .sheet(item: $paywall) { PaywallView(context: $0) }
    }

    @ViewBuilder
    private func content(_ model: TodayViewModel) -> some View {
        switch model.state {
        case .idle, .loading where model.state.value == nil:
            loadingSkeleton
        case .failed(let error, nil) where error != .offline:
            ErrorStateView { Task { await model.load() } }
        default:
            feedScroll(model)
        }
    }

    private func feedScroll(_ model: TodayViewModel) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: SkySpacing.x5) {
                if let feed = model.state.value {
                    banners(model, feed)
                    header(feed)
                    GlobalSummaryHero(summary: feed.summary, date: feed.date)
                    DailyBriefingCard(briefing: feed.briefing, isPlus: env.subscription.isPlus,
                                      onReadFull: { showBriefing = true },
                                      onUnlock: { paywall = PaywallContext(trigger: .briefing) })
                        .navigationDestination(isPresented: $showBriefing) {
                            BriefingDetailView(date: feed.date)
                        }
                    topCases(feed)
                    updates(feed)
                    savedUpdates(model)
                    editorialNote(feed)
                }
            }
            .padding(.horizontal, SkySpacing.screenEdge)
            .padding(.vertical, SkySpacing.x4)
        }
        .refreshable { await model.refresh() }
    }

    // MARK: Pieces

    @ViewBuilder
    private func banners(_ model: TodayViewModel, _ feed: TodayFeed) -> some View {
        if case .failed(.offline, _) = model.state {
            InlineBanner(kind: .offline) { Task { await model.load() } }
        }
        if model.state.isPartial {
            InlineBanner(kind: .partial)
        }
        if feed.topCases.contains(where: \.isDemo) || feed.recentUpdates.contains(where: \.isDemo) {
            InlineBanner(kind: .demo)
        }
    }

    private func header(_ feed: TodayFeed) -> some View {
        HStack {
            Text(SkyFormat.dateOnly(feed.date))
                .font(SkyTypography.metadata).foregroundStyle(SkyColor.textSecondary)
            Spacer()
            StaleBadge(date: feed.lastUpdatedAt)
        }
    }

    @ViewBuilder
    private func topCases(_ feed: TodayFeed) -> some View {
        if feed.topCases.isEmpty {
            EmptyStateView(messageKey: "empty.today")
        } else {
            VStack(alignment: .leading, spacing: SkySpacing.x3) {
                SectionHeader(title: SkyStrings.t("today.topCases"), systemImage: "star")
                ForEach(Array(feed.topCases.enumerated()), id: \.element.id) { index, item in
                    NavigationLink(value: CaseLink(id: item.id)) {
                        CaseCard(uapCase: item, variant: index == 0 ? .featured : .standard)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private func updates(_ feed: TodayFeed) -> some View {
        if !feed.recentUpdates.isEmpty {
            VStack(alignment: .leading, spacing: SkySpacing.x3) {
                SectionHeader(title: SkyStrings.t("today.updates"), systemImage: "arrow.triangle.2.circlepath")
                ForEach(feed.recentUpdates) { item in
                    NavigationLink(value: CaseLink(id: item.id)) {
                        CaseCard(uapCase: item, variant: .compact)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private func savedUpdates(_ model: TodayViewModel) -> some View {
        if !model.savedUpdates.isEmpty {
            VStack(alignment: .leading, spacing: SkySpacing.x3) {
                SectionHeader(title: SkyStrings.t("today.savedUpdates"), systemImage: "bookmark")
                ForEach(model.savedUpdates) { item in
                    NavigationLink(value: CaseLink(id: item.id)) {
                        CaseCard(uapCase: item, variant: .compact)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func editorialNote(_ feed: TodayFeed) -> some View {
        Text(feed.editorialNote)
            .font(SkyTypography.supporting).italic()
            .foregroundStyle(SkyColor.textTertiary)
            .padding(.top, SkySpacing.x2)
    }

    private var loadingSkeleton: some View {
        ScrollView {
            VStack(spacing: SkySpacing.x5) {
                ForEach(0..<4, id: \.self) { _ in SkeletonCard() }
            }
            .padding(.horizontal, SkySpacing.screenEdge)
            .padding(.vertical, SkySpacing.x4)
        }
    }
}

#Preview("Today · Free") {
    TodayView().environment(AppEnvironment.preview(entitlement: .free)).environment(AppSettings())
}
#Preview("Today · Plus") {
    TodayView().environment(AppEnvironment.preview(entitlement: .active(expiresAt: nil))).environment(AppSettings())
}
