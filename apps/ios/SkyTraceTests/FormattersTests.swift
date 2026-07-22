import XCTest
@testable import SkyTrace

final class FormattersTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    func testRelativeFormattingUsesInjectedReferenceDate() throws {
        let event = try XCTUnwrap(calendar.date(from: DateComponents(
            timeZone: TimeZone(secondsFromGMT: 0), year: 2026, month: 1, day: 1, hour: 12)))
        let near = try XCTUnwrap(calendar.date(byAdding: .day, value: 1, to: event))
        let far = try XCTUnwrap(calendar.date(byAdding: .day, value: 9, to: event))

        let nearText = SkyFormat.relative(event, now: near)
        let farText = SkyFormat.relative(event, now: far)

        XCTAssertNotEqual(nearText, farText,
                          "Changing the injected reference time must change the relative phrase")
    }

    func testAdaptiveFormattingSwitchesAtInjectedWindow() throws {
        let event = try XCTUnwrap(calendar.date(from: DateComponents(
            timeZone: TimeZone(secondsFromGMT: 0), year: 2026, month: 1, day: 1, hour: 12)))
        let near = try XCTUnwrap(calendar.date(byAdding: .day, value: 2, to: event))
        let far = try XCTUnwrap(calendar.date(byAdding: .day, value: 30, to: event))

        XCTAssertNotEqual(SkyFormat.adaptive(event, now: near, window: 14),
                          SkyFormat.dateOnly(event))
        XCTAssertEqual(SkyFormat.adaptive(event, now: far, window: 14),
                       SkyFormat.dateOnly(event))
    }

    func testFutureDateFallsBackToAbsoluteInAdaptiveFormatting() throws {
        let now = try XCTUnwrap(calendar.date(from: DateComponents(
            timeZone: TimeZone(secondsFromGMT: 0), year: 2026, month: 1, day: 1, hour: 12)))
        let future = try XCTUnwrap(calendar.date(byAdding: .day, value: 1, to: now))

        XCTAssertEqual(SkyFormat.adaptive(future, now: now), SkyFormat.dateOnly(future))
    }
}
