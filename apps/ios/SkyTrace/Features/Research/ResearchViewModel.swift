import Foundation
import Observation

@MainActor
@Observable
final class ResearchViewModel {
    var query = ""
    var filter = CaseFilter()
    var results: [UAPCase] = []
    var recentlyViewed: [UAPCase] = []
    var saved: [UAPCase] = []
    var updatedThisWeek: [UAPCase] = []
    /// Past committed queries (most-recent first), surfaced in discovery.
    var recentSearches: [String] = []
    /// True while a debounced search is in flight (keeps prior results visible).
    var isRunning = false
    /// Discovery load state for the initial screen (skeleton → ready / failed).
    var didLoad = false
    var loadFailed = false
    private var allCases: [UAPCase] = []
    private var searchTask: Task<Void, Never>?
    /// Monotonic token. Only the newest request may publish results or stop the
    /// activity indicator, even when an older repository ignores cancellation.
    private var searchGeneration = 0

    private let caseRepo: any CaseRepository
    private let library: LibraryStore
    private let now: @Sendable () -> Date

    init(caseRepo: any CaseRepository, library: LibraryStore,
         now: @escaping @Sendable () -> Date = { .now }) {
        self.caseRepo = caseRepo
        self.library = library
        self.now = now
    }

    var isSearching: Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || filter.isActive
    }

    /// Phenomena/theme tags derived from the loaded data (not a fixture).
    var phenomenaTags: [String] {
        Array(Set(allCases.flatMap(\.shapeTags))).sorted().prefix(12).map { $0 }
    }

    /// Status facets (V2 vocabulary) with per-status result counts. Counts are
    /// computed for the current query + non-status filters, so an active status
    /// filter doesn't collapse the other options to zero — the bar always shows
    /// how many cases each status would yield, and tapping narrows to it.
    var statusFacets: [(status: SkyCaseStatus, count: Int)] {
        var base = filter
        base.statuses = []
        let matched = CaseSearch.run(query: query, filters: base, in: allCases,
                                     now: now())
        let grouped = Dictionary(grouping: matched) { SkyCaseStatus($0.status) }
        return SkyCaseStatus.allCases.compactMap { s in
            guard let n = grouped[s]?.count, n > 0 else { return nil }
            return (s, n)
        }
    }

    func isStatusSelected(_ s: SkyCaseStatus) -> Bool {
        CaseStatus.allCases.contains { SkyCaseStatus($0) == s && filter.statuses.contains($0) }
    }

    /// Toggle a V2 status facet by mapping it to the legacy statuses that render
    /// as it (so filtering works against the current fixture model), then search.
    func toggleStatusFacet(_ s: SkyCaseStatus) {
        let legacy = CaseStatus.allCases.filter { SkyCaseStatus($0) == s }
        let anyOn = legacy.contains { filter.statuses.contains($0) }
        for l in legacy {
            if anyOn { filter.statuses.remove(l) } else { filter.statuses.insert(l) }
        }
        cancelDebounce()
        Task { await runSearch() }
    }

    func load() async {
        do {
            let loaded = try await caseRepo.allCases()
            try Task.checkCancellation()
            allCases = loaded
            loadFailed = false
        } catch is CancellationError {
            return
        } catch {
            loadFailed = true
            didLoad = true
            return
        }

        let recentIDs = await library.recentlyViewedIDs()
        guard !Task.isCancelled else { return }
        recentlyViewed = recentIDs.compactMap { id in allCases.first { $0.id == id } }
        let savedIDs = Set(await library.bookmarkedIDs())
        guard !Task.isCancelled else { return }
        saved = allCases.filter { savedIDs.contains($0.id) }
        let current = now()
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: current) ?? current
        updatedThisWeek = allCases.filter { $0.hasRecentUpdate && $0.updatedAt >= weekAgo }
        recentSearches = await library.recentSearches()
        guard !Task.isCancelled else { return }
        didLoad = true
        // Do not run an empty search on load — discovery is shown instead.
    }

    /// Debounced + cancellable. Skips empty queries with no active filter.
    func onQueryChange() {
        cancelDebounce()
        let generation = searchGeneration
        let requestedQuery = query
        let requestedFilter = filter
        let trimmed = requestedQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || requestedFilter.isActive else {
            isRunning = false
            results = []
            return
        }

        isRunning = true
        searchTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }
                await self?.performSearch(query: requestedQuery,
                                          filter: requestedFilter,
                                          generation: generation)
            } catch is CancellationError {
                return
            } catch {
                return
            }
        }
    }

    /// Cancels queued debounce work and immediately invalidates every older
    /// repository call. This closes the gap while submit/tag persistence awaits.
    func cancelDebounce() {
        searchTask?.cancel()
        searchTask = nil
        searchGeneration &+= 1
    }

    /// Immediate search (submit, tag tap, filter change). Captures the current
    /// inputs so mutations during an await cannot relabel an old response.
    func runSearch() async {
        searchGeneration &+= 1
        let generation = searchGeneration
        await performSearch(query: query, filter: filter, generation: generation)
    }

    private func performSearch(query requestedQuery: String,
                               filter requestedFilter: CaseFilter,
                               generation: Int) async {
        isRunning = true
        defer {
            if generation == searchGeneration { isRunning = false }
        }
        do {
            let found = try await caseRepo.search(query: requestedQuery,
                                                  filters: requestedFilter)
            try Task.checkCancellation()
            guard generation == searchGeneration else { return }
            results = found
        } catch is CancellationError {
            return
        } catch {
            guard generation == searchGeneration else { return }
            results = []
        }
    }

    /// Commits the current query (from the search-bar submit): records it in
    /// recent searches, then runs immediately. Empty queries are not recorded.
    func submitSearch() async {
        cancelDebounce()
        await recordSearch(query)
        guard !Task.isCancelled else { return }
        await runSearch()
    }

    func selectTag(_ tag: String) {
        cancelDebounce()
        query = tag
        Task {
            await recordSearch(tag)
            guard !Task.isCancelled else { return }
            await runSearch()
        }
    }

    /// Persists a committed query and refreshes the local list for the UI.
    private func recordSearch(_ q: String) async {
        let trimmed = q.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        await library.addRecentSearch(trimmed)
        guard !Task.isCancelled else { return }
        recentSearches = await library.recentSearches()
    }

    func clearRecentSearches() {
        Task {
            await library.clearRecentSearches()
            guard !Task.isCancelled else { return }
            recentSearches = []
        }
    }

    func clearFilters() {
        cancelDebounce()
        filter = .none
        Task { await runSearch() }
    }

    /// Why this case matched — derived from the actual matched field, not the
    /// unrelated priority reason. Returns nil when only a filter is active.
    func matchReason(for c: UAPCase) -> String? {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return nil }
        if c.title.lowercased().contains(q) { return SkyStrings.t("search.reason.title") }
        if (c.localityName?.lowercased().contains(q) ?? false) || c.regionName.lowercased().contains(q) {
            return SkyStrings.t("search.reason.location")
        }
        if c.shapeTags.contains(where: { $0.lowercased().contains(q) }) {
            return SkyStrings.t("search.reason.shape")
        }
        if c.summary.lowercased().contains(q) { return SkyStrings.t("search.reason.summary") }
        if c.sources.contains(where: { $0.title.lowercased().contains(q) }) {
            return SkyStrings.t("search.reason.source")
        }
        return nil
    }
}
