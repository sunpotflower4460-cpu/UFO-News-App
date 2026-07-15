import XCTest

/// Captures real Simulator screenshots of the shipping V2/V3 screens. Run on the
/// macOS CI runner via `screenshots.yml`, which exports the attachments and
/// commits the PNGs.
///
/// Each screen is captured in its own test with a **fresh app launch** — a long
/// single-session tour accumulates state and can terminate the app mid-run, so
/// per-screen launches keep capture reliable. All launches disable continuous
/// animations so XCUITest can reach quiescence.
@MainActor
final class ScreenshotUITests: XCTestCase {

    override func setUp() { continueAfterFailure = true }

    private func launchApp(showWelcome: Bool = false, language: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [showWelcome ? "-uitest-show-welcome" : "-uitest-skip-welcome",
                                "-uitest-no-animations"]
        if let language {
            // Force the app UI language (and matching locale for RTL/formatting).
            app.launchArguments += ["-AppleLanguages", "(\(language))", "-AppleLocale", language]
        }
        app.launch()
        return app
    }

    // MARK: - Screens (one fresh launch each)

    func testCaptureWelcome() {
        let app = launchApp(showWelcome: true)
        Thread.sleep(forTimeInterval: 2.4)
        snapshot(name: "00-welcome-aether")

        let start = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] %@", "始")).firstMatch
        let cta = start.exists ? start : app.buttons.element(boundBy: 0)
        if cta.waitForExistence(timeout: 6) {
            cta.tap()
            Thread.sleep(forTimeInterval: 1.6)
            snapshot(name: "00b-welcome-policy")
        }
    }

    func testCaptureToday() {
        let app = launchApp()
        waitUntilLoaded(app)
        snapshot(name: "01-today-v2")
    }

    /// Arabic launch — verifies translated core vocabulary + right-to-left
    /// layout mirroring (body strings fall back to readable English for now).
    func testCaptureTodayArabic() {
        let app = launchApp(language: "ar")
        waitUntilLoaded(app)
        snapshot(name: "01-today-ar-rtl")
    }

    /// Spanish launch — verifies a Latin-script target language renders.
    func testCaptureTodaySpanish() {
        let app = launchApp(language: "es")
        waitUntilLoaded(app)
        snapshot(name: "01-today-es")
    }

    func testCaptureMap() {
        let app = launchApp()
        let tabs = app.tabBars.buttons
        guard tabs.count >= 2 else { return }
        tabs.element(boundBy: 1).tap()
        waitUntilLoaded(app)
        // Map tiles don't load offline in CI; raise the list sheet (map/list
        // parity) so real content is visible instead of a blank map.
        expandSheet(app)
        snapshot(name: "02-map-v2")
    }

    func testCaptureSearch() {
        let app = launchApp()
        let tabs = app.tabBars.buttons
        guard tabs.count >= 3 else { return }
        tabs.element(boundBy: 2).tap()
        waitUntilLoaded(app)
        snapshot(name: "03-search-v2")
    }

    func testCaptureSettings() {
        let app = launchApp()
        let tabs = app.tabBars.buttons
        guard tabs.count >= 4 else { return }
        tabs.element(boundBy: 3).tap()
        Thread.sleep(forTimeInterval: 1.4)
        snapshot(name: "04-settings")
    }

    func testCaptureCaseDetail() {
        let app = launchApp()
        waitUntilLoaded(app)
        let caseCard = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "北海")).firstMatch
        guard caseCard.waitForExistence(timeout: 8) else { return }
        caseCard.tap()
        waitUntilLoaded(app)
        Thread.sleep(forTimeInterval: 1.0)
        snapshot(name: "05-case-detail-v2")
    }

    // MARK: - Helpers

    private func expandSheet(_ app: XCUIApplication) {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.92))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.16))
        start.press(forDuration: 0.15, thenDragTo: end)
        Thread.sleep(forTimeInterval: 1.0)
    }

    /// Settle, then wait until no loading spinner remains (or timeout).
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
