import Foundation

/// A citation to an external document. SkyTrace stores metadata + an allowed
/// excerpt only — never full third-party article bodies.
struct SourceReference: Codable, Sendable, Hashable, Identifiable {
    let id: String
    var outletName: String
    var sourceType: SourceType
    var title: String
    var publishedAt: Date?
    var retrievedAt: Date
    var role: EvidenceRole
    var url: URL?
    /// Short, rights-cleared excerpt. May be empty when no excerpt is licensed.
    var allowedExcerpt: String?
    /// Whether this source counts toward independent corroboration.
    var independenceGroupID: String?
}

/// A point of agreement across independent reports.
struct AgreementPoint: Codable, Sendable, Hashable, Identifiable {
    let id: String
    var text: String
    var supportingSourceIDs: [String]
}

/// A point where sources contradict each other.
struct ContradictionPoint: Codable, Sendable, Hashable, Identifiable {
    let id: String
    var text: String
    var conflictingSourceIDs: [String]
}

/// A candidate mundane explanation and how well it fits.
struct ExplanationCandidate: Codable, Sendable, Hashable, Identifiable {
    let id: String
    var category: ExplanationCategory
    var label: String
    /// 0–100 match strength. "0" means "no match found in available data",
    /// which is NOT the same as "ruled out".
    var matchScore: Int
    var matchingConditions: [String]
    var nonMatchingConditions: [String]
    /// Description of the data range / gaps that limit this assessment.
    var dataLimitations: String?
    var assessedAt: Date?
    /// When true, this candidate is considered ruled out (not merely unmatched).
    var isExcluded: Bool
}

/// An entry in a case's update timeline.
struct CaseTimelineEntry: Codable, Sendable, Hashable, Identifiable {
    let id: String
    var date: Date
    var summary: String
    var statusChange: CaseStatus?
    var addedSourceIDs: [String]
    /// Optional score delta note, e.g. "既知現象一致度 40 → 72".
    var scoreChangeNote: String?
}

/// Missing-information / next-evidence items surfaced in Case Detail.
struct EvidenceGap: Codable, Sendable, Hashable, Identifiable {
    let id: String
    var text: String
}
