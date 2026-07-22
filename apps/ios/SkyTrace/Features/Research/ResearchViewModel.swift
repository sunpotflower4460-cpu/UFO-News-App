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

    private let caseRepo: any CaseRepository
    private let library: LibraryStore
    private let now: @Sendable () -> Date

    init(caseRepo: any CaseRepository, library: LibraryStore,
         now: @escaping @Sendable () -> Date = { .now }) {
        self.caseRepo = caseRepo
        self.library = library
        self.now = now
    }

    var isSearching: Bool { !query.trimmingCharacters(in: .whitespaces).isEmpty || filter.isActive }

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
        for l in legacy { if anyOn { filter.statuses.remove(l) } else { filter.statuses.insert(l) } }
        cancelDebounce()
        Task { await runSearch() }
    }

    func load() async {
        do {
            allCases = try await caseRepo.allCases()
            loadFailed = false
        } catch {
            loadFailed = true
            didLoad = true
            return
        }
        let recentIDs = await library.recentlyViewedIDs()
        recentlyViewed = recentIDs.compactMap { id in allCases.first { $0.id == id } }
        let savedIDs = Set(await library.bookmarkedIDs())
        saved = allCases.filter { savedIDs.contains($0.id) }
        let current = now()
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: current) ?? current
        updatedThisWeek = allCases.filter { $0.hasRecentUpdate && $0.updatedAt >= weekAgo }
        recentSearches = await library.recentSearches()
        didLoad = true
        // Do not run an empty search on load — discovery is shown instead.
    }

    /// Debounced + cancellable. Skips empty queries with no active filter.
    func onQueryChange() {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty || filter.isActive else {
            isRunning = false
            results = []
            return
        }
        isRunning = true
        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            if Task.isCancelled { return }
            await self?.runSearch()
        }
    }

    /// Cancels any pending debounced search. Call before an immediate search so
    /// a queued debounce can't overwrite fresher results.
    func cancelDebounce() { searchTask?.cancel() }

    /// Immediate search (submit, tag tap, filter change). Does NOT cancel
    /// `searchTask` — when called from the debounce it would cancel the very
    /// task running it, which a cancellation-aware repo would turn into an
    /// empty result set.
    func runSearch() async {
        isRunning = true
        defer { isRunning = false }
        results = (try? await caseRepo.search(query: query, filters: filter)) ?? []
    }

    /// Commits the current query (from the search-bar submit): records it in
    /// recent searches, then runs immediately. Empty queries are not recorded.
    func submitSearch() async {
        cancelDebounce()
        await recordSearch(query)
        await runSearch()
    }

    func selectTag(_ tag: String) {
        cancelDebounce()
        query = tag
        Task {
            await recordSearch(tag)
            await runSearch()
        }
    }

    /// Persists a committed query and refreshes the local list for the UI.
    private func recordSearch(_ q: String) async {
        let trimmed = q.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        await library.addRecentSearch(trimmed)
        recentSearches = await library.recentSearches()
    }

    func clearRecentSearches() {
        Task {
            await library.clearRecentSearches()
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
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
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
