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
        let store = LibraryStore(defaults: UserDefaults(suiteName: "test.\(UUID().uuidString)")!)
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
        let store = LibraryStore(defaults: UserDefaults(suiteName: "test.\(UUID().uuidString)")!)
        for c in DemoCases.all { await store.markViewed(c.id) }
        let recent = await store.recentlyViewedIDs()
        XCTAssertLessThanOrEqual(recent.count, 12)
        XCTAssertEqual(recent.first, DemoCases.all.last?.id, "Most recent should be first")
    }

    func testReleaseLinkAuditFlagsPlaceholderHost() {
        let problems = ReleaseLinkAudit.audit()
        XCTAssertTrue(problems.contains { $0.reason == "placeholder host" },
                      "Placeholder legal URLs must be flagged before submission")
    }

    func testLoadableKeepsCacheOnFailure() {
        let cached = DemoFeed.feed()
        let state = Loadable<TodayFeed>.failed(.offline, cached: cached)
        XCTAssertNotNil(state.value)
        XCTAssertEqual(state.error, .offline)
    }
}
