import SwiftUI

/// Premium "SNSでの目撃報告" — a swipeable stream of social-media-sourced
/// references gathered across cases. This screen deliberately does **not**
/// rank, score, or filter posts by how likely they are to "really" show a
/// UFO: every card is labelled an unverified report and links to its
/// original post, exactly like the `.social` sources already shown lower on
/// Case Detail (CLAUDE.md §2/§6; SKYTRACE_NEWS_FIRST_PRODUCTION_DIRECTIVE
/// §17 bans "UFO確率"/"AIが判定"). The only filter/sort offered here is by
/// plain category (shape tag, already used elsewhere in Research) and by
/// date — never by a computed likelihood. Populating this from real
/// platforms requires an approved Tier D provider
/// (docs/DATA_SOURCE_REGISTRY.md); until then it only shows fixture data via
/// `SocialReportsRepository`, never a separately-scraped feed.
struct SocialReportsSwipeView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var state: Loadable<[SocialReportCandidate]> = .idle
    @State private var linkToOpen: IdentifiedURL?
    @State private var paywall: PaywallContext?
    @State private var selectedShapeTags: Set<String> = []
    @State private var sortOrder: SocialReportSortOrder = .caseOrder
    @State private var selection: String = ""

    var body: some View {
        Group {
            if !env.subscription.isPlus {
                lockedState
            } else {
                switch state {
                case .idle, .loading:
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                case .loaded(let items), .partial(let items):
                    content(items)
                case .failed(_, .some(let cached)) where !cached.isEmpty:
                    content(cached)
                case .failed:
                    ErrorStateView { Task { await load() } }
                }
            }
        }
        .background(SkyColor.canvas)
        .navigationTitle(SkyStrings.t("social.title"))
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
        .sheet(item: $linkToOpen) { SafariView(url: $0.url) }
        .sheet(item: $paywall) { PaywallView(context: $0) }
    }

    private var lockedState: some View {
        ScrollView {
            PremiumLockView(
                title: SkyStrings.t("social.title"),
                unlocks: [SkyStrings.t("social.unlockReports"), SkyStrings.t("social.unlockOriginalLinks")],
                ctaTitle: SkyStrings.t("paywall.cta"),
                onUnlock: { paywall = PaywallContext(trigger: .socialReports) }
            )
            .padding(SkySpacing.screenEdge)
        }
    }

    private func load() async {
        if state.value == nil { state = .loading }
        do {
            let items = try await env.socialReportsRepository.socialReports()
            try Task.checkCancellation()
            state = .loaded(items)
        } catch is CancellationError {
            return
        } catch let error as RepositoryError {
            state = .failed(error, cached: state.value)
        } catch {
            state = .failed(.unknown(error.localizedDescription), cached: state.value)
        }
    }

    // MARK: Filter / sort (categorical + chronological only — never a score)

    private func allShapeTags(_ items: [SocialReportCandidate]) -> [String] {
        Array(Set(items.flatMap(\.caseShapeTags))).sorted()
    }

    private func displayed(_ items: [SocialReportCandidate]) -> [SocialReportCandidate] {
        var out = selectedShapeTags.isEmpty
            ? items
            : items.filter { !selectedShapeTags.isDisjoint(with: Set($0.caseShapeTags)) }
        switch sortOrder {
        case .caseOrder: break
        case .newestFirst: out.sort { $0.sortDate > $1.sortDate }
        case .oldestFirst: out.sort { $0.sortDate < $1.sortDate }
        }
        return out
    }

    private func toggleTag(_ tag: String) {
        if selectedShapeTags.contains(tag) { selectedShapeTags.remove(tag) } else { selectedShapeTags.insert(tag) }
    }

    private func content(_ all: [SocialReportCandidate]) -> some View {
        let items = displayed(all)
        return VStack(spacing: 0) {
            controlsBar(all: all, shown: items.count)
            if items.isEmpty {
                EmptyStateView(messageKey: "social.filterEmpty", systemImage: "line.3.horizontal.decrease.circle")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                cardStack(items)
            }
        }
        .onAppear { if selection.isEmpty { selection = items.first?.id ?? "" } }
        .onChange(of: items.map(\.id)) { _, ids in
            if !ids.contains(selection) { selection = ids.first ?? "" }
        }
    }

    private func controlsBar(all: [SocialReportCandidate], shown: Int) -> some View {
        VStack(alignment: .leading, spacing: SkySpacing.x2) {
            let tags = allShapeTags(all)
            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: SkySpacing.x2) {
                        ForEach(tags, id: \.self) { tag in
                            Button { toggleTag(tag) } label: {
                                SkyChip(text: tag, systemImage: "number", isSelected: selectedShapeTags.contains(tag))
                            }
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(selectedShapeTags.contains(tag) ? [.isButton, .isSelected] : .isButton)
                        }
                    }
                    .padding(.horizontal, SkySpacing.screenEdge)
                }
            }
            HStack {
                Text(SkyStrings.t("social.shownCount", String(shown)))
                    .font(.caption2).foregroundStyle(SkyColor.textTertiary)
                Spacer(minLength: 0)
                sortMenu
            }
            .padding(.horizontal, SkySpacing.screenEdge)
        }
        .padding(.vertical, SkySpacing.x2)
    }

    private var sortMenu: some View {
        Menu {
            ForEach(SocialReportSortOrder.allCases) { order in
                Button {
                    sortOrder = order
                } label: {
                    if sortOrder == order {
                        Label(SkyStrings.t(order.labelKey), systemImage: "checkmark")
                    } else {
                        Text(SkyStrings.t(order.labelKey))
                    }
                }
            }
        } label: {
            Label(SkyStrings.t(sortOrder.labelKey), systemImage: "arrow.up.arrow.down")
                .font(.caption.weight(.semibold))
        }
        .accessibilityIdentifier("social.sortMenu")
    }

    /// A horizontally paged stack — swipe left/right between reports. Each
    /// page is a full card so VoiceOver reads one report at a time; the OS
    /// already announces "page N of M" for `.page` style, so the visual
    /// counter below is hidden from VoiceOver to avoid a duplicate.
    private func cardStack(_ items: [SocialReportCandidate]) -> some View {
        VStack(spacing: SkySpacing.x1) {
            TabView(selection: $selection) {
                ForEach(items) { candidate in
                    ScrollView {
                        SocialReportCard(candidate: candidate, onOpenLink: { linkToOpen = IdentifiedURL(url: $0) })
                            .padding(SkySpacing.screenEdge)
                    }
                    .refreshable { await load() }
                    .tag(candidate.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            positionIndicator(items)
        }
    }

    private func positionIndicator(_ items: [SocialReportCandidate]) -> some View {
        let index = items.firstIndex(where: { $0.id == selection }) ?? 0
        return Text(SkyStrings.t("social.position", String(index + 1), String(items.count)))
            .font(.caption.monospacedDigit()).foregroundStyle(SkyColor.textTertiary)
            .padding(.bottom, SkySpacing.x2)
            .accessibilityHidden(true)
    }
}

private enum SocialReportSortOrder: String, CaseIterable, Identifiable {
    case caseOrder, newestFirst, oldestFirst
    var id: String { rawValue }
    var labelKey: String { "social.sort.\(rawValue)" }
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
            .accessibilityHint(SkyStrings.t("action.openDetail"))
            if let url = candidate.source.url {
                HStack(spacing: SkySpacing.x2) {
                    Button {
                        onOpenLink(url)
                    } label: {
                        Label(SkyStrings.t("social.viewOriginalPost"), systemImage: "arrow.up.right.square")
                            .font(SkyTypography.supporting.weight(.semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SkyColor.accentPrimary)
                    .accessibilityIdentifier("social.viewOriginal.\(candidate.id)")

                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)
                    .tint(SkyColor.accentPrimary)
                    .accessibilityLabel(SkyStrings.t("action.share"))
                }
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
