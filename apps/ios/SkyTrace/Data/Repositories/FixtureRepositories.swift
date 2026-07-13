import Foundation

/// Fixture-backed repositories. These satisfy the same protocols as the future
/// API-backed implementations, so the app can be built end-to-end with no
/// network. An optional injected latency/failure lets us demo loading/error.
struct FixtureFeedRepository: FeedRepository {
    var artificialDelay: Duration = .milliseconds(350)
    var forcedError: RepositoryError? = nil

    func todayFeed() async throws -> TodayFeed {
        try await simulate(artificialDelay, forcedError)
        return DemoFeed.feed()
    }
}

struct FixtureCaseRepository: CaseRepository {
    var artificialDelay: Duration = .milliseconds(250)
    var forcedError: RepositoryError? = nil

    func allCases() async throws -> [UAPCase] {
        try await simulate(artificialDelay, forcedError)
        return DemoCases.all
    }

    func caseDetail(id: String) async throws -> UAPCase {
        try await simulate(artificialDelay, forcedError)
        guard let match = DemoCases.all.first(where: { $0.id == id }) else {
            throw RepositoryError.notFound
        }
        return match
    }

    func article(for caseID: String) async throws -> SynthesizedArticle? {
        try await simulate(artificialDelay, forcedError)
        return DemoCases.article(for: caseID)
    }

    func search(query: String, filters: CaseFilter) async throws -> [UAPCase] {
        try await simulate(.milliseconds(150), forcedError)
        return CaseSearch.run(query: query, filters: filters, in: DemoCases.all)
    }
}

struct FixtureBriefingRepository: BriefingRepository {
    var forcedError: RepositoryError? = nil
    func briefing(for date: Date) async throws -> DailyBriefing {
        try await simulate(.milliseconds(200), forcedError)
        return DemoFeed.briefing
    }
}

/// Shared search/filter logic so Map, Research and tests agree.
enum CaseSearch {
    static func run(query: String, filters: CaseFilter, in cases: [UAPCase]) -> [UAPCase] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        return cases.filter { c in
            matchesText(c, q) && matchesFilters(c, filters)
        }
    }

    static func matchesText(_ c: UAPCase, _ q: String) -> Bool {
        guard !q.isEmpty else { return true }
        let haystack = [c.title, c.summary, c.regionName, c.localityName ?? "",
                        c.countryCode] + c.shapeTags
        return haystack.joined(separator: " ").lowercased().contains(q)
    }

    static func matchesFilters(_ c: UAPCase, _ f: CaseFilter) -> Bool {
        if !f.statuses.isEmpty && !f.statuses.contains(c.status) { return false }
        if c.scores.unresolvedness < f.minUnresolvedness { return false }
        if !f.shapeTags.isEmpty && f.shapeTags.isDisjoint(with: Set(c.shapeTags)) { return false }
        if f.withUpdatesOnly && !c.hasRecentUpdate { return false }
        if let cutoff = window(f.dateWindow) {
            let ref = c.occurredAtStart ?? c.publishedAt
            if ref < cutoff { return false }
        }
        return true
    }

    private static func window(_ w: CaseFilter.DateWindow) -> Date? {
        let now = FixtureClock.today
        let cal = Calendar(identifier: .gregorian)
        switch w {
        case .anyTime: return nil
        case .past24h: return cal.date(byAdding: .hour, value: -24, to: now)
        case .past7d: return cal.date(byAdding: .day, value: -7, to: now)
        case .past30d: return cal.date(byAdding: .day, value: -30, to: now)
        case .thisYear: return cal.date(from: DateComponents(year: cal.component(.year, from: now)))
        }
    }
}

/// Injects an optional delay and error to exercise UI states.
private func simulate(_ delay: Duration, _ error: RepositoryError?) async throws {
    if delay > .zero { try? await Task.sleep(for: delay) }
    if let error { throw error }
}
