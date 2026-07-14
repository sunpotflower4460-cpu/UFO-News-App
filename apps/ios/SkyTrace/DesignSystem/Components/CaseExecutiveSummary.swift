import SwiftUI

/// The "現時点" snapshot at the top of Case Detail: current state, the leading
/// known explanation, and the main open point — so a reader knows where the
/// case stands before the deep sections (V3 §5.1). Quiet Zone: legible, no
/// glass, status shown by icon + text, never a single truth score.
struct CaseExecutiveSnapshot: Sendable, Hashable {
    let currentState: String
    let leadingExplanation: String?
    let openPoint: String?
}

struct CaseExecutiveSummary: View {
    let snapshot: CaseExecutiveSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x2) {
            Text(SkyStrings.t("case.currentState"))
                .font(SkyTypography.metadata.weight(.semibold))
                .foregroundStyle(SkyColor.accentPrimary)
            Text(snapshot.currentState)
                .font(SkyTypography.body).foregroundStyle(SkyColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            if let leading = snapshot.leadingExplanation {
                row("scope", SkyStrings.t("case.leadingExplanation", leading), SkyColor.signalCyan)
            }
            if let open = snapshot.openPoint {
                row("questionmark.circle", SkyStrings.t("case.openPoint", open), SkyColor.signalWarm)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SkySpacing.x4)
        .background(SkyColor.surfaceSecondary, in: RoundedRectangle(cornerRadius: SkyRadius.card, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: SkyRadius.card, style: .continuous)
            .strokeBorder(SkyColor.borderSubtle, lineWidth: 1))
        .accessibilityElement(children: .combine)
    }

    private func row(_ icon: String, _ text: String, _ color: Color) -> some View {
        HStack(alignment: .top, spacing: SkySpacing.x2) {
            Image(systemName: icon).foregroundStyle(color).font(.caption).padding(.top, 2)
            Text(text).font(SkyTypography.supporting).foregroundStyle(SkyColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
