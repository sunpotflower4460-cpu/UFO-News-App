import SwiftUI

/// Contextual Plus lock. Never a bare padlock — always names what unlocks and
/// how deep the content goes, with a context-appropriate CTA.
struct PremiumLockView: View {
    let title: String
    let unlocks: [String]
    var ctaTitle: String
    var onUnlock: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x3) {
            HStack(spacing: SkySpacing.x2) {
                Image(systemName: "sparkles").foregroundStyle(SkyColor.signalViolet)
                Text(title).font(SkyTypography.cardHeadline).foregroundStyle(SkyColor.textPrimary)
                Spacer()
                PremiumBadge()
            }
            VStack(alignment: .leading, spacing: SkySpacing.x2) {
                ForEach(unlocks, id: \.self) { item in
                    HStack(spacing: SkySpacing.x2) {
                        Image(systemName: "checkmark.circle.fill").imageScale(.small)
                            .foregroundStyle(SkyColor.signalViolet)
                        Text(item).font(SkyTypography.supporting).foregroundStyle(SkyColor.textSecondary)
                    }
                }
            }
            Button(action: onUnlock) {
                Text(ctaTitle).font(SkyTypography.supporting.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(SkyColor.signalViolet)
        }
        .padding(SkySpacing.x5)
        .background(
            LinearGradient(colors: [SkyColor.surfacePrimary, SkyColor.signalViolet.opacity(0.08)],
                           startPoint: .top, endPoint: .bottom),
            in: RoundedRectangle(cornerRadius: SkyRadius.hero, style: .continuous)
        )
        .overlay(RoundedRectangle(cornerRadius: SkyRadius.hero, style: .continuous)
            .strokeBorder(SkyColor.signalViolet.opacity(0.3), lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityHint(ctaTitle)
    }
}
