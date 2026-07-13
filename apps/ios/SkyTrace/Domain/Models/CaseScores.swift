import Foundation

/// The four-axis score set for a case.
///
/// SkyTrace deliberately never produces a single "authenticity" number. Each
/// axis measures something different, and `knownPhenomenaMatch` is inverted in
/// meaning: a *high* value means the case is *more* likely explained.
struct CaseScores: Codable, Sendable, Hashable {
    /// 0–100. Quality of the underlying evidence (footage, metadata, duration…).
    var evidenceQuality: Int
    /// 0–100. How independent the corroborating reports are.
    var independence: Int
    /// 0–100. How well a known phenomenon explains the case. Higher = more explained.
    var knownPhenomenaMatch: Int
    /// 0–100. Residual unexplained signal. High value does NOT imply extraterrestrial.
    var unresolvedness: Int

    /// Internal scoring algorithm version, surfaced for provenance.
    var algorithmVersion: String

    static let placeholder = CaseScores(
        evidenceQuality: 0, independence: 0,
        knownPhenomenaMatch: 0, unresolvedness: 0,
        algorithmVersion: "demo-1"
    )

    /// Ordered list for UI iteration. Kept here so views never hardcode axis order.
    var axes: [ScoreAxis] {
        [
            ScoreAxis(kind: .evidenceQuality, value: evidenceQuality),
            ScoreAxis(kind: .independence, value: independence),
            ScoreAxis(kind: .knownPhenomenaMatch, value: knownPhenomenaMatch),
            ScoreAxis(kind: .unresolvedness, value: unresolvedness),
        ]
    }
}

/// A single presentable score axis (kind + value), used by `ScoreQuadrant`.
struct ScoreAxis: Identifiable, Sendable, Hashable {
    enum Kind: String, Sendable, CaseIterable {
        case evidenceQuality
        case independence
        case knownPhenomenaMatch
        case unresolvedness

        var titleKey: String { "score.\(rawValue).title" }
        var explanationKey: String { "score.\(rawValue).explanation" }

        /// Whether a higher value reads as "more explainable" (true) vs
        /// "stronger signal" (false). Drives the caption in `ScoreQuadrant`.
        var higherMeansMoreExplained: Bool { self == .knownPhenomenaMatch }

        var signal: SignalRole {
            switch self {
            case .evidenceQuality: .cyan
            case .independence: .violet
            case .knownPhenomenaMatch: .green
            case .unresolvedness: .amber
            }
        }
    }

    let kind: Kind
    let value: Int
    var id: String { kind.rawValue }
}
