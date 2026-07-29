import Foundation

/// A social-media-sourced reference, shown in the Premium "SNSでの目撃報告"
/// swipe feed. This is a *reading aid*, not a verdict: SkyTrace never scores
/// or ranks a post by how likely it is to "really be a UFO" (CLAUDE.md §2:
/// "地球外起源を確率表示する"のNG、directive §17banned "UFO確率"/"AIが判定").
/// Every candidate is labelled as an unverified report and links out to the
/// original post — it never rehosts post text or media beyond what the
/// underlying `SourceReference`/`MediaAsset` rights model already allows.
struct SocialReportCandidate: Identifiable, Sendable, Hashable {
    let id: String
    let caseID: String
    let caseTitle: String
    let caseStatus: CaseStatus
    let source: SourceReference
    /// Media tied to this specific source (still subject to the normal rights
    /// gate — a rights-unknown asset renders as a link-out, never an image).
    let media: [MediaAsset]
    let isDemo: Bool
}

extension Array where Element == UAPCase {
    /// All social-media source references across these cases, in stable order
    /// (case order, then source order) — never sorted or filtered by a
    /// computed "UFO likelihood". Production population of this list is
    /// further gated by the backend's Source Registry / Tier D provider
    /// approval (docs/DATA_SOURCE_REGISTRY.md; SKYTRACE_NEWS_FIRST_PRODUCTION_DIRECTIVE
    /// §10) — until a social provider is approved for automated retrieval,
    /// this stays empty outside of Debug fixtures.
    var socialReportCandidates: [SocialReportCandidate] {
        flatMap { c in
            c.sources
                .filter { $0.sourceType == .social }
                .map { source in
                    SocialReportCandidate(
                        id: "\(c.id)_\(source.id)", caseID: c.id, caseTitle: c.title, caseStatus: c.status,
                        source: source, media: c.media.filter { $0.sourceID == source.id }, isDemo: c.isDemo
                    )
                }
        }
    }
}
