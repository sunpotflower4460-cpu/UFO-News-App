import Foundation

/// Deterministic date helpers so fixtures are stable across runs/timezones.
enum FixtureClock {
    /// A fixed "today" anchor for demo data: 2026-07-13 22:40 UTC.
    static let today: Date = {
        var c = DateComponents()
        c.year = 2026; c.month = 7; c.day = 13; c.hour = 22; c.minute = 40
        return Calendar(identifier: .gregorian).date(from: c) ?? Date(timeIntervalSince1970: 1_784_000_000)
    }()

    static func day(_ offset: Int, hour: Int = 21, minute: Int = 0) -> Date {
        let cal = Calendar(identifier: .gregorian)
        let base = cal.date(byAdding: .day, value: offset, to: today) ?? today
        return cal.date(bySettingHour: hour, minute: minute, second: 0, of: base) ?? base
    }
}

/// Small builder helpers to keep the fixture file readable.
enum Fx {
    static func source(_ id: String, _ outlet: String, _ type: SourceType, _ title: String,
                       role: EvidenceRole = .supports, daysAgo: Int = 2,
                       excerpt: String? = nil, group: String? = nil,
                       url: String? = "https://example.org/skytrace-demo") -> SourceReference {
        SourceReference(
            id: id, outletName: outlet, sourceType: type, title: title,
            publishedAt: FixtureClock.day(-daysAgo), retrievedAt: FixtureClock.day(-daysAgo, hour: 23),
            role: role, url: url.flatMap(URL.init(string:)), allowedExcerpt: excerpt,
            independenceGroupID: group
        )
    }

    static func agree(_ id: String, _ text: String, _ src: [String]) -> AgreementPoint {
        AgreementPoint(id: id, text: text, supportingSourceIDs: src)
    }
    static func contra(_ id: String, _ text: String, _ src: [String]) -> ContradictionPoint {
        ContradictionPoint(id: id, text: text, conflictingSourceIDs: src)
    }
    static func gap(_ id: String, _ text: String) -> EvidenceGap { EvidenceGap(id: id, text: text) }

    /// Demo media. `mediaURL` is intentionally nil so no real (rights-uncertain)
    /// binary is fetched — cleared items render the abstract observation
    /// placeholder; the source link is always present.
    static func media(_ id: String, _ kind: MediaKind, _ rights: MediaRights, source: String,
                      attribution: String, caption: String, license: String? = nil,
                      url: String = "https://example.org/skytrace-demo-source") -> MediaAsset {
        MediaAsset(
            id: id, kind: kind, rights: rights, sourceID: source, attribution: attribution,
            sourceURL: URL(string: url)!, mediaURL: nil, thumbnailURL: nil,
            caption: caption, licenseNote: license)
    }

    static func candidate(_ id: String, _ cat: ExplanationCategory, _ label: String, _ score: Int,
                          match: [String], nonMatch: [String] = [], limits: String? = nil,
                          excluded: Bool = false, daysAgo: Int = 1) -> ExplanationCandidate {
        ExplanationCandidate(
            id: id, category: cat, label: label, matchScore: score,
            matchingConditions: match, nonMatchingConditions: nonMatch,
            dataLimitations: limits, assessedAt: FixtureClock.day(-daysAgo), isExcluded: excluded
        )
    }

    static func timeline(_ id: String, _ daysAgo: Int, _ summary: String,
                         status: CaseStatus? = nil, sources: [String] = [],
                         scoreNote: String? = nil) -> CaseTimelineEntry {
        CaseTimelineEntry(id: id, date: FixtureClock.day(-daysAgo), summary: summary,
                          statusChange: status, addedSourceIDs: sources, scoreChangeNote: scoreNote)
    }

    static func fact(_ id: String, _ text: String, claims: [String] = [], sources: [String] = [],
                     gated: Bool = false) -> ArticleBlock {
        ArticleBlock(id: id, kind: .factParagraph, text: text, claimIDs: claims,
                     sourceIDs: sources, confidence: nil, missingFields: [], isPremiumGated: gated)
    }
    static func heading(_ id: String, _ text: String, gated: Bool = false) -> ArticleBlock {
        ArticleBlock(id: id, kind: .heading, text: text, claimIDs: [], sourceIDs: [],
                     confidence: nil, missingFields: [], isPremiumGated: gated)
    }
    static func inference(_ id: String, _ text: String, confidence: Double,
                          claims: [String] = [], gated: Bool = true) -> ArticleBlock {
        ArticleBlock(id: id, kind: .inference, text: text, claimIDs: claims, sourceIDs: [],
                     confidence: confidence, missingFields: [], isPremiumGated: gated)
    }
    static func unknown(_ id: String, _ text: String, missing: [String], gated: Bool = false) -> ArticleBlock {
        ArticleBlock(id: id, kind: .unknown, text: text, claimIDs: [], sourceIDs: [],
                     confidence: nil, missingFields: missing, isPremiumGated: gated)
    }
}
