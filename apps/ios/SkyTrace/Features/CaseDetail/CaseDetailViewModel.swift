import SwiftUI
import Observation

@MainActor
@Observable
final class CaseDetailViewModel {
    var state: Loadable<UAPCase> = .idle
    var article: SynthesizedArticle?
    var isBookmarked = false

    private let caseID: String
    private let caseRepo: any CaseRepository
    private let library: LibraryStore

    init(caseID: String, caseRepo: any CaseRepository, library: LibraryStore) {
        self.caseID = caseID
        self.caseRepo = caseRepo
        self.library = library
    }

    func load() async {
        if state.value == nil { state = .loading }
        do {
            let detail = try await caseRepo.caseDetail(id: caseID)
            try Task.checkCancellation()
            state = .loaded(detail)

            // The synthesis article is optional enrichment. A transient failure
            // must not replace an already-loaded factual case with a full-screen
            // error or discard a previously cached article.
            do {
                let loadedArticle = try await caseRepo.article(for: caseID)
                try Task.checkCancellation()
                article = loadedArticle
            } catch is CancellationError {
                return
            } catch {
                // Preserve the detail and any previous article.
            }

            isBookmarked = await library.isBookmarked(caseID)
            guard !Task.isCancelled else { return }
            await library.markViewed(caseID)
        } catch is CancellationError {
            return
        } catch let error as RepositoryError {
            state = .failed(error, cached: state.value)
        } catch {
            state = .failed(.unknown(error.localizedDescription), cached: state.value)
        }
    }

    func toggleBookmark() async {
        await library.toggleBookmark(caseID)
        guard !Task.isCancelled else { return }
        isBookmarked = await library.isBookmarked(caseID)
        Haptics.success()
    }
}
