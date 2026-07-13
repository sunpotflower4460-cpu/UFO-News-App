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
            state = .loaded(detail)
            article = try await caseRepo.article(for: caseID)
            isBookmarked = await library.isBookmarked(caseID)
            await library.markViewed(caseID)
        } catch let error as RepositoryError {
            state = .failed(error, cached: state.value)
        } catch {
            state = .failed(.unknown(error.localizedDescription), cached: nil)
        }
    }

    func toggleBookmark() async {
        await library.toggleBookmark(caseID)
        isBookmarked = await library.isBookmarked(caseID)
        Haptics.success()
    }
}
