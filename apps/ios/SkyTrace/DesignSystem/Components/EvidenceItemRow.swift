import SwiftUI

/// One evidence record (kind + what it is + when captured). Distinct from
/// `SourceRow`, which is a citation. Quiet Zone styling — legible, not glassy.
struct EvidenceItemRow: View {
    let item: EvidenceItem

    var body: some View {
        HStack(alignment: .top, spacing: SkySpacing.x3) {
            Image(systemName: item.kind.systemImage)
                .foregroundStyle(SkyColor.accentSecondary)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(SkyStrings.t(item.kind.labelKey))
                    .font(SkyTypography.metadata.weight(.semibold))
                    .foregroundStyle(SkyColor.textSecondary)
                Text(item.title)
                    .font(SkyTypography.supporting)
                    .foregroundStyle(SkyColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                if let captured = item.capturedAt {
                    Text(SkyStrings.t("evidence.captured", SkyFormat.dateOnly(captured)))
                        .font(SkyTypography.metadata).foregroundStyle(SkyColor.textTertiary)
                }
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}
