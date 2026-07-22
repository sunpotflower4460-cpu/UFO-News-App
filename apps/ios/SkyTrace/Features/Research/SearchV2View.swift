import SwiftUI

/// V2 Search (docs/uiux 03 §5): discovery sections before input, type-grouped
/// suggestions, a results list with a match reason, filter chips, and a zero-
/// results recovery path. Case-centric results. Reachable from the debug Design
/// Gallery during bring-up; existing Explore tab untouched.
struct SearchV2View: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(DataRefreshController.self) private var refresh
    @State private var model: ResearchViewModel?
    @State private var showFilters = false

    var body: some View {
        Group {
            if let model {
                if model.loadFailed {
                    ErrorStateView { Task { await model.load() } }
                } else if !model.didLoad {
                    discoverSkeleton
                } else if model.isSearching {
                    results(model)
                } else {
                    discover(model)
                }
            } else {
                discoverSkeleton
            }
        }
        .background(SkyColor.canvas)
        .navigationTitle(SkyStrings.t("research.title"))
        .searchable(text: searchBinding,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: SkyStrings.t("research.searchPrompt"))
        .onSubmit(of: .search) { Task { await model?.submitSearch() } }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showFilters = true } label: {
                    Image(systemName: model?.filter.isActive == true
                          ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                }
            }
        }
        .refreshable { await model?.load() }
        .task(id: refresh.generation) {
            if model == nil { model = ResearchViewModel(caseRepo: env.caseRepository, library: env.library) }
            await model?.load()
        }
        .sheet(isPresented: $showFilters) { if let model { FiltersSheet(model: model) } }
    }

    private var searchBinding: Binding<String> {
        Binding(get: { model?.query ?? "" }, set: { model?.query = $0; model?.onQueryChange() })
    }

    private var discoverSkeleton: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SkySpacing.x6) {
                ForEach(0..<3, id: \.self) { _ in SkeletonCard() }
            }
            .padding(.horizontal, SkySpacing.screenEdge).padding(.vertical, SkySpacing.x4)
        }
        .accessibilityLabel(SkyStrings.t("state.loading"))
    }

    // MARK: Discovery root

    private func discover(_ model: ResearchViewModel) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: SkySpacing.x8) {
                recentSearches(model)
                facetBar(model)
                if !model.recentlyViewed.isEmpty {
                    section(SkyStrings.t("research.recent"), "clock.arrow.circlepath", model.recentlyViewed)
                }
                if !model.updatedThisWeek.isEmpty {
                    section(SkyStrings.t("research.updatedThisWeek"), "arrow.triangle.2.circlepath", model.updatedThisWeek)
                }
                phenomena(model)
                savedSection(model)
            }
            .padding(.horizontal, SkySpacing.screenEdge).padding(.vertical, SkySpacing.x4)
        }
    }

    private func section(_ title: String, _ image: String, _ items: [UAPCase]) -> some View {
        EditorialSection(title: title, systemImage: image) {
            VStack(alignment: .leading, spacing: SkySpacing.x3) {
                ForEach(items) { row($0) }
            }
        }
    }

    // Recent committed searches — tap to re-run, or clear the list.
    @ViewBuilder private func recentSearches(_ model: ResearchViewModel) -> some View {
        if !model.recentSearches.isEmpty {
            EditorialSection(title: SkyStrings.t("research.recentSearches"), systemImage: "clock") {
                VStack(alignment: .leading, spacing: SkySpacing.x2) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: SkySpacing.x2)], alignment: .leading,
                              spacing: SkySpacing.x2) {
                        ForEach(model.recentSearches, id: \.self) { term in
                            Button { model.selectTag(term) } label: {
                                SkyChip(text: term, systemImage: "magnifyingglass")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Button(SkyStrings.t("research.clearRecent")) { model.clearRecentSearches() }
                        .font(.caption).foregroundStyle(SkyColor.accentPrimary)
                }
            }
        }
    }

    // Status facet chips (V2 vocabulary) with per-status result counts. Shared
    // by discovery and results so the filter vocabulary is one system across
    // Search and Map. Tapping a chip narrows to that status.
    @ViewBuilder private func facetBar(_ model: ResearchViewModel) -> some View {
        let facets = model.statusFacets
        if facets.count > 1 {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SkySpacing.x2) {
                    ForEach(facets, id: \.status) { facet in
                        Button { model.toggleStatusFacet(facet.status) } label: {
                            HStack(spacing: 4) {
                                CaseStatusGlyph(status: facet.status, size: 13)
                                Text(SkyStrings.t(facet.status.labelKey)).font(SkyTypography.metadata)
                                    .foregroundStyle(SkyColor.textPrimary)
                                Text("\(facet.count)").font(SkyTypography.metadata.monospacedDigit())
                                    .foregroundStyle(SkyColor.textTertiary)
                            }
                            .padding(.horizontal, SkySpacing.x3).padding(.vertical, SkySpacing.x2)
                            .background(model.isStatusSelected(facet.status)
                                        ? facet.status.color.opacity(0.22) : SkyColor.surfaceInteractive,
                                        in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(SkyStrings.t(facet.status.labelKey))、\(facet.count)")
                        .accessibilityAddTraits(model.isStatusSelected(facet.status)
                                                ? [.isButton, .isSelected] : .isButton)
                    }
                }
            }
        }
    }

    // Phenomena/theme chips built from loaded data facets (not a fixture).
    @ViewBuilder private func phenomena(_ model: ResearchViewModel) -> some View {
        if !model.phenomenaTags.isEmpty {
            EditorialSection(title: SkyStrings.t("research.collections"), systemImage: "tag") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: SkySpacing.x2)], alignment: .leading,
                          spacing: SkySpacing.x2) {
                    ForEach(model.phenomenaTags, id: \.self) { tag in
                        Button { model.selectTag(tag) } label: { SkyChip(text: tag, systemImage: "number") }
                            .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    @ViewBuilder private func savedSection(_ model: ResearchViewModel) -> some View {
        EditorialSection(title: SkyStrings.t("research.saved"), systemImage: "bookmark") {
            if model.saved.isEmpty {
                EmptyStateView(messageKey: "empty.saved", systemImage: "bookmark")
            } else {
                VStack(alignment: .leading, spacing: SkySpacing.x3) { ForEach(model.saved) { row($0) } }
            }
        }
    }

    // MARK: Results

    private func results(_ model: ResearchViewModel) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: SkySpacing.x3) {
                HStack {
                    Text(SkyStrings.t("research.resultCount", model.results.count))
                        .font(SkyTypography.metadata).foregroundStyle(SkyColor.textSecondary)
                    if model.isRunning { ProgressView().controlSize(.mini) }
                    Spacer()
                    if model.filter.isActive {
                        Button(SkyStrings.t("research.clearFilters")) { model.clearFilters() }
                            .font(.caption).foregroundStyle(SkyColor.accentPrimary)
                    }
                }
                facetBar(model)
                if model.results.isEmpty {
                    VStack(alignment: .leading, spacing: SkySpacing.x3) {
                        EmptyStateView(messageKey: "empty.search", systemImage: "magnifyingglass")
                        Button(SkyStrings.t("research.clearFilters")) {
                            model.query = ""; model.clearFilters()
                        }
                        .buttonStyle(.bordered).tint(SkyColor.accentPrimary)
                        .frame(maxWidth: .infinity)
                    }
                } else {
                    ForEach(model.results) { c in row(c, reason: model.matchReason(for: c)) }
                }
            }
            .padding(.horizontal, SkySpacing.screenEdge).padding(.vertical, SkySpacing.x4)
        }
    }

    // MARK: Result row (status geometry + reason)

    private func row(_ c: UAPCase, reason: String? = nil) -> some View {
        NavigationLink { CaseDetailV2View(caseID: c.id) } label: {
            HStack(alignment: .top, spacing: SkySpacing.x3) {
                CaseStatusGlyph(status: c.v2Status, size: 22, showsUpdateIndicator: c.hasRecentUpdate)
                    .padding(.top, 2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(c.title).font(SkyTypography.supporting.weight(.semibold))
                        .foregroundStyle(SkyColor.textPrimary).lineLimit(2)
                    HStack(spacing: SkySpacing.x2) {
                        Text(c.localityName ?? c.regionName)
                        if let occurred = c.occurredAtStart { Text(SkyFormat.dateOnly(occurred)) }
                    }
                    .font(SkyTypography.metadata).foregroundStyle(SkyColor.textTertiary)
                    if let reason {
                        Label(reason, systemImage: "text.magnifyingglass")
                            .font(SkyTypography.metadata).foregroundStyle(SkyColor.signalWarm).lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview("Search V2") {
    NavigationStack { SearchV2View() }
        .environment(AppEnvironment.preview()).environment(AppSettings())
        .environment(DataRefreshController())
}
