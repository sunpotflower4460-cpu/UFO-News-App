import XCTest

/// Captures real Simulator screenshots of the shipping V2 tabs. Run on the
/// macOS CI runner via the `screenshots.yml` workflow, which exports the
/// attachments and commits the PNGs. Launches with `-uitest-skip-welcome` so
/// the app starts on the tab shell; the app defaults to the dark appearance.
@MainActor
final class ScreenshotUITests: XCTestCase {

    override func setUp() { continueAfterFailure = true }

    func testCaptureV2Screens() {
        let app = XCUIApplication()
        app.launchArguments += ["-uitest-skip-welcome"]
        app.launch()

        // Let the Today fixture feed settle.
        Thread.sleep(forTimeInterval: 2.0)
        snapshot(name: "01-today-v2")

        let tabs = app.tabBars.buttons
        if tabs.count >= 2 {
            tabs.element(boundBy: 1).tap(); Thread.sleep(forTimeInterval: 2.0)
            snapshot(name: "02-map-v2")
        }
        if tabs.count >= 3 {
            tabs.element(boundBy: 2).tap(); Thread.sleep(forTimeInterval: 1.5)
            snapshot(name: "03-search-v2")
        }
        if tabs.count >= 4 {
            tabs.element(boundBy: 3).tap(); Thread.sleep(forTimeInterval: 1.0)
            snapshot(name: "04-settings")
        }

        // Case Detail V2 via the first case card on Today.
        if tabs.count >= 1 {
            tabs.element(boundBy: 0).tap(); Thread.sleep(forTimeInterval: 1.0)
            let firstLink = app.scrollViews.buttons.firstMatch
            if firstLink.waitForExistence(timeout: 5) {
                firstLink.tap(); Thread.sleep(forTimeInterval: 1.5)
                snapshot(name: "05-case-detail-v2")
            }
        }
    }

    private func snapshot(name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
