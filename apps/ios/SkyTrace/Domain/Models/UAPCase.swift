import Foundation
import CoreLocation

/// The central entity: one "event in the sky", uniting many reports.
struct UAPCase: Codable, Sendable, Hashable, Identifiable {
    let id: String
    var slug: String
    var title: String
    /// 60-second summary, 4–6 lines.
    var summary: String

    // Times are kept distinct on purpose (P3 Trust Is Visible).
    var occurredAtStart: Date?
    var occurredAtEnd: Date?
    var publishedAt: Date
    var lastVerifiedAt: Date?
    var updatedAt: Date

    // Location
    var latitude: Double
    var longitude: Double
    var locationPrecision: LocationPrecision
    var countryCode: String
    var regionName: String
    var localityName: String?
    /// IANA time-zone identifier of the observation location, e.g. "Asia/Tokyo".
    var timeZoneIdentifier: String

    var status: CaseStatus
    var scores: CaseScores

    // Provenance counts, always shown distinctly.
    var sourceCount: Int
    var independentReportCount: Int

    // Rich detail
    var agreements: [AgreementPoint]
    var contradictions: [ContradictionPoint]
    var explanationCandidates: [ExplanationCandidate]
    var missingInformation: [EvidenceGap]
    var neededEvidence: [EvidenceGap]
    var timeline: [CaseTimelineEntry]
    var sources: [SourceReference]

    var currentAssessment: String
    var shapeTags: [String]

    /// True for fixture/demo content that must never be presented as production news.
    var isDemo: Bool

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Whether the case has any newer-than-published update worth flagging.
    var hasRecentUpdate: Bool {
        guard let last = timeline.map(\.date).max() else { return false }
        return last > publishedAt.addingTimeInterval(60)
    }
}

extension UAPCase {
    /// Location time zone, falling back to the current zone if malformed.
    var timeZone: TimeZone { TimeZone(identifier: timeZoneIdentifier) ?? .current }
}
