import Foundation

/// On-device bookmarks + recently-viewed store. Backed by `UserDefaults` for
/// Phase 1 (a SwiftData migration is planned for Phase 2 caching — see
/// DECISIONS.md). Actor-isolated for safe concurrent access.
actor LibraryStore: LibraryRepository {
    private let defaults: UserDefaults
    private let bookmarkKey = "skytrace.bookmarks"
    private let recentKey = "skytrace.recentlyViewed"
    private let recentSearchKey = "skytrace.recentSearches"
    private let recentLimit = 12
    private let recentSearchLimit = 8

    /// Takes a suite name (Sendable) rather than a `UserDefaults` instance so no
    /// non-Sendable value crosses the actor boundary (Swift 6 concurrency).
    init(suiteName: String? = nil) {
        self.defaults = suiteName.flatMap { UserDefaults(suiteName: $0) } ?? .standard
    }

    func bookmarkedIDs() async -> [String] {
        defaults.stringArray(forKey: bookmarkKey) ?? []
    }

    func isBookmarked(_ id: String) async -> Bool {
        await bookmarkedIDs().contains(id)
    }

    func toggleBookmark(_ id: String) async {
        var ids = await bookmarkedIDs()
        if let idx = ids.firstIndex(of: id) { ids.remove(at: idx) } else { ids.insert(id, at: 0) }
        defaults.set(ids, forKey: bookmarkKey)
    }

    func recentlyViewedIDs() async -> [String] {
        defaults.stringArray(forKey: recentKey) ?? []
    }

    func markViewed(_ id: String) async {
        var ids = await recentlyViewedIDs()
        ids.removeAll { $0 == id }
        ids.insert(id, at: 0)
        if ids.count > recentLimit { ids = Array(ids.prefix(recentLimit)) }
        defaults.set(ids, forKey: recentKey)
    }

    func recentlyViewedCount() async -> Int {
        await recentlyViewedIDs().count
    }

    /// Clears the recently-viewed cache. Bookmarks are kept (a separate action).
    func clearRecentlyViewed() async {
        defaults.removeObject(forKey: recentKey)
    }

    func recentSearches() async -> [String] {
        defaults.stringArray(forKey: recentSearchKey) ?? []
    }

    /// Records a committed query (submit / tag), most-recent first. Trims,
    /// ignores empties, and de-duplicates case-insensitively so re-running a
    /// past search just moves it to the top rather than adding a near-duplicate.
    func addRecentSearch(_ query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var items = await recentSearches()
        items.removeAll { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
        items.insert(trimmed, at: 0)
        if items.count > recentSearchLimit { items = Array(items.prefix(recentSearchLimit)) }
        defaults.set(items, forKey: recentSearchKey)
    }

    func clearRecentSearches() async {
        defaults.removeObject(forKey: recentSearchKey)
    }
}
