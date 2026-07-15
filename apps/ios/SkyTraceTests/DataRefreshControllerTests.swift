import XCTest
@testable import SkyTrace

@MainActor
final class DataRefreshControllerTests: XCTestCase {

    func testStartsAtGenerationZeroWithNoTimestamp() {
        let c = DataRefreshController()
        XCTAssertEqual(c.generation, 0)
        XCTAssertNil(c.lastRefreshed)
    }

    func testRequestRefreshBumpsGenerationAndStampsTime() {
        let fixed = Date(timeIntervalSince1970: 1_800_000_000)
        let c = DataRefreshController(now: { fixed })
        c.requestRefresh()
        XCTAssertEqual(c.generation, 1)
        XCTAssertEqual(c.lastRefreshed, fixed)
        c.requestRefresh()
        XCTAssertEqual(c.generation, 2)
    }

    func testManualRefreshWorksEvenWhenAutoRefreshDisabled() {
        // A manual/pull refresh must always fire, independent of the auto-refresh
        // setting (which only governs the background poll cadence).
        let c = DataRefreshController(isEnabled: { false })
        c.requestRefresh()
        c.requestRefresh()
        XCTAssertEqual(c.generation, 2)
        XCTAssertNotNil(c.lastRefreshed)
    }

    func testStopPollingIsSafeWhenNotStarted() {
        // Idempotent stop — must not crash when no poll task is running.
        let c = DataRefreshController()
        c.stopPolling()
        XCTAssertEqual(c.generation, 0)
    }
}
