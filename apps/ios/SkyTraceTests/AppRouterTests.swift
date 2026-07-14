import XCTest
@testable import SkyTrace

@MainActor
final class AppRouterTests: XCTestCase {

    func testDefaultsToToday() {
        XCTAssertEqual(AppRouter().selectedTab, .today)
    }

    func testOpenMapSwitchesTab() {
        let router = AppRouter()
        router.openMap()
        XCTAssertEqual(router.selectedTab, .map)
        XCTAssertNil(router.mapFocusCaseID)
    }

    func testOpenMapWithFocusRecordsCase() {
        let router = AppRouter()
        router.openMap(focus: "case-123")
        XCTAssertEqual(router.selectedTab, .map)
        XCTAssertEqual(router.mapFocusCaseID, "case-123")
    }
}
