import Foundation

/// One structured block of an AI-synthesised article. The LLM never returns
/// free Markdown; every factual block must trace to claims and sources.
struct ArticleBlock: Codable, Sendable, Hashable, Identifiable {
    enum Kind: String, Codable, Sendable {
        case heading
        case factParagraph = "fact_paragraph"
        case inference
        case unknown
        case quote
        case calculation

        var labelKey: String { "article.block.\(rawValue)" }
    }

    let id: String
    var kind: Kind
    var text: String
    /// Claim IDs backing this block (required for `factParagraph`).
    var claimIDs: [String]
    /// Source document IDs backing this block.
    var sourceIDs: [String]
    /// 0.0–1.0 confidence, used for `inference` blocks.
    var confidence: Double?
    /// For `unknown` blocks: which fields are missing.
    var missingFields: [String]

    var isPremiumGated: Bool
}

/// A versioned AI-synthesised article attached to a case.
struct SynthesizedArticle: Codable, Sendable, Hashable, Identifiable {
    let id: String
    var caseID: String
    var versionNumber: Int
    var headline: String
    var dek: String
    var blocks: [ArticleBlock]
    var readingMinutes: Int
    var generatedAt: Date
    var disclosure: AIDisclosure
    var modelLabel: String
    var promptVersion: String
    var correctionNote: String?
}
