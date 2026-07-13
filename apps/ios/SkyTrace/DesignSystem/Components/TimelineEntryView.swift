import SwiftUI

/// A single timeline entry. Frames corrections as "understanding advanced",
/// never as a downgrade.
struct TimelineEntryView: View {
    let entry: CaseTimelineEntry
    var isLast: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: SkySpacing.x3) {
            VStack(spacing: 0) {
                Circle().fill(SkyColor.signalCyan).frame(width: 9, height: 9).padding(.top, 4)
                if !isLast {
                    Rectangle().fill(SkyColor.borderSubtle).frame(width: 1)
                        .frame(maxHeight: .infinity)
                }
            }
            VStack(alignment: .leading, spacing: SkySpacing.x1) {
                Text(SkyFormat.dateOnly(entry.date))
                    .font(.caption.weight(.semibold)).foregroundStyle(SkyColor.textTertiary)
                Text(entry.summary).font(SkyTypography.body)
                    .foregroundStyle(SkyColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                if let change = entry.statusChange {
                    StatusBadge(status: change)
                }
                if let note = entry.scoreChangeNote {
                    Text(note).font(.caption2.monospacedDigit()).foregroundStyle(SkyColor.textSecondary)
                }
            }
            .padding(.bottom, isLast ? 0 : SkySpacing.x4)
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}
