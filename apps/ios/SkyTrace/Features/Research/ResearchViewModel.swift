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
    private var allCases: [UAPCase] = []

    private let caseRepo: any CaseRepository
    private let library: LibraryStore

    init(caseRepo: any CaseRepository, library: LibraryStore) {
        self.caseRepo = caseRepo
        self.library = library
    }

    var isSearching: Bool { !query.trimmingCharacters(in: .whitespaces).isEmpty || filter.isActive }

    func load() async {
        allCases = (try? await caseRepo.allCases()) ?? []
        let recentIDs = await library.recentlyViewedIDs()
        recentlyViewed = recentIDs.compactMap { id in allCases.first { $0.id == id } }
        let savedIDs = Set(await library.bookmarkedIDs())
        saved = allCases.filter { savedIDs.contains($0.id) }
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: FixtureClock.today)!
        updatedThisWeek = allCases.filter { $0.hasRecentUpdate && $0.updatedAt >= weekAgo }
        await runSearch()
    }

    func runSearch() async {
        results = (try? await caseRepo.search(query: query, filters: filter)) ?? []
    }

    func clearFilters() {
        filter = .none
        Task { await runSearch() }
    }
}
