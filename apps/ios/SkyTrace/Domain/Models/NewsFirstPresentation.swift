import Foundation

/// News First / AI Second presentation data, derived from the existing Phase 1
/// `UAPCase` fixtures so the redesigned Case Detail/Today screens gain a lead
/// outlet, primary sources, a primary media asset, and a Premium "3分でわかる
/// まとめ" without a parallel domain model or fixture rewrite. Production data
/// will populate an equivalent shape directly from the backend contract
/// (docs/openapi + `NewsFirstPresentation` DTOs) once Phase 2 sources land.
extension UAPCase {

    /// Distinct outlet names in first-appearance order (stable, not alphabetised)
    /// so the header can name the lead outlet and count "others" without
    /// duplicating a single outlet that filed multiple source documents.
    var reportingOutletNames: [String] {
        var seen = Set<String>()
        var out: [String] = []
        for s in sources where !seen.contains(s.outletName) {
            seen.insert(s.outletName)
            out.append(s.outletName)
        }
        return out
    }

    /// The outlet named first in the News Header's "reported by" line.
    var leadOutletName: String? { reportingOutletNames.first }

    /// How many *other* distinct outlets also reported this, beyond the lead.
    var additionalOutletCount: Int { max(0, reportingOutletNames.count - 1) }

    /// When the event was first reported by any source — distinct from
    /// `publishedAt` (SkyTrace's own publish time) and `occurredAtStart` (when
    /// the event happened). `nil` when no source carries a publish date.
    var firstReportedAt: Date? {
        sources.compactMap(\.publishedAt).min()
    }

    /// Up to three sources chosen for the "元記事を読む" primary CTAs directly
    /// under the media. Official/primary documents lead, then press, then the
    /// remaining evidence-bearing types; social posts (context only) are never
    /// promoted to a primary action. Ties break on most-recently published.
    var primarySources: [SourceReference] {
        let rank: [SourceType: Int] = [
            .official: 0, .press: 1, .scientific: 2, .openData: 3, .database: 4, .social: 5,
        ]
        return sources
            .sorted { a, b in
                let ra = rank[a.sourceType] ?? 9
                let rb = rank[b.sourceType] ?? 9
                if ra != rb { return ra < rb }
                return (a.publishedAt ?? a.retrievedAt) > (b.publishedAt ?? b.retrievedAt)
            }
            .prefix(3)
            .map { $0 }
    }

    /// The lead media asset shown directly under the header (Media First).
    /// Rights-cleared assets are preferred; a rights-unknown asset is still
    /// returned so its link-out card can be shown (never its image), matching
    /// `MediaAssetView`'s existing display gate. `nil` means no media at all —
    /// the caller falls back to the abstract `ObservationGlyph`.
    var primaryMedia: MediaAsset? {
        media.first { $0.canDisplayInline } ?? media.first
    }

    /// Media beyond the lead asset, shown lower on the page rather than
    /// duplicated in the hero position.
    var additionalMedia: [MediaAsset] {
        guard let lead = primaryMedia else { return media }
        return media.filter { $0.id != lead.id }
    }
}

/// The Premium "3分でわかるまとめ" (three-minute summary): what was reported,
/// what multiple sources let us confirm, and what remains unknown — facts and
/// inference kept in separate groups, never blended into one verdict.
struct PremiumSummaryContent: Codable, Sendable, Hashable {
    var whatWasReported: [String]
    var whatCanBeConfirmed: [String]
    var stillUnknown: [String]
    var hasFollowUp: Bool
    /// A short, non-alarming caution for readers, e.g. an open contradiction.
    var cautionNote: String?
}

extension UAPCase {
    /// Derives the Premium summary from existing agreement/contradiction/gap
    /// data. Reported vs. confirmed vs. unknown stay in separate buckets on
    /// purpose (CLAUDE.md §6: "inference is labeled", "unknown stays unknown").
    var premiumSummary: PremiumSummaryContent {
        let confirmed = agreements.map(\.text)
        let unknown = missingInformation.map(\.text) + contradictions.map(\.text)
        let hasFollowUp = timeline.contains { $0.date > publishedAt.addingTimeInterval(60) }
        return PremiumSummaryContent(
            whatWasReported: [summary],
            whatCanBeConfirmed: confirmed,
            stillUnknown: unknown,
            hasFollowUp: hasFollowUp,
            cautionNote: contradictions.first?.text
        )
    }
}

extension SourceType {
    /// Localization key (a `%@` format string taking the outlet name) for the
    /// primary-source CTA verb — varies by source type so the button reads
    /// like a real editorial action ("Reutersの記事を読む") rather than a
    /// generic "詳しく見る".
    var newsActionLabelKey: String {
        switch self {
        case .official: "news.source.action.official"
        case .press: "news.source.action.press"
        case .scientific: "news.source.action.scientific"
        case .database, .openData: "news.source.action.data"
        case .social: "news.source.action.social"
        }
    }
}
