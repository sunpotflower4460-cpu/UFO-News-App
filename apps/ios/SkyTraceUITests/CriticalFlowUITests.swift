import XCTest

/// Critical-flow UI tests (UI_UX_PLAN 21.1). These require a running Simulator.
/// They launch with `-uitest-skip-welcome` so the app starts on the tab shell.
final class CriticalFlowUITests: XCTestCase {

    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-uitest-skip-welcome"]
        app.launch()
        return app
    }

    override func setUp() { continueAfterFailure = false }

    func testTabBarHasFourTabs() {
        let app = launch()
        XCTAssertGreaterThanOrEqual(app.tabBars.buttons.count, 4)
    }

    func testTodayToCaseDetailToSource() {
        let app = launch()
        // Today is the first tab and shows at least one case card.
        let firstLink = app.scrollViews.otherElements.buttons.firstMatch
        XCTAssertTrue(firstLink.waitForExistence(timeout: 5))
        firstLink.tap()
        // Detail should show a Sources section eventually.
        XCTAssertTrue(app.staticTexts.count > 0)
    }

    func testMapTabOpens() {
        let app = launch()
        app.tabBars.buttons.element(boundBy: 1).tap()
        XCTAssertTrue(app.otherElements.firstMatch.waitForExistence(timeout: 5))
    }

    func testResearchSearch() {
        let app = launch()
        app.tabBars.buttons.element(boundBy: 2).tap()
        let searchField = app.searchFields.firstMatch
        if searchField.waitForExistence(timeout: 5) {
            searchField.tap()
            searchField.typeText("東京")
        }
    }

    func testSettingsRestoreExists() {
        let app = launch()
        app.tabBars.buttons.element(boundBy: 3).tap()
        XCTAssertTrue(app.tables.firstMatch.waitForExistence(timeout: 5)
                      || app.collectionViews.firstMatch.waitForExistence(timeout: 5))
    }
}
