import SwiftUI

/// Primary source actions (directive §4.3): up to three named, one-tap actions
/// directly under the media — "Reutersの記事を読む", never a bare "詳しく見る".
/// The verb varies by source type (an official body "announces", a scientific
/// source has "data") so each button reads like a real editorial action.
struct PrimarySourceActions: View {
    let sources: [SourceReference]
    var onOpen: (URL) -> Void

    var body: some View {
        if !sources.isEmpty {
            VStack(alignment: .leading, spacing: SkySpacing.x2) {
                ForEach(sources) { source in
                    Button {
                        if let url = source.url { onOpen(url) }
                    } label: {
                        HStack(spacing: SkySpacing.x3) {
                            Image(systemName: source.sourceType.systemImage)
                                .foregroundStyle(SkyColor.accentPrimary)
                                .frame(width: 22)
                            Text(SkyStrings.t(source.sourceType.newsActionLabelKey, source.outletName))
                                .font(SkyTypography.supporting.weight(.semibold))
                                .foregroundStyle(SkyColor.textPrimary)
                                .lineLimit(2)
                            Spacer(minLength: 0)
                            if source.url != nil {
                                Image(systemName: "arrow.up.right.square").foregroundStyle(SkyColor.textTertiary)
                            }
                        }
                        .padding(SkySpacing.x3)
                        .background(SkyColor.surfaceSecondary, in: RoundedRectangle(cornerRadius: SkyRadius.chip))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(source.url == nil)
                    .opacity(source.url == nil ? 0.5 : 1)
                    .accessibilityIdentifier("caseDetail.primarySource.\(source.id)")
                    .accessibilityHint(source.url != nil ? SkyStrings.t("sources.openLink") : "")
                }
            }
        }
    }
}

#Preview("Primary Source Actions") {
    VStack {
        PrimarySourceActions(sources: DemoCases.northSeaNotable.primarySources, onOpen: { _ in })
    }
    .padding()
    .background(SkyColor.canvas)
}
