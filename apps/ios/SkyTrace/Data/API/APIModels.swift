import Foundation

/// Wire-format mirror of `docs/openapi/skytrace-v1.yaml`'s envelope + payload
/// shapes. These are deliberately separate from the `Domain/Models` types —
/// the API contract and the app's presentation model are allowed to diverge,
/// and a mapper (`APIMapping.swift`) is the single seam that translates
/// between them.
struct APIEnvelope<T: Decodable>: Decodable {
    let schemaVersion: String
    let generatedAt: Date
    let retrievedAt: Date
    let verifiedAt: Date?
    let contentRevision: Int
    let sourceRevision: Int
    let rightsState: String
    let locale: String
    let cacheTTL: Int
    let data: T
}

struct APISource: Decodable {
    let id: String
    let outletName: String
    let sourceType: String
    let title: String
    let publishedAt: Date?
    let retrievedAt: Date
    let role: String
    let url: URL?
}

struct APIMediaAsset: Decodable {
    let id: String
    let kind: String
    let rightsState: String
    let displayPermission: String
    let sourcePageURL: URL
    let mediaURL: URL?
    let thumbnailURL: URL?
    let attributionText: String
    let licenseNote: String?
}

struct APICase: Decodable {
    let id: String
    let slug: String
    let title: String
    let summary: String
    let occurredAtStart: Date?
    let publishedAt: Date
    let updatedAt: Date
    let lastVerifiedAt: Date?
    let locationPrecision: String
    let latitude: Double
    let longitude: Double
    let countryCode: String
    let regionName: String
    let localityName: String?
    let status: String
    let sourceCount: Int
    let independentReportCount: Int
    let sources: [APISource]
    let media: [APIMediaAsset]
    let isDemo: Bool
}

struct APIBriefing: Decodable {
    let id: String
    let date: Date
    let headline: String
    let summary: String
    let usedCaseCount: Int
    let sourceCount: Int
    let readingMinutes: Int
    let generatedAt: Date
    let disclosure: String
}

struct APITodayFeed: Decodable {
    let date: Date
    let lastUpdatedAt: Date
    let topCases: [APICase]
    let newReportCount: Int
    let mergedCaseCount: Int
}

struct APIRegion: Decodable {
    let countryCode: String
    let regionName: String
    let caseCount: Int
}

/// One item in the Premium "SNSでの目撃報告" feed. Deliberately has no
/// score/likelihood/rank field — see `SocialReportCandidate`'s doc comment.
struct APISocialReport: Decodable {
    let id: String
    let caseId: String
    let caseTitle: String
    let caseStatus: String
    let caseShapeTags: [String]
    let source: APISource
    let media: [APIMediaAsset]
    let isDemo: Bool
}

struct APIErrorBody: Decodable {
    let code: String
    let message: String
    let requestId: String
}
