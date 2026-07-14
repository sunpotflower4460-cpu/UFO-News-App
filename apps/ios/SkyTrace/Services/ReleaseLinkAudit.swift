import Foundation

/// Guards App Store readiness: every legal/support page must resolve to a valid
/// HTTPS URL before a Release build ships (CLAUDE_CODE_PHASES 7.4). Wired into a
/// unit test now; a Release build-phase check can call `assertValidForRelease()`.
enum ReleaseLinkAudit {
    struct Problem: Equatable { let page: String; let reason: String }

    static func audit(_ pages: [LegalPage] = LegalPage.allCases) -> [Problem] {
        var problems: [Problem] = []
        for page in pages {
            guard let url = page.externalURL else {
                problems.append(.init(page: page.rawValue, reason: "missing URL")); continue
            }
            if url.scheme?.lowercased() != "https" {
                problems.append(.init(page: page.rawValue, reason: "non-HTTPS scheme"))
            }
            if url.host?.contains("example.com") == true {
                // Placeholder host — must be replaced before submission.
                problems.append(.init(page: page.rawValue, reason: "placeholder host"))
            }
        }
        return problems
    }

    /// In DEBUG this only logs; a Release pipeline should treat problems as fatal.
    static func assertValidForRelease() {
        let problems = audit()
        #if DEBUG
        if !problems.isEmpty { print("[ReleaseLinkAudit] pending: \(problems)") }
        #else
        precondition(problems.isEmpty, "Invalid legal/support URLs for Release: \(problems)")
        #endif
    }
}
