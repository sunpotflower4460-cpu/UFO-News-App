import SwiftUI
import Observation

@MainActor
@Observable
final class TodayViewModel {
    var state: Loadable<TodayFeed> = .idle
    var savedUpdates: [UAPCase] = []

    private let feedRepo: any FeedRepository
    private let caseRepo: any CaseRepository
    private let library: LibraryStore

    init(feedRepo: any FeedRepository, caseRepo: any CaseRepository, library: LibraryStore) {
        self.feedRepo = feedRepo
        self.caseRepo = caseRepo
        self.library = library
    }

    func load(forceState override: PreviewStateOverride = .none) async {
        if applyOverride(override) { return }
        if state.value == nil { state = .loading }
        do {
            let feed = try await feedRepo.todayFeed()
            state = feed.isPartial ? .partial(feed) : .loaded(feed)
            await loadSavedUpdates()
        } catch let error as RepositoryError {
            state = .failed(error, cached: state.value)
        } catch {
            state = .failed(.unknown(error.localizedDescription), cached: state.value)
        }
    }

    func refresh() async {
        await load()
        Haptics.light()
    }

    private func loadSavedUpdates() async {
        let ids = Set(await library.bookmarkedIDs())
        guard !ids.isEmpty else { savedUpdates = []; return }
        let all = (try? await caseRepo.allCases()) ?? []
        savedUpdates = all.filter { ids.contains($0.id) && $0.hasRecentUpdate }
    }

    /// Debug preview-state override support.
    private func applyOverride(_ override: PreviewStateOverride) -> Bool {
        switch override {
        case .none: return false
        case .loading: state = .loading
        case .empty:
            var f = DemoFeed.feed(); f.topCases = []; f.recentUpdates = []
            f.summary = GlobalSummary(newReportCount: 0, mergedCaseCount: 0,
                                      likelyExplainedCount: 0, insufficientDataCount: 0,
                                      notableUnresolvedCount: 0)
            state = .loaded(f)
        case .error: state = .failed(.unknown("forced"), cached: nil)
        case .offline: state = .failed(.offline, cached: DemoFeed.feed())
        case .partial:
            var f = DemoFeed.feed(); f.isPartial = true
            state = .partial(f)
        }
        return true
    }
}
