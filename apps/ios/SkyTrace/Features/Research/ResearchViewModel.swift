import SwiftUI
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
    /// True while a debounced search is in flight (keeps prior results visible).
    var isRunning = false
    private var allCases: [UAPCase] = []
    private var searchTask: Task<Void, Never>?

    private let caseRepo: any CaseRepository
    private let library: LibraryStore

    init(caseRepo: any CaseRepository, library: LibraryStore) {
        self.caseRepo = caseRepo
        self.library = library
    }

    var isSearching: Bool { !query.trimmingCharacters(in: .whitespaces).isEmpty || filter.isActive }

    /// Phenomena/theme tags derived from the loaded data (not a fixture).
    var phenomenaTags: [String] {
        Array(Set(allCases.flatMap(\.shapeTags))).sorted().prefix(12).map { $0 }
    }

    func load() async {
        allCases = (try? await caseRepo.allCases()) ?? []
        let recentIDs = await library.recentlyViewedIDs()
        recentlyViewed = recentIDs.compactMap { id in allCases.first { $0.id == id } }
        let savedIDs = Set(await library.bookmarkedIDs())
        saved = allCases.filter { savedIDs.contains($0.id) }
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: FixtureClock.today)!
        updatedThisWeek = allCases.filter { $0.hasRecentUpdate && $0.updatedAt >= weekAgo }
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

    /// Immediate search (submit, tag tap, filter change).
    func runSearch() async {
        searchTask?.cancel()
        isRunning = true
        defer { isRunning = false }
        results = (try? await caseRepo.search(query: query, filters: filter)) ?? []
    }

    func selectTag(_ tag: String) {
        query = tag
        Task { await runSearch() }
    }

    func clearFilters() {
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
