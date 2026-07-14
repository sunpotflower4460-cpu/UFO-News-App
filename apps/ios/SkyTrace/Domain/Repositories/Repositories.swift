import Foundation

/// Errors surfaced by repositories. Views translate these into calm state UI.
enum RepositoryError: Error, Sendable, Equatable {
    case offline
    case notFound
    case partial
    case decoding
    case unknown(String)
}

/// Supplies the Today feed.
protocol FeedRepository: Sendable {
    func todayFeed() async throws -> TodayFeed
}

/// Supplies cases for list, map, search, and detail.
protocol CaseRepository: Sendable {
    func allCases() async throws -> [UAPCase]
    func caseDetail(id: String) async throws -> UAPCase
    func article(for caseID: String) async throws -> SynthesizedArticle?
    func search(query: String, filters: CaseFilter) async throws -> [UAPCase]
}

/// Supplies daily briefings.
protocol BriefingRepository: Sendable {
    func briefing(for date: Date) async throws -> DailyBriefing
}

/// Local bookmarks + recently-viewed, persisted on-device.
protocol LibraryRepository: Sendable {
    func bookmarkedIDs() async -> [String]
    func isBookmarked(_ id: String) async -> Bool
    func toggleBookmark(_ id: String) async
    func recentlyViewedIDs() async -> [String]
    func markViewed(_ id: String) async
    func recentlyViewedCount() async -> Int
    func clearRecentlyViewed() async
}

/// Structured search / filter criteria used by the Research hub and Map.
struct CaseFilter: Sendable, Hashable {
    var statuses: Set<CaseStatus> = []
    var minUnresolvedness: Int = 0
    var shapeTags: Set<String> = []
    var withUpdatesOnly: Bool = false
    var dateWindow: DateWindow = .anyTime

    enum DateWindow: String, Sendable, CaseIterable, Identifiable {
        case anyTime, past24h, past7d, past30d, thisYear
        var id: String { rawValue }
        var labelKey: String { "filter.window.\(rawValue)" }
    }

    var isActive: Bool {
        !statuses.isEmpty || minUnresolvedness > 0 || !shapeTags.isEmpty
            || withUpdatesOnly || dateWindow != .anyTime
    }

    static let none = CaseFilter()
}
