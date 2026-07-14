import SwiftUI

/// A concrete evidence *record* the case rests on — distinct from a Source
/// (a citation). Evidence answers "what was recorded" (an official document,
/// instrument data, a database record); Sources answer "where it was reported".
/// Derived from record-bearing sources for now; production data will populate
/// evidence directly (see docs/DECISIONS.md D-V3-001).
struct EvidenceItem: Identifiable, Sendable, Hashable {
    let id: String
    let kind: EvidenceKind
    let title: String
    let capturedAt: Date?
    /// The source that provides this record (citation cross-reference).
    let sourceID: String
}

enum EvidenceKind: String, Sendable, Hashable {
    case officialRecord
    case instrumentData
    case databaseRecord
    case openData

    var labelKey: String { "evidence.kind.\(rawValue)" }

    var systemImage: String {
        switch self {
        case .officialRecord: "building.columns"
        case .instrumentData: "waveform.path.ecg"
        case .databaseRecord: "cylinder.split.1x2"
        case .openData: "chart.bar.doc.horizontal"
        }
    }

    /// Which source types count as evidence records (not just citations).
    init?(_ sourceType: SourceType) {
        switch sourceType {
        case .official: self = .officialRecord
        case .scientific: self = .instrumentData
        case .database: self = .databaseRecord
        case .openData: self = .openData
        case .press, .social: return nil
        }
    }
}
