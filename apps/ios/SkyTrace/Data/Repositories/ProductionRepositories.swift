import Foundation

/// Maps `APIClientError` onto the app-wide `RepositoryError` so Case Detail,
/// Today, and Research never need a third error type to switch on.
private func mapError(_ error: Error) -> RepositoryError {
    if let apiError = error as? APIClientError {
        switch apiError {
        case .offline: return .offline
        case .notFound: return .notFound
        case .decoding: return .decoding
        case .server: return .partial
        case .notConfigured: return .unknown("production_data_source_not_configured")
        }
    }
    return .unknown(error.localizedDescription)
}

/// Live backend implementation of `FeedRepository`, built only when
/// `AppEnvironment` has an explicit `apiBaseURL` — the default `.localAPI`
/// selection with no configured URL keeps using `UnconfiguredFeedRepository`
/// (directive §14: "API未設定なら明示エラー", never a silent fixture swap).
struct ProductionFeedRepository: FeedRepository {
    let client: SkyTraceAPIClient

    func todayFeed() async throws -> TodayFeed {
        do {
            async let feedEnvelope: APIEnvelope<APITodayFeed> = client.get("/v1/feed/today")
            async let briefingEnvelope: APIEnvelope<APIBriefing> = client.get("/v1/briefings/today")
            let (feed, briefing) = try await (feedEnvelope, briefingEnvelope)
            try Task.checkCancellation()
            return APIMapping.todayFeed(feed.data, briefing: APIMapping.briefing(briefing.data))
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw mapError(error)
        }
    }
}

struct ProductionCaseRepository: CaseRepository {
    let client: SkyTraceAPIClient

    func allCases() async throws -> [UAPCase] {
        do {
            let envelope: APIEnvelope<[APICase]> = try await client.get("/v1/cases")
            return envelope.data.map(APIMapping.uapCase)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw mapError(error)
        }
    }

    func caseDetail(id: String) async throws -> UAPCase {
        do {
            let envelope: APIEnvelope<APICase> = try await client.get("/v1/cases/\(id)")
            return APIMapping.uapCase(envelope.data)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw mapError(error)
        }
    }

    /// The v1 contract has no synthesis-article endpoint yet (it arrives with
    /// the AI summary pipeline in Phase 4) — `nil` here means "no article",
    /// the same optional-enrichment path `CaseDetailViewModel` already treats
    /// as a non-fatal absence, never an error state.
    func article(for caseID: String) async throws -> SynthesizedArticle? { nil }

    func search(query: String, filters: CaseFilter) async throws -> [UAPCase] {
        do {
            var components = URLComponents(string: "/v1/search")!
            components.queryItems = [URLQueryItem(name: "q", value: query)]
            let envelope: APIEnvelope<[APICase]> = try await client.get(components.string ?? "/v1/search")
            return envelope.data.map(APIMapping.uapCase)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw mapError(error)
        }
    }
}

struct ProductionSocialReportsRepository: SocialReportsRepository {
    let client: SkyTraceAPIClient

    func socialReports() async throws -> [SocialReportCandidate] {
        do {
            let envelope: APIEnvelope<[APISocialReport]> = try await client.get("/v1/social/reports")
            return envelope.data.map(APIMapping.socialReport)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw mapError(error)
        }
    }
}

struct ProductionBriefingRepository: BriefingRepository {
    let client: SkyTraceAPIClient

    /// The v1 contract only exposes *today's* briefing; a historical `date`
    /// that doesn't match today surfaces as `.notFound` rather than silently
    /// substituting today's briefing for a different day.
    func briefing(for date: Date) async throws -> DailyBriefing {
        do {
            let envelope: APIEnvelope<APIBriefing> = try await client.get("/v1/briefings/today")
            let mapped = APIMapping.briefing(envelope.data)
            guard Calendar.current.isDate(mapped.date, inSameDayAs: date) else { throw RepositoryError.notFound }
            return mapped
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw mapError(error)
        }
    }
}
