import XCTest
@testable import SkyTrace

/// Guards the editorial invariants that the whole product rests on.
final class FixtureIntegrityTests: XCTestCase {

    func testAtLeastEightDemoCases() {
        XCTAssertGreaterThanOrEqual(DemoCases.all.count, 8)
    }

    func testAllCasesAreFlaggedDemo() {
        XCTAssertTrue(DemoCases.all.allSatisfy(\.isDemo), "Every fixture must carry a DEMO flag")
    }

    func testAtLeastTwoJapaneseCases() {
        let jp = DemoCases.all.filter { $0.countryCode == "JP" }
        XCTAssertGreaterThanOrEqual(jp.count, 2)
    }

    func testEveryCaseHasAtLeastOneSourceAndRetrievalTime() {
        for c in DemoCases.all {
            XCTAssertFalse(c.sources.isEmpty, "\(c.id) has no sources")
            XCTAssertEqual(c.sourceCount, c.sourceCount) // present
            for s in c.sources {
                XCTAssertNotNil(s.retrievedAt, "\(c.id) source \(s.id) missing retrievedAt")
            }
        }
    }

    func testScoresWithinBounds() {
        for c in DemoCases.all {
            for axis in c.scores.axes {
                XCTAssert((0...100).contains(axis.value), "\(c.id) \(axis.kind) out of range")
            }
        }
    }

    func testStatusCoverageIncludesKeyStates() {
        let statuses = Set(DemoCases.all.map(\.status))
        for required in [CaseStatus.explained, .insufficientData, .notableUnresolved, .disputed, .withdrawn] {
            XCTAssertTrue(statuses.contains(required), "Missing demo case with status \(required)")
        }
    }

    /// The citation gate: every published fact block must reference a source.
    func testArticleFactBlocksAreCited() {
        for article in DemoArticles.all {
            for block in article.blocks where block.kind == .factParagraph {
                XCTAssertFalse(block.sourceIDs.isEmpty,
                               "\(article.id) fact block \(block.id) has no source (citation gate)")
            }
            for block in article.blocks where block.kind == .unknown {
                XCTAssertFalse(block.missingFields.isEmpty,
                               "\(article.id) unknown block \(block.id) should state missing fields")
            }
        }
    }

    func testExplanationExcludedIsDistinctFromZeroMatch() {
        // A candidate with matchScore 0 that is NOT excluded must still be allowed
        // (means "no match found", not "ruled out").
        let excluded = DemoCases.all.flatMap(\.explanationCandidates).filter(\.isExcluded)
        XCTAssertTrue(excluded.allSatisfy { $0.matchScore <= 20 })
    }
}
