import Foundation

/// The Today feed payload: a world snapshot plus curated case groupings.
struct TodayFeed: Codable, Sendable, Hashable {
    var date: Date
    var lastUpdatedAt: Date
    var summary: GlobalSummary
    var briefing: DailyBriefing
    var topCases: [UAPCase]
    var recentUpdates: [UAPCase]
    var editorialNote: String
    /// True when the feed was assembled from cache / partial sources.
    var isPartial: Bool
}

/// The "today in the world's skies" statistics block.
struct GlobalSummary: Codable, Sendable, Hashable {
    var newReportCount: Int
    var mergedCaseCount: Int
    var likelyExplainedCount: Int
    var insufficientDataCount: Int
    var notableUnresolvedCount: Int
    /// Coverage disclaimer key — the feed only reflects sources we could reach.
    var coverageNoteKey: String = "summary.coverage.disclaimer"
}

/// A daily world briefing. Free users see the lead + table of contents; Plus
/// users read the full body.
struct DailyBriefing: Codable, Sendable, Hashable, Identifiable {
    let id: String
    var date: Date
    var headline: String
    /// ~200 character summary shown to everyone.
    var summary: String
    var tableOfContents: [String]
    var blocks: [ArticleBlock]
    var referencedCaseIDs: [String]
    var sourceCount: Int
    var usedCaseCount: Int
    var readingMinutes: Int
    var generatedAt: Date
    var disclosure: AIDisclosure
    var tomorrowWatch: [String]
}
