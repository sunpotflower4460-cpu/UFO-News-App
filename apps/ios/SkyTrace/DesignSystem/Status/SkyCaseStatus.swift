import SwiftUI

/// V2 case status vocabulary (Aether Editorial System). Status describes the
/// *state of understanding*, never the nature of the object (docs/uiux
/// 01_MASTER_PLAN §6). Introduced alongside the Phase 1 `CaseStatus` so screens
/// can migrate without breaking the build; `init(_:)` maps the legacy value.
enum SkyCaseStatus: String, Codable, Sendable, CaseIterable, Identifiable {
    case newReport
    case underReview
    case informationInsufficient
    case knownExplanationLikely
    case explained
    case disputed
    case corrected
    case archived

    var id: String { rawValue }

    /// Localization key for the user-facing label (natural Japanese).
    var labelKey: String { "v2.status.\(rawValue)" }

    /// One-line plain-language meaning of the status, used by the Trust Center
    /// (and anywhere the status vocabulary is explained rather than just tagged).
    var meaningKey: String { "v2.status.\(rawValue).meaning" }

    /// Geometry used by `CaseStatusGlyph`. Same geometry everywhere: map, rows,
    /// header, timeline, widgets, VoiceOver description.
    var geometry: StatusGeometry {
        switch self {
        case .newReport: .pointInRing
        case .underReview: .openRingTick
        case .informationInsufficient: .openRingGap
        case .knownExplanationLikely: .halfFilled
        case .explained: .diamond
        case .disputed: .offsetArcs
        case .corrected: .diamondRevision
        case .archived: .squareOutline
        }
    }

    /// Colour token (paired with geometry + label — never the only carrier).
    var color: Color {
        switch self {
        case .newReport: SkyColor.statusNew
        case .underReview: SkyColor.statusReview
        case .informationInsufficient: SkyColor.statusInsufficient
        case .knownExplanationLikely: SkyColor.statusLikelyKnown
        case .explained: SkyColor.statusExplained
        case .disputed: SkyColor.statusDisputed
        case .corrected: SkyColor.statusCorrected
        case .archived: SkyColor.statusArchived
        }
    }

    /// SF Symbol fallback for very small / large-text contexts where the custom
    /// glyph is secondary.
    var systemImageFallback: String {
        switch self {
        case .newReport: "circle.circle"
        case .underReview: "scope"
        case .informationInsufficient: "questionmark.circle"
        case .knownExplanationLikely: "circle.lefthalf.filled"
        case .explained: "diamond"
        case .disputed: "arrow.triangle.branch"
        case .corrected: "pencil.circle"
        case .archived: "square"
        }
    }

    /// Maps the legacy Phase 1 status onto the V2 vocabulary during migration.
    init(_ legacy: CaseStatus) {
        switch legacy {
        case .explained: self = .explained
        case .likelyExplained: self = .knownExplanationLikely
        case .insufficientData: self = .informationInsufficient
        case .underReview: self = .underReview
        case .notableUnresolved: self = .underReview
        case .disputed: self = .disputed
        // A withdrawn/retracted report reads as a correction (consistent with
        // `UAPCase.whatChanged`, which treats `.withdrawn` as `.correction`).
        case .withdrawn: self = .corrected
        }
    }
}

/// The distinct geometric marks per status. Drawn by `CaseStatusGlyph`.
enum StatusGeometry: Sendable {
    case pointInRing
    case openRingTick
    case openRingGap
    case halfFilled
    case diamond
    case offsetArcs
    case diamondRevision
    case squareOutline
}
