import XCTest
@testable import SkyTrace

/// Verifies the News First derived model (Domain/Models/NewsFirstPresentation.swift):
/// primary source ranking, lead outlet naming, primary media selection, and the
/// Premium summary's fact/confirmation/unknown separation.
final class NewsFirstPresentationTests: XCTestCase {

    func testPrimarySourcesRankOfficialAheadOfPressAheadOfSocial() {
        let c = DemoCases.queenslandFireball
        let ranked = c.primarySources
        XCTAssertEqual(ranked.map(\.sourceType), [.official, .press, .social],
                       "Official sources must lead, social (context-only) must never rank first")
    }

    func testPrimarySourcesCappedAtThree() {
        // Even a case with many sources should only ever surface up to three
        // primary CTAs — the rest stay in the full source list below.
        let manySources = (1...6).map { i in
            SourceReference(id: "extra_\(i)", outletName: "Outlet \(i)", sourceType: .press,
                            title: "t\(i)", publishedAt: nil, retrievedAt: .now,
                            role: .supports, url: nil, allowedExcerpt: nil, independenceGroupID: nil)
        }
        var c = DemoCases.starlink
        c.sources = manySources
        XCTAssertLessThanOrEqual(c.primarySources.count, 3)
    }

    func testLeadOutletNameIsFirstDistinctOutletInSourceOrder() {
        let c = DemoCases.northSeaNotable
        XCTAssertEqual(c.leadOutletName, c.sources.first?.outletName)
    }

    func testAdditionalOutletCountExcludesTheLeadOutlet() {
        let c = DemoCases.northSeaNotable
        XCTAssertEqual(c.additionalOutletCount, c.reportingOutletNames.count - 1)
        XCTAssertGreaterThanOrEqual(c.additionalOutletCount, 0)
    }

    func testPrimaryMediaPrefersRightsClearedOverUnknown() throws {
        let c = DemoCases.northSeaNotable
        let primary = try XCTUnwrap(c.primaryMedia)
        XCTAssertTrue(primary.canDisplayInline,
                      "The lead media asset must be rights-cleared — a rights-unknown asset must never be promoted ahead of a cleared one")
        XCTAssertFalse(c.additionalMedia.contains { $0.id == primary.id },
                       "The lead asset must not also appear in additionalMedia (no duplicate rendering)")
    }

    func testPrimaryMediaIsNilWhenCaseHasNoMedia() {
        let c = DemoCases.starlink
        XCTAssertTrue(c.media.isEmpty, "Fixture assumption changed — pick a case with no media for this test")
        XCTAssertNil(c.primaryMedia)
    }

    func testFirstReportedAtIsEarliestSourcePublishDate() throws {
        let c = DemoCases.queenslandFireball
        let expected = try XCTUnwrap(c.sources.compactMap(\.publishedAt).min())
        XCTAssertEqual(c.firstReportedAt, expected)
    }

    func testPremiumSummarySeparatesReportedConfirmedAndUnknown() {
        let c = DemoCases.northSeaNotable
        let summary = c.premiumSummary
        XCTAssertEqual(summary.whatWasReported, [c.summary])
        XCTAssertEqual(summary.whatCanBeConfirmed, c.agreements.map(\.text))
        XCTAssertEqual(Set(summary.stillUnknown),
                       Set(c.missingInformation.map(\.text) + c.contradictions.map(\.text)))
    }

    func testPremiumSummaryHasFollowUpMatchesWhatChanged() {
        for c in DemoCases.all {
            XCTAssertEqual(c.premiumSummary.hasFollowUp, !c.whatChanged.isEmpty, "case \(c.id)")
        }
    }

    func testSourceActionLabelKeysAreDistinctPerSourceType() {
        let keys = Set([SourceType.official, .press, .scientific, .database, .openData, .social]
            .map(\.newsActionLabelKey))
        // database and openData intentionally share a key ("...のデータを見る");
        // every other type must have its own distinct action verb.
        XCTAssertEqual(keys.count, 5)
    }
}
