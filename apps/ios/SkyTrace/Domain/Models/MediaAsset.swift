import Foundation

/// Rights status for a media asset. It decides whether the item may be shown
/// inline or only linked to at its source — SkyTrace never hosts or
/// redistributes unlicensed third-party media (CLAUDE.md §7; DECISIONS D-007).
enum MediaRights: String, Codable, Sendable, Hashable {
    case publicDomain = "public_domain"
    case official                        // government / official-archive works
    case creativeCommons = "creative_commons"
    case licensed                        // a license we hold
    case rightsUnknown = "rights_unknown"

    /// Whether the asset may be displayed inline. Unknown/unlicensed media is
    /// never hosted — it is only linked to at its source.
    var allowsInlineDisplay: Bool {
        switch self {
        case .publicDomain, .official, .creativeCommons, .licensed: true
        case .rightsUnknown: false
        }
    }

    var labelKey: String { "media.rights.\(rawValue)" }
}

enum MediaKind: String, Codable, Sendable, Hashable {
    case image, video
    var systemImage: String { self == .video ? "play.rectangle.fill" : "photo" }
    var labelKey: String { "media.kind.\(rawValue)" }
}

/// A media item (image or video) associated with a case, carrying its rights
/// status so the UI can choose between inline display (rights-cleared) and a
/// link-out to the source (rights-unknown). `sourceURL` is always present — it
/// is the link-out target and the attribution destination; `mediaURL` is used
/// for inline rendering only when rights permit and a direct URL exists.
struct MediaAsset: Codable, Sendable, Hashable, Identifiable {
    let id: String
    var kind: MediaKind
    var rights: MediaRights
    /// The case source this media came from (a `SourceReference.id`).
    var sourceID: String
    /// Outlet / author credit shown with the asset.
    var attribution: String
    /// The page to open at the source — always shown as the link-out target.
    var sourceURL: URL
    /// Direct media URL, used for inline display only when `rights` permits and
    /// it exists (backend-provided). Nil in fixtures.
    var mediaURL: URL?
    /// Optional still/thumbnail for cleared items (esp. video).
    var thumbnailURL: URL?
    var caption: String?
    /// Optional license note, e.g. "Public domain (NASA)", "CC BY 4.0".
    var licenseNote: String?

    /// True when the asset may be rendered inline (rights are cleared).
    var canDisplayInline: Bool { rights.allowsInlineDisplay }

    /// URL suitable for `AsyncImage`. Video media URLs commonly point to MP4
    /// files, so prefer the still thumbnail; images prefer their direct media.
    var previewURL: URL? {
        switch kind {
        case .image: mediaURL ?? thumbnailURL
        case .video: thumbnailURL
        }
    }
}
