import SwiftUI

/// Status badge: always pairs an SF Symbol + word so meaning never rests on
/// colour alone (accessibility requirement).
struct StatusBadge: View {
    let status: CaseStatus
    var compact: Bool = false

    var body: some View {
        let tint = SkyColor.signal(status.signal)
        HStack(spacing: SkySpacing.x1) {
            Image(systemName: status.systemImage)
                .imageScale(.small)
            if !compact {
                Text(SkyStrings.t(status.labelKey))
                    .font(SkyTypography.metadata.weight(.semibold))
            }
        }
        .foregroundStyle(tint)
        .padding(.horizontal, SkySpacing.x2)
        .padding(.vertical, SkySpacing.x1)
        .background(tint.opacity(0.14), in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(SkyStrings.t(status.labelKey))
    }
}

/// "DEMO DATA" badge — makes fixture content impossible to mistake for news.
struct DemoBadge: View {
    var body: some View {
        Text(SkyStrings.t("label.demo"))
            .font(.caption2.weight(.bold))
            .tracking(0.5)
            .foregroundStyle(SkyColor.signalAmber)
            .padding(.horizontal, SkySpacing.x2)
            .padding(.vertical, 2)
            .overlay(Capsule().strokeBorder(SkyColor.signalAmber.opacity(0.6), lineWidth: 1))
            .accessibilityLabel(SkyStrings.t("label.demo"))
    }
}

/// Small "updated" pill.
struct UpdateBadge: View {
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "arrow.triangle.2.circlepath").imageScale(.small)
            Text(SkyStrings.t("label.updated")).font(.caption2.weight(.semibold))
        }
        .foregroundStyle(SkyColor.signalCyan)
        .accessibilityLabel(SkyStrings.t("label.updated"))
    }
}

/// Plus marker used on gated content.
struct PremiumBadge: View {
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "sparkles").imageScale(.small)
            Text(SkyStrings.t("label.plus")).font(.caption2.weight(.bold))
        }
        .foregroundStyle(SkyColor.signalViolet)
        .padding(.horizontal, SkySpacing.x2)
        .padding(.vertical, 2)
        .background(SkyColor.signalViolet.opacity(0.14), in: Capsule())
        .accessibilityLabel(SkyStrings.t("label.plus"))
    }
}

/// AI disclosure chip.
struct AIDisclosureBadge: View {
    let disclosure: AIDisclosure
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: disclosure.systemImage).imageScale(.small)
            Text(SkyStrings.t(disclosure.labelKey)).font(SkyTypography.metadata)
        }
        .foregroundStyle(SkyColor.textSecondary)
        .accessibilityLabel(SkyStrings.t(disclosure.labelKey))
    }
}

/// Generic outlined chip for tags / filters.
struct SkyChip: View {
    let text: String
    var systemImage: String? = nil
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            if let systemImage { Image(systemName: systemImage).imageScale(.small) }
            Text(text).font(SkyTypography.metadata.weight(.medium))
        }
        .foregroundStyle(isSelected ? SkyColor.canvas : SkyColor.textSecondary)
        .padding(.horizontal, SkySpacing.x3)
        .padding(.vertical, SkySpacing.x2)
        .background(
            isSelected ? SkyColor.signalCyan : SkyColor.surfaceInteractive,
            in: Capsule()
        )
    }
}

#Preview("Badges") {
    VStack(alignment: .leading, spacing: 12) {
        ForEach(CaseStatus.allCases) { StatusBadge(status: $0) }
        HStack { DemoBadge(); UpdateBadge(); PremiumBadge() }
        AIDisclosureBadge(disclosure: .editorReviewed)
        HStack { SkyChip(text: "円盤形", isSelected: true); SkyChip(text: "光点", systemImage: "circle") }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(SkyColor.canvas)
}
