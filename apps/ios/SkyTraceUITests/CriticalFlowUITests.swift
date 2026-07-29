import XCTest

/// Critical-flow UI tests. These launch with deterministic fixture data, the
/// Welcome flow skipped, and continuous animations off. Japanese covers content
/// assertions; English and Arabic smoke tests cover localization and RTL shells.
@MainActor
final class CriticalFlowUITests: XCTestCase {

    private func launch(language: String = "ja", locale: String = "ja_JP") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += [
            "-uitest-skip-welcome",
            "-uitest-no-animations",
            "-AppleLanguages", "(\(language))",
            "-AppleLocale", locale,
        ]
        app.launch()
        return app
    }

    override func setUp() { continueAfterFailure = false }

    /// iPhone exposes tabs as tab-bar buttons; iPad can expose its top tab bar
    /// using a different type and duplicate parent/child accessibility nodes.
    /// Select the first concrete match without assuming the UIKit element class.
    private func tab(_ app: XCUIApplication, identifier: String, label: String) -> XCUIElement {
        let identified = app.descendants(matching: .any).matching(identifier: identifier).firstMatch
        if identified.waitForExistence(timeout: 5) { return identified }
        return app.descendants(matching: .any).matching(identifier: label).firstMatch
    }

    func testTabBarHasFourReachableTabs() {
        let app = launch()
        XCTAssertTrue(tab(app, identifier: "tab.today", label: "今日").waitForExistence(timeout: 5))
        XCTAssertTrue(tab(app, identifier: "tab.map", label: "地図").waitForExistence(timeout: 5))
        XCTAssertTrue(tab(app, identifier: "tab.research", label: "探す").waitForExistence(timeout: 5))
        XCTAssertTrue(tab(app, identifier: "tab.settings", label: "設定").waitForExistence(timeout: 5))
    }

    func testTodayPriorityCaseOpensDetail() {
        let app = launch()
        let priority = app.buttons["today.priorityCase"]
        XCTAssertTrue(priority.waitForExistence(timeout: 10))
        priority.tap()

        // A detail push must produce a navigation back button; this verifies an
        // actual destination rather than merely asserting that some text exists.
        XCTAssertTrue(app.navigationBars.buttons.firstMatch.waitForExistence(timeout: 5))
    }

    /// News First completion condition (directive §15 Phase 1): the AI's
    /// reference notes must start closed and only reveal AI-framed content
    /// (here, the Trust Center entry that lives inside the same disclosure)
    /// once the reader deliberately opens it.
    func testAIReferenceDisclosureStartsCollapsedAndExpandsOnTap() {
        let app = launch()
        let priority = app.buttons["today.priorityCase"]
        XCTAssertTrue(priority.waitForExistence(timeout: 10))
        priority.tap()

        let disclosure = app.descendants(matching: .any)
            .matching(identifier: "caseDetail.aiReference.disclosure").firstMatch
        XCTAssertTrue(disclosure.waitForExistence(timeout: 10))

        let trustEntry = app.staticTexts["信頼のしくみ"]
        XCTAssertFalse(trustEntry.exists, "AI reference content must start collapsed, not visible on first load")

        disclosure.tap()
        XCTAssertTrue(trustEntry.waitForExistence(timeout: 5), "AI reference content must open once tapped")
    }

    /// A reader must be able to reach a named, one-tap primary-source action
    /// ("Reutersの記事を読む"-style) directly from Case Detail, above the fold
    /// and without opening any disclosure (directive §4.3).
    func testPrimarySourceActionIsReachableFromCaseDetail() {
        let app = launch()
        let priority = app.buttons["today.priorityCase"]
        XCTAssertTrue(priority.waitForExistence(timeout: 10))
        priority.tap()

        let sourceAction = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", "caseDetail.primarySource."))
            .firstMatch
        XCTAssertTrue(sourceAction.waitForExistence(timeout: 10))
    }

    func testMapTabLoadsMapExperience() {
        let app = launch()
        let mapTab = tab(app, identifier: "tab.map", label: "地図")
        XCTAssertTrue(mapTab.waitForExistence(timeout: 5))
        mapTab.tap()

        // MapKit's raw accessibility element type differs across OS/Xcode
        // versions. Assert the app-owned screen identifier instead.
        let mapScreen = app.descendants(matching: .any)["screen.map"]
        XCTAssertTrue(mapScreen.waitForExistence(timeout: 10))
    }

    func testResearchSearchReturnsTokyoCase() {
        let app = launch()
        let researchTab = tab(app, identifier: "tab.research", label: "探す")
        XCTAssertTrue(researchTab.waitForExistence(timeout: 5))
        researchTab.tap()

        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("東京")

        XCTAssertTrue(app.staticTexts["東京湾上空で停止して見えた3つの灯火"]
            .waitForExistence(timeout: 10))
    }

    func testSettingsShowsRestoreButNotUnimplementedNotifications() {
        let app = launch()
        let settingsTab = tab(app, identifier: "tab.settings", label: "設定")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        XCTAssertTrue(app.buttons["購入を復元"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["通知を有効にする"].exists,
                       "Notification controls must remain hidden until delivery is implemented")
    }

    func testEnglishShellExposesAllTopLevelDestinations() {
        let app = launch(language: "en", locale: "en_US")
        XCTAssertTrue(tab(app, identifier: "tab.today", label: "Today").waitForExistence(timeout: 5))
        XCTAssertTrue(tab(app, identifier: "tab.map", label: "Map").waitForExistence(timeout: 5))
        XCTAssertTrue(tab(app, identifier: "tab.research", label: "Explore").waitForExistence(timeout: 5))
        XCTAssertTrue(tab(app, identifier: "tab.settings", label: "Settings").waitForExistence(timeout: 5))
    }

    func testArabicRTLShellKeepsSearchAndSettingsReachable() {
        let app = launch(language: "ar", locale: "ar_SA")
        let searchTab = tab(app, identifier: "tab.research", label: "استكشاف")
        XCTAssertTrue(searchTab.waitForExistence(timeout: 5))
        searchTab.tap()
        XCTAssertTrue(app.searchFields.firstMatch.waitForExistence(timeout: 5))

        let settingsTab = tab(app, identifier: "tab.settings", label: "الإعدادات")
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()
        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 5))
    }
}
