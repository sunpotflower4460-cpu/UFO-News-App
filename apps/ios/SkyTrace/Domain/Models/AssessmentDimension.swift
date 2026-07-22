import Foundation

/// A single assessment dimension (docs/uiux 01 §6 P3 / 03 §7.4). SkyTrace never
/// shows one truth/confidence score — it shows separate dimensions, each with a
/// qualitative level and the basis for it.
struct AssessmentDimension: Codable, Sendable, Hashable, Identifiable {
    enum Kind: String, Codable, Sendable, CaseIterable {
        case sourceIndependence
        case timeConsistency
        case locationPrecision
        case mediaProvenance
        case officialCorroboration
        case knownPhenomenonFit
        case unresolvedContradictions
        case missingInformation

        var labelKey: String { "assess.\(rawValue)" }

        /// These dimensions measure the amount of a problem, unlike the other
        /// dimensions where a stronger level is favourable.
        var isAdverse: Bool {
            self == .unresolvedContradictions || self == .missingInformation
        }
    }

    /// Qualitative level. Deliberately coarse; not a numeric score.
    enum Level: String, Codable, Sendable, CaseIterable {
        case strong, moderate, limited, insufficient
        var labelKey: String { "assess.level.\(rawValue)" }
        /// 0…1 for a compact bar (never shown as a percentage number).
        var fraction: Double {
            switch self { case .strong: 0.9; case .moderate: 0.62; case .limited: 0.34; case .insufficient: 0.14 }
        }
        var signal: SignalRole {
            switch self { case .strong: .green; case .moderate: .cyan; case .limited: .amber; case .insufficient: .neutral }
        }
    }

    let id: String
    var kind: Kind
    var level: Level
    /// Short basis, e.g. "3件中2件は相互の接触を確認できません".
    var basis: String

    /// Risk dimensions invert the colour meaning: more unresolved contradiction
    /// or missing information must become warmer/redder, never greener.
    var signal: SignalRole {
        guard kind.isAdverse else { return level.signal }
        switch level {
        case .strong: return .red
        case .moderate: return .red
        case .limited: return .amber
        case .insufficient: return .green
        }
    }
}

/// A "What Changed" delta shown first for returning users (03 §7.2).
struct CaseChangeEntry: Codable, Sendable, Hashable, Identifiable {
    enum Kind: String, Codable, Sendable {
        case newEvidence, assessmentChanged, correction, locationRefined, officialUpdate, contradiction
        var labelKey: String { "change.\(rawValue)" }
        var systemImage: String {
            switch self {
            case .newEvidence: "doc.badge.plus"
            case .assessmentChanged: "arrow.triangle.swap"
            case .correction: "pencil.and.outline"
            case .locationRefined: "scope"
            case .officialUpdate: "building.columns"
            case .contradiction: "exclamationmark.triangle"
            }
        }
    }
    let id: String
    var kind: Kind
    /// Human summary, e.g. "位置精度：約20km → 約3km".
    var summary: String
    /// Optional timeline entry id this change links to.
    var timelineEntryID: String?
    var changedAt: Date
}

/// A short, source-linked confirmed fact (03 §7.5).
struct ConfirmedFact: Codable, Sendable, Hashable, Identifiable {
    let id: String
    var text: String
    var sourceIDs: [String]
}

/// A related case with an explicit relation reason (03 §7.12).
struct RelatedCaseRef: Codable, Sendable, Hashable, Identifiable {
    enum Relation: String, Codable, Sendable {
        case sameTimeRegion, similarAppearance, sameExplanation, sharedSource, historical
        var labelKey: String { "related.\(rawValue)" }
    }
    let id: String          // referenced case id
    var relation: Relation
}
