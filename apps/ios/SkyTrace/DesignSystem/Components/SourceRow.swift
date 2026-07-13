import SwiftUI

/// One source citation. Shows outlet name + document type + role, not just a
/// bare domain. Opens externally via the provided handler (SFSafariView).
struct SourceRow: View {
    let source: SourceReference
    var onOpen: (URL) -> Void = { _ in }

    var body: some View {
        Button {
            if let url = source.url { onOpen(url) }
        } label: {
            HStack(alignment: .top, spacing: SkySpacing.x3) {
                Image(systemName: source.sourceType.systemImage)
                    .foregroundStyle(SkyColor.signalCyan)
                    .frame(width: 22)
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: SkySpacing.x2) {
                        Text(source.outletName)
                            .font(SkyTypography.supporting.weight(.semibold))
                            .foregroundStyle(SkyColor.textPrimary)
                        Text(SkyStrings.t(source.sourceType.labelKey))
                            .font(.caption2)
                            .foregroundStyle(SkyColor.textTertiary)
                        roleTag
                    }
                    Text(source.title)
                        .font(SkyTypography.supporting)
                        .foregroundStyle(SkyColor.textSecondary)
                        .lineLimit(2)
                    if let published = source.publishedAt {
                        Text(SkyFormat.dateOnly(published))
                            .font(.caption2).foregroundStyle(SkyColor.textTertiary)
                    }
                }
                Spacer(minLength: 0)
                if source.url != nil {
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(SkyColor.textTertiary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(source.outletName)、\(SkyStrings.t(source.sourceType.labelKey))、\(source.title)")
        .accessibilityHint(source.url != nil ? SkyStrings.t("sources.openLink") : "")
    }

    private var roleTag: some View {
        let role = source.role
        let signal: SignalRole = role == .supports ? .green : (role == .contradicts ? .red : .neutral)
        return Text(SkyStrings.t(role.labelKey))
            .font(.caption2)
            .foregroundStyle(SkyColor.signal(signal))
    }
}
