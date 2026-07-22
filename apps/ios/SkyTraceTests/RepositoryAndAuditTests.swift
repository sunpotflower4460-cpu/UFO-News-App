import XCTest
@testable import SkyTrace

final class RepositoryAndAuditTests: XCTestCase {

    func testFeedLoads() async throws {
        let feed = try await FixtureFeedRepository(artificialDelay: .zero).todayFeed()
        XCTAssertFalse(feed.topCases.isEmpty)
        XCTAssertGreaterThan(feed.summary.mergedCaseCount, 0)
    }

    func testCaseDetailNotFoundThrows() async {
        let repo = FixtureCaseRepository(artificialDelay: .zero)
        do {
            _ = try await repo.caseDetail(id: "nope")
            XCTFail("Expected notFound")
        } catch let e as RepositoryError {
            XCTAssertEqual(e, .notFound)
        } catch { XCTFail("Wrong error") }
    }

    func testForcedErrorPropagates() async {
        let repo = FixtureFeedRepository(artificialDelay: .zero, forcedError: .offline)
        do { _ = try await repo.todayFeed(); XCTFail() }
        catch let e as RepositoryError { XCTAssertEqual(e, .offline) }
        catch { XCTFail() }
    }

    func testFixtureRepositoryPropagatesCancellation() async {
        let repo = FixtureFeedRepository(artificialDelay: .seconds(2))
        let task = Task { try await repo.todayFeed() }
        await Task.yield()
        task.cancel()
        do {
            _ = try await task.value
            XCTFail("A cancelled repository call must not continue to publish stale fixture data")
        } catch is CancellationError {
            // Expected.
        } catch {
            XCTFail("Expected CancellationError, got \(error)")
        }
    }

    func testBookmarkToggle() async {
        let store = LibraryStore(suiteName: "test.\(UUID().uuidString)")
        let id = DemoCases.starlink.id
        var isMarked = await store.isBookmarked(id)
        XCTAssertFalse(isMarked)
        await store.toggleBookmark(id)
        isMarked = await store.isBookmarked(id)
        XCTAssertTrue(isMarked)
        await store.toggleBookmark(id)
        isMarked = await store.isBookmarked(id)
        XCTAssertFalse(isMarked)
    }

    func testRecentlyViewedIsCappedAndOrdered() async {
        let store = LibraryStore(suiteName: "test.\(UUID().uuidString)")
        for c in DemoCases.all { await store.markViewed(c.id) }
        let recent = await store.recentlyViewedIDs()
        XCTAssertLessThanOrEqual(recent.count, 12)
        XCTAssertEqual(recent.first, DemoCases.all.last?.id, "Most recent should be first")
    }

    func testReleaseLinkAuditPassesForProductionHosts() {
        let problems = ReleaseLinkAudit.audit()
        XCTAssertTrue(problems.isEmpty,
                      "Legal/support URLs must be valid HTTPS with no placeholder host before submission; got \(problems)")
    }

    func testReleaseLinkAuditFlagsPlaceholderHost() {
        let bad = ReleaseLinkAudit.problems(page: "probe", url: URL(string: "https://skytrace.example.com/x"))
        XCTAssertTrue(bad.contains { $0.reason == "placeholder host" },
                      "A placeholder host must still be flagged")
    }

    func testReleaseLinkAuditFlagsNonHTTPS() {
        let bad = ReleaseLinkAudit.problems(page: "probe", url: URL(string: "http://sunpotflower4460-cpu.github.io/x"))
        XCTAssertTrue(bad.contains { $0.reason == "non-HTTPS scheme" },
                      "A non-HTTPS URL must be flagged")
    }

    func testLoadableKeepsCacheOnFailure() {
        let cached = DemoFeed.feed()
        let state = Loadable<TodayFeed>.failed(.offline, cached: cached)
        XCTAssertNotNil(state.value)
        XCTAssertEqual(state.error, .offline)
    }

    @MainActor
    func testProductionSourceNeverFallsBackToFixtures() async {
        let env = AppEnvironment(
            dataSource: .localAPI,
            subscription: SubscriptionStore(provider: FakeSubscriptionProvider()),
            library: LibraryStore(suiteName: "test.\(UUID().uuidString)")
        )
        do {
            _ = try await env.caseRepository.allCases()
            XCTFail("Production source must fail while the API is unconfigured, not return fixtures")
        } catch let error as RepositoryError {
            guard case .unknown(let reason) = error else {
                return XCTFail("Expected explicit production-not-configured error, got \(error)")
            }
            XCTAssertEqual(reason, "production_data_source_not_configured")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    @MainActor
    func testCaseDetailSurvivesOptionalArticleFailure() async {
        let store = LibraryStore(suiteName: "test.\(UUID().uuidString)")
        let model = CaseDetailViewModel(caseID: DemoCases.starlink.id,
                                        caseRepo: DetailOnlyRepository(),
                                        library: store)

        await model.load()

        XCTAssertEqual(model.state.value?.id, DemoCases.starlink.id)
        XCTAssertNil(model.article)
        XCTAssertNil(model.state.error,
                     "Optional synthesis failure must not replace factual detail with an error")
    }

    func testReleaseDefaultsHideUnimplementedNotifications() {
        XCTAssertFalse(FeatureFlags.releaseDefaults.notificationsEnabled)
    }

    func testEmptyAdverseAssessmentDimensionsAreNotStrongOrRed() {
        if let noContradictions = DemoCases.all.first(where: { $0.contradictions.isEmpty }),
           let dimension = noContradictions.assessmentDimensions.first(where: { $0.kind == .unresolvedContradictions }) {
            XCTAssertEqual(dimension.level, .insufficient)
            XCTAssertEqual(dimension.signal, .green)
        } else {
            XCTFail("Fixture set should include a case without contradictions")
        }

        if let noMissing = DemoCases.all.first(where: { $0.missingInformation.isEmpty }),
           let dimension = noMissing.assessmentDimensions.first(where: { $0.kind == .missingInformation }) {
            XCTAssertEqual(dimension.level, .insufficient)
            XCTAssertEqual(dimension.signal, .green)
        } else {
            XCTFail("Fixture set should include a case without missing information")
        }
    }
}

private struct DetailOnlyRepository: CaseRepository {
    func allCases() async throws -> [UAPCase] { DemoCases.all }

    func caseDetail(id: String) async throws -> UAPCase {
        guard id == DemoCases.starlink.id else { throw RepositoryError.notFound }
        return DemoCases.starlink
    }

    func article(for caseID: String) async throws -> SynthesizedArticle? {
        throw RepositoryError.offline
    }

    func search(query: String, filters: CaseFilter) async throws -> [UAPCase] { [] }
}
