import XCTest

/// Captures real Simulator screenshots of the shipping V2 tabs. Run on the
/// macOS CI runner via `screenshots.yml`, which exports the attachments and
/// commits the PNGs. Launches with `-uitest-skip-welcome`; the app defaults to
/// the dark appearance.
@MainActor
final class ScreenshotUITests: XCTestCase {

    override func setUp() { continueAfterFailure = true }

    /// First-run Welcome flow (Aether depth): the dimensional night sky +
    /// AetherOrb. Forces Welcome via `-uitest-show-welcome` so it's captured
    /// regardless of persisted state.
    func testCaptureWelcome() {
        let app = XCUIApplication()
        app.launchArguments += ["-uitest-show-welcome"]
        app.launch()
        // Let the atmosphere + orb settle before capturing.
        Thread.sleep(forTimeInterval: 2.4)
        snapshot(name: "00-welcome-aether")

        // Advance to the editorial policy page (does not complete Welcome).
        let start = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "始"))
            .firstMatch
        let cta = start.exists ? start : app.buttons.element(boundBy: 0)
        if cta.waitForExistence(timeout: 6) {
            cta.tap()
            Thread.sleep(forTimeInterval: 1.6)
            snapshot(name: "00b-welcome-policy")
        }
    }

    func testCaptureV2Screens() {
        let app = XCUIApplication()
        app.launchArguments += ["-uitest-skip-welcome"]
        app.launch()
        let tabs = app.tabBars.buttons

        waitUntilLoaded(app)
        snapshot(name: "01-today-v2")

        if tabs.count >= 2 {
            tabs.element(boundBy: 1).tap()
            waitUntilLoaded(app)
            // Map tiles don't load in the offline CI simulator, so raise the
            // persistent bottom sheet to its large detent to show the list
            // (map/list parity) instead of a blank map.
            expandSheet(app)
            snapshot(name: "02-map-v2")
        }
        if tabs.count >= 3 { tabs.element(boundBy: 2).tap(); waitUntilLoaded(app); snapshot(name: "03-search-v2") }
        if tabs.count >= 4 { tabs.element(boundBy: 3).tap(); Thread.sleep(forTimeInterval: 1.2); snapshot(name: "04-settings") }

        // Case Detail V2: back to Today, tap the priority case (title contains 北海).
        if tabs.count >= 1 {
            tabs.element(boundBy: 0).tap()
            waitUntilLoaded(app)
            let caseCard = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "北海")).firstMatch
            if caseCard.waitForExistence(timeout: 8) {
                caseCard.tap()
                waitUntilLoaded(app)
                Thread.sleep(forTimeInterval: 1.2)
                snapshot(name: "05-case-detail-v2")
            }
        }
    }

    /// Drag the persistent bottom sheet from its small detent up to large,
    /// revealing the case list. Uses a coordinate drag from near-bottom to
    /// near-top of the screen.
    private func expandSheet(_ app: XCUIApplication) {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.92))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.16))
        start.press(forDuration: 0.15, thenDragTo: end)
        Thread.sleep(forTimeInterval: 1.0)
    }

    /// Settle time then wait until no loading spinner remains (or timeout).
    private func waitUntilLoaded(_ app: XCUIApplication, timeout: TimeInterval = 14) {
        Thread.sleep(forTimeInterval: 1.6)
        let deadline = Date().addingTimeInterval(timeout)
        while app.activityIndicators.firstMatch.exists && Date() < deadline {
            Thread.sleep(forTimeInterval: 0.4)
        }
        Thread.sleep(forTimeInterval: 0.8)
    }

    private func snapshot(name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
