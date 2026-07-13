import SwiftUI
import SafariServices

/// Presents a source link in an in-app Safari view (per UI plan: SFSafariView
/// for source rows). Offline handling is the caller's concern.
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}

/// A small identifiable URL wrapper so `.sheet(item:)` can present links.
struct IdentifiedURL: Identifiable {
    let id = UUID()
    let url: URL
}
