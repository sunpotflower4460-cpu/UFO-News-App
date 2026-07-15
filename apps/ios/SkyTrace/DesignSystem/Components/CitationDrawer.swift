import SwiftUI

/// A medium-height drawer that shows the source behind a tapped in-text
/// citation marker (V3 §5.3): its footnote number, outlet, type, title, any
/// rights-cleared excerpt, and an in-app link to the original. Presented as a
/// sheet so the reader never loses their place in the article.
struct CitationDrawer: View {
    let number: Int
    let source: SourceReference
    @State private var linkToOpen: IdentifiedURL?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SkySpacing.x4) {
                    HStack(alignment: .top, spacing: SkySpacing.x3) {
                        Text("[\(number)]")
                            .font(SkyTypography.sectionHeading.monospacedDigit())
                            .foregroundStyle(SkyColor.signalCyan)
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: SkySpacing.x2) {
                                Text(source.outletName)
                                    .font(SkyTypography.supporting.weight(.semibold))
                                    .foregroundStyle(SkyColor.textPrimary)
                                Text(SkyStrings.t(source.sourceType.labelKey))
                                    .font(.caption2).foregroundStyle(SkyColor.textTertiary)
                            }
                            Text(source.title)
                                .font(SkyTypography.body).foregroundStyle(SkyColor.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            if let published = source.publishedAt {
                                Text(SkyFormat.dateOnly(published))
                                    .font(.caption2).foregroundStyle(SkyColor.textTertiary)
                            }
                        }
                        Spacer(minLength: 0)
                    }

                    if let excerpt = source.allowedExcerpt, !excerpt.isEmpty {
                        VStack(alignment: .leading, spacing: SkySpacing.x1) {
                            Text(SkyStrings.t("citation.excerpt"))
                                .font(.caption2.weight(.semibold)).foregroundStyle(SkyColor.textTertiary)
                            Text(excerpt)
                                .font(SkyTypography.supporting).foregroundStyle(SkyColor.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(SkySpacing.x3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(SkyColor.surfaceSecondary, in: RoundedRectangle(cornerRadius: SkyRadius.chip))
                    }

                    if let url = source.url {
                        Button {
                            linkToOpen = IdentifiedURL(url: url)
                        } label: {
                            Label(SkyStrings.t("sources.openLink"), systemImage: "arrow.up.right.square")
                                .font(SkyTypography.supporting.weight(.semibold))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent).tint(SkyColor.signalCyan)
                    }
                }
                .padding(.horizontal, SkySpacing.screenEdge)
                .padding(.vertical, SkySpacing.x4)
            }
            .background(SkyColor.canvas)
            .navigationTitle(SkyStrings.t("citation.drawerTitle", String(number)))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(SkyStrings.t("action.close")) { dismiss() }
                }
            }
            .sheet(item: $linkToOpen) { SafariView(url: $0.url) }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
