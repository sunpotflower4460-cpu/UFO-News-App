import XCTest
@testable import SkyTrace

/// Scans the source-of-truth string catalog for banned sensational/verdict
/// language (SKYTRACE_NEWS_FIRST_PRODUCTION_DIRECTIVE §17 "コピーLint候補").
/// Reads `Resources/Localizable.xcstrings` directly from the checkout via
/// `#filePath` rather than as a bundle resource, since Xcode compiles the
/// String Catalog into per-locale `.strings`/`.stringsdict` at build time and
/// the raw `.xcstrings` JSON is not itself bundled with the app.
final class CopyLintTests: XCTestCase {

    /// Terms that must never appear as a user-facing Japanese string UNLESS the
    /// same string explicitly denies/negates it (e.g. "信ぴょう性スコアは使い
    /// ません", "地球外起源を断定しない") — SkyTrace's own policy copy names
    /// these ideas only to reject them, which is the intended usage
    /// (CLAUDE.md §2/§6, directive §17). A bare, non-negated appearance would
    /// mean the copy is asserting the very verdict SkyTrace must not assert.
    private static let bannedTerms = [
        "信ぴょう性", "真相", "UFO確率", "AIが判定", "結論として", "間違いなく", "地球外",
    ]

    /// Japanese negative-predicate endings. A banned term sharing a sentence
    /// with one of these reads as a denial, not a claim.
    private static let negationMarkers = ["ない", "ません"]

    private func loadCatalog() throws -> [String: Any] {
        let testFileURL = URL(fileURLWithPath: #filePath)
        let catalogURL = testFileURL
            .deletingLastPathComponent() // SkyTraceTests
            .deletingLastPathComponent() // apps/ios
            .appendingPathComponent("SkyTrace/Resources/Localizable.xcstrings")
        let data = try Data(contentsOf: catalogURL)
        let json = try JSONSerialization.jsonObject(with: data)
        return try XCTUnwrap(json as? [String: Any])
    }

    private func allJapaneseValues() throws -> [(key: String, value: String)] {
        let catalog = try loadCatalog()
        let strings = try XCTUnwrap(catalog["strings"] as? [String: Any])
        var out: [(String, String)] = []
        for (key, raw) in strings {
            guard let entry = raw as? [String: Any],
                  let localizations = entry["localizations"] as? [String: Any],
                  let ja = localizations["ja"] as? [String: Any],
                  let unit = ja["stringUnit"] as? [String: Any],
                  let value = unit["value"] as? String else { continue }
            out.append((key, value))
        }
        return out
    }

    func testNoBannedVerdictLanguageInJapaneseCopy() throws {
        let entries = try allJapaneseValues()
        XCTAssertFalse(entries.isEmpty, "Sanity check: the catalog must have parsed at least one ja value")
        var offenders: [String] = []
        for (key, value) in entries {
            for term in Self.bannedTerms where value.contains(term) {
                let isDenial = Self.negationMarkers.contains { value.contains($0) }
                if !isDenial { offenders.append("\(key): contains \"\(term)\" as a bare claim in \"\(value)\"") }
            }
        }
        XCTAssertTrue(offenders.isEmpty, "Banned verdict language found:\n" + offenders.joined(separator: "\n"))
    }

    func testAIReferenceCopyDoesNotClaimAVerdict() throws {
        let entries = Dictionary(uniqueKeysWithValues: try allJapaneseValues())
        let title = try XCTUnwrap(entries["ai.referenceTitle"])
        let subtitle = try XCTUnwrap(entries["ai.referenceSubtitle"])
        XCTAssertEqual(title, "AIの補足を見る")
        for term in ["判定", "真実", "結論"] {
            XCTAssertFalse(title.contains(term), "\(title) must not contain \(term)")
            XCTAssertFalse(subtitle.contains(term), "\(subtitle) must not contain \(term)")
        }
    }
}
