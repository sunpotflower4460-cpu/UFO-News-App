import SwiftUI

/// Renders one article block with its provenance treatment: inference blocks are
/// labelled with confidence, unknown blocks state what's missing, and source
/// footnote markers are shown after fact blocks.
struct ArticleBlockView: View {
    let block: ArticleBlock

    var body: some View {
        switch block.kind {
        case .heading:
            Text(block.text).font(SkyTypography.sectionHeading)
                .foregroundStyle(SkyColor.textPrimary)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, SkySpacing.x2)
        case .factParagraph, .calculation, .quote:
            VStack(alignment: .leading, spacing: SkySpacing.x1) {
                Text(block.text).font(SkyTypography.body).foregroundStyle(SkyColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                if !block.sourceIDs.isEmpty {
                    Text(footnotes).font(.caption2).foregroundStyle(SkyColor.signalCyan)
                }
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

    private var footnotes: String {
        "— " + block.sourceIDs.map { "[\($0)]" }.joined(separator: " ")
    }
}
