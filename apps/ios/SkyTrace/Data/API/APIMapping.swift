import Foundation

/// Maps `docs/openapi/skytrace-v1.yaml` DTOs onto the app's `Domain/Models`
/// types. This is the one seam allowed to know both shapes — everything else
/// in the app (views, view models, the other repositories) only ever sees
/// `Domain/Models` types, whether they came from fixtures or the network.
enum APIMapping {

    static func caseStatus(_ raw: String) -> CaseStatus {
        CaseStatus(rawValue: raw) ?? .insufficientData
    }

    static func locationPrecision(_ raw: String) -> LocationPrecision {
        LocationPrecision(rawValue: raw) ?? .withheld
    }

    static func sourceType(_ raw: String) -> SourceType {
        SourceType(rawValue: raw) ?? .press
    }

    static func evidenceRole(_ raw: String) -> EvidenceRole {
        EvidenceRole(rawValue: raw) ?? .contextualizes
    }

    static func mediaKind(_ raw: String) -> MediaKind {
        MediaKind(rawValue: raw) ?? .image
    }

    static func aiDisclosure(_ raw: String) -> AIDisclosure {
        AIDisclosure(rawValue: raw) ?? .editorReviewed
    }

    static func source(_ dto: APISource) -> SourceReference {
        SourceReference(
            id: dto.id, outletName: dto.outletName, sourceType: sourceType(dto.sourceType),
            title: dto.title, publishedAt: dto.publishedAt, retrievedAt: dto.retrievedAt,
            role: evidenceRole(dto.role), url: dto.url, allowedExcerpt: nil, independenceGroupID: nil
        )
    }

    /// `rights` is chosen from the server's already-computed `displayPermission`
    /// — never re-derived from `rightsState` alone — so the client's rendering
    /// gate (`MediaAsset.canDisplayInline`) can only ever be as permissive as
    /// the server's rights gate, never more (directive §11).
    ///
    /// `sourceID` is always empty: `APIMediaAsset`/`MediaAssetOut` has no field
    /// linking a media item back to a specific `SourceReference` (the v1
    /// contract only nests media under its own source inside
    /// `/v1/social/reports`, which builds that association server-side). Do
    /// not add client-side logic that filters an API-mapped `UAPCase.media`
    /// by `sourceID` — it will silently match nothing. Fixture data (built
    /// directly with real `sourceID`s in `DemoCases.swift`) is unaffected.
    static func media(_ dto: APIMediaAsset) -> MediaAsset {
        let rights: MediaRights = dto.displayPermission == "allowed" ? .licensed : .rightsUnknown
        return MediaAsset(
            id: dto.id, kind: mediaKind(dto.kind), rights: rights, sourceID: "", attribution: dto.attributionText,
            sourceURL: dto.sourcePageURL, mediaURL: rights.allowsInlineDisplay ? dto.mediaURL : nil,
            thumbnailURL: dto.thumbnailURL, caption: nil, licenseNote: dto.licenseNote
        )
    }

    /// Fields not yet in the v1 contract (scores, agreements/contradictions,
    /// explanations, timeline, evidence gaps) default to empty/placeholder —
    /// they arrive with the clustering/scoring/synthesis pipeline in Phase 3/4
    /// (SKYTRACE_NEWS_FIRST_PRODUCTION_DIRECTIVE §15). A production case is
    /// therefore News-First-complete today (title/media/sources/premium-summary
    /// inputs) but its collapsed AI/assessment disclosures stay empty until then.
    static func uapCase(_ dto: APICase) -> UAPCase {
        UAPCase(
            id: dto.id, slug: dto.slug, title: dto.title, summary: dto.summary,
            occurredAtStart: dto.occurredAtStart, occurredAtEnd: nil,
            publishedAt: dto.publishedAt, lastVerifiedAt: dto.lastVerifiedAt, updatedAt: dto.updatedAt,
            latitude: dto.latitude, longitude: dto.longitude, locationPrecision: locationPrecision(dto.locationPrecision),
            countryCode: dto.countryCode, regionName: dto.regionName, localityName: dto.localityName,
            timeZoneIdentifier: "UTC",
            status: caseStatus(dto.status), scores: .placeholder,
            sourceCount: dto.sourceCount, independentReportCount: dto.independentReportCount,
            agreements: [], contradictions: [], explanationCandidates: [],
            missingInformation: [], neededEvidence: [], timeline: [],
            sources: dto.sources.map(source), media: dto.media.map(media),
            currentAssessment: "", shapeTags: [], isDemo: dto.isDemo
        )
    }

    static func briefing(_ dto: APIBriefing) -> DailyBriefing {
        DailyBriefing(
            id: dto.id, date: dto.date, headline: dto.headline, summary: dto.summary,
            tableOfContents: [], blocks: [], referencedCaseIDs: [],
            sourceCount: dto.sourceCount, usedCaseCount: dto.usedCaseCount, readingMinutes: dto.readingMinutes,
            generatedAt: dto.generatedAt, disclosure: aiDisclosure(dto.disclosure), tomorrowWatch: []
        )
    }

    /// No score/likelihood field exists on either side of this mapping —
    /// see `SocialReportCandidate`'s doc comment.
    static func socialReport(_ dto: APISocialReport) -> SocialReportCandidate {
        SocialReportCandidate(
            id: dto.id, caseID: dto.caseId, caseTitle: dto.caseTitle, caseStatus: caseStatus(dto.caseStatus),
            source: source(dto.source), media: dto.media.map(media),
            caseShapeTags: dto.caseShapeTags, isDemo: dto.isDemo
        )
    }

    /// `/v1/feed/today` and `/v1/briefings/today` are separate endpoints in
    /// the v1 contract, so the repository fetches both and passes the mapped
    /// briefing in here rather than this mapper making a second network call.
    static func todayFeed(_ dto: APITodayFeed, briefing: DailyBriefing) -> TodayFeed {
        TodayFeed(
            date: dto.date, lastUpdatedAt: dto.lastUpdatedAt,
            summary: GlobalSummary(
                newReportCount: dto.newReportCount, mergedCaseCount: dto.mergedCaseCount,
                likelyExplainedCount: 0, insufficientDataCount: 0, notableUnresolvedCount: 0
            ),
            briefing: briefing,
            topCases: dto.topCases.map(uapCase), recentUpdates: [],
            editorialNote: "", isPartial: false
        )
    }
}
