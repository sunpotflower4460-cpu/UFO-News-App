import XCTest
@testable import SkyTrace

/// The Premium "SNSでの目撃報告" feed must only ever be a plain, unranked list
/// of `.social` sources — never a probability/likelihood judgment (CLAUDE.md
/// §2, directive §17 "UFO確率"/"AIが判定"禁止). These tests lock down the
/// derivation so a future change can't quietly reintroduce a score/sort by
/// "likelihood".
final class SocialReportCandidateTests: XCTestCase {

    func testOnlySocialSourceTypeSourcesBecomeCandidates() {
        let candidates = DemoCases.all.socialReportCandidates
        XCTAssertFalse(candidates.isEmpty, "Fixture set should include at least one .social source")
        for candidate in candidates {
            XCTAssertEqual(candidate.source.sourceType, .social)
        }
    }

    func testCandidatesPreserveCaseAndSourceOrderWithNoSorting() {
        let cases = DemoCases.all
        let candidates = cases.socialReportCandidates
        // Rebuild the expected order the dumb way (case order, then source
        // order) and assert it matches exactly — proves there is no sort by
        // any computed score.
        var expectedIDs: [String] = []
        for c in cases {
            for s in c.sources where s.sourceType == .social {
                expectedIDs.append("\(c.id)_\(s.id)")
            }
        }
        XCTAssertEqual(candidates.map(\.id), expectedIDs)
    }

    func testCandidateCarriesOnlyMediaBelongingToItsOwnSource() {
        guard let candidate = DemoCases.all.socialReportCandidates.first(where: { !$0.media.isEmpty }) else {
            XCTFail("Fixture set should include a .social source with attached media")
            return
        }
        XCTAssertTrue(candidate.media.allSatisfy { $0.sourceID == candidate.source.id })
    }

    func testNoLikelihoodOrScoreFieldExistsOnTheCandidateType() {
        // A structural guard: SocialReportCandidate has exactly these stored
        // properties. Widening this to add a score/likelihood field must be a
        // deliberate, reviewed decision, not an accidental one — this test
        // documents the current, intentional shape.
        let mirror = Mirror(reflecting: DemoCases.all.socialReportCandidates.first!)
        let fieldNames = Set(mirror.children.compactMap(\.label))
        XCTAssertEqual(fieldNames, ["id", "caseID", "caseTitle", "caseStatus", "source", "media", "caseShapeTags", "isDemo"])
    }
}
