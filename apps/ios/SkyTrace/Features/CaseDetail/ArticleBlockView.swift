import SwiftUI

/// Renders one article block with its provenance treatment: inference blocks are
/// labelled with confidence, unknown blocks state what's missing, and source
/// footnote markers are shown after fact blocks.
struct ArticleBlockView: View {
    let block: ArticleBlock
    /// Maps a source id to its footnote number (1-based) within the article.
    /// Returns nil when the id can't be resolved to a real source — then a
    /// plain, non-tappable footnote is shown instead of a live marker.
    var citationNumber: (String) -> Int? = { _ in nil }
    /// Invoked when a citation marker is tapped, with the tapped source id.
    var onCite: (String) -> Void = { _ in }

    var body: some View {
        switch block.kind {
        case .heading:
            Text(block.text).font(SkyTypography.sectionHeading)
                .foregroundStyle(SkyColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, SkySpacing.x2)
        case .factParagraph, .calculation, .quote:
            VStack(alignment: .leading, spacing: SkySpacing.x2) {
                Text(block.text).font(SkyTypography.body).foregroundStyle(SkyColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                citations
            }
        case .inference:
            calloutBlock(
                label: SkyStrings.t("article.inferenceLabel",
                                    String(Int((block.confidence ?? 0) * 100))),
                role: .violet, symbol: "arrow.triangle.branch")
        case .unknown:
            calloutBlock(label: SkyStrings.t("article.unknownLabel"),
                         role: .amber, symbol: "questionmark.circle")
        }
    }

    private func calloutBlock(label: String, role: SignalRole, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: SkySpacing.x1) {
            Label(label, systemImage: symbol)
                .font(.caption.weight(.semibold)).foregroundStyle(SkyColor.signal(role))
            Text(block.text).font(SkyTypography.body).foregroundStyle(SkyColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(SkySpacing.x3)
        .background(SkyColor.signal(role).opacity(0.08), in: RoundedRectangle(cornerRadius: SkyRadius.chip))
    }

    /// Citation markers after a fact block. Each resolvable source becomes a
    /// tappable "[n]" chip that opens the citation drawer; unresolved ids fall
    /// back to a plain footnote so a block never loses its provenance.
    @ViewBuilder private var citations: some View {
        let numbered = block.sourceIDs.compactMap { id in citationNumber(id).map { (id, $0) } }
        if !numbered.isEmpty {
            HStack(spacing: SkySpacing.x1) {
                ForEach(numbered, id: \.0) { id, n in
                    Button { onCite(id) } label: {
                        Text("[\(n)]")
                            .font(.caption2.weight(.semibold)).monospacedDigit()
                            .foregroundStyle(SkyColor.signalCyan)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(SkyColor.signalCyan.opacity(0.12), in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(SkyStrings.t("citation.marker", String(n)))
                    .accessibilityHint(SkyStrings.t("citation.hint"))
                }
            }
        } else if !block.sourceIDs.isEmpty {
            Text("— " + block.sourceIDs.map { "[\($0)]" }.joined(separator: " "))
                .font(.caption2).foregroundStyle(SkyColor.signalCyan)
        }
    }
}
