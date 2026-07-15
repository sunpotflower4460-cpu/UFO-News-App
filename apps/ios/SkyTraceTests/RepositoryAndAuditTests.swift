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
        // Legal/support URLs now resolve to the GitHub Pages site (docs/site),
        // so the audit must be clean — a prerequisite for a Release build.
        let problems = ReleaseLinkAudit.audit()
        XCTAssertTrue(problems.isEmpty,
                      "Legal/support URLs must be valid HTTPS with no placeholder host before submission; got \(problems)")
    }

    func testReleaseLinkAuditFlagsPlaceholderHost() {
        // The audit still catches a regression back to a placeholder host.
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
}
