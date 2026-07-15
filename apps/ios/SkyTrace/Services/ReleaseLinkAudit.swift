import Foundation

/// Guards App Store readiness: every legal/support page must resolve to a valid
/// HTTPS URL before a Release build ships (CLAUDE_CODE_PHASES 7.4). Wired into a
/// unit test now; a Release build-phase check can call `assertValidForRelease()`.
enum ReleaseLinkAudit {
    struct Problem: Equatable { let page: String; let reason: String }

    static func audit(_ pages: [LegalPage] = LegalPage.allCases) -> [Problem] {
        pages.flatMap { problems(page: $0.rawValue, url: $0.externalURL) }
    }

    /// Validates a single legal/support URL. Exposed so tests can probe both a
    /// production URL (must be clean) and a placeholder (must be flagged).
    static func problems(page: String, url: URL?) -> [Problem] {
        guard let url else { return [.init(page: page, reason: "missing URL")] }
        var problems: [Problem] = []
        if url.scheme?.lowercased() != "https" {
            problems.append(.init(page: page, reason: "non-HTTPS scheme"))
        }
        if url.host?.contains("example.com") == true || url.host?.contains("example.org") == true {
            // Placeholder host — must be replaced before submission.
            problems.append(.init(page: page, reason: "placeholder host"))
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
