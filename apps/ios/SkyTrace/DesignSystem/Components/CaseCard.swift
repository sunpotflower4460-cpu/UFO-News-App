import SwiftUI

/// Reusable case card with variants. The whole card is a single tap target with
/// a combined VoiceOver label; it never nests many small buttons.
struct CaseCard: View {
    enum Variant { case featured, standard, compact, mapSheet, savedUpdate }

    let uapCase: UAPCase
    var variant: Variant = .standard

    var body: some View {
        switch variant {
        case .featured: featured
        case .standard, .savedUpdate: standard
        case .compact: compact
        case .mapSheet: mapSheet
        }
    }

    // MARK: Variants

    private var featured: some View {
        VStack(alignment: .leading, spacing: 0) {
            ObservationGlyph(seed: seed)
                .frame(height: 132)
            VStack(alignment: .leading, spacing: SkySpacing.x2) {
                topRow
                Text(uapCase.title).font(SkyTypography.cardHeadline.weight(.semibold))
                    .foregroundStyle(SkyColor.textPrimary)
                    .lineLimit(3)
                Text(uapCase.summary).font(SkyTypography.supporting)
                    .foregroundStyle(SkyColor.textSecondary).lineLimit(3)
                footer
            }
            .padding(SkySpacing.x4)
        }
        .background(SkyColor.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: SkyRadius.hero, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: SkyRadius.hero, style: .continuous)
            .strokeBorder(SkyColor.borderSubtle, lineWidth: 1))
        .modifier(A11yCard(uapCase: uapCase))
    }

    private var standard: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x2) {
            topRow
            Text(uapCase.title).font(SkyTypography.cardHeadline)
                .foregroundStyle(SkyColor.textPrimary).lineLimit(2)
            Text(uapCase.summary).font(SkyTypography.supporting)
                .foregroundStyle(SkyColor.textSecondary).lineLimit(2)
            footer
        }
        .cardSurface()
        .modifier(A11yCard(uapCase: uapCase))
    }

    private var compact: some View {
        HStack(spacing: SkySpacing.x3) {
            VStack { CaseStatusGlyph(status: uapCase.v2Status, size: 22); Spacer(minLength: 0) }
            VStack(alignment: .leading, spacing: SkySpacing.x1) {
                Text(uapCase.title).font(SkyTypography.supporting.weight(.semibold))
                    .foregroundStyle(SkyColor.textPrimary).lineLimit(2)
                HStack(spacing: SkySpacing.x2) {
                    Text(regionTime).font(.caption2).foregroundStyle(SkyColor.textTertiary)
                    if uapCase.hasRecentUpdate { UpdateBadge() }
                }
            }
            Spacer(minLength: 0)
            if uapCase.isDemo { DemoBadge() }
        }
        .cardSurface(padding: SkySpacing.x3)
        .modifier(A11yCard(uapCase: uapCase))
    }

    private var mapSheet: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x2) {
            topRow
            Text(uapCase.title).font(SkyTypography.cardHeadline).foregroundStyle(SkyColor.textPrimary)
            Text(uapCase.summary).font(SkyTypography.supporting)
                .foregroundStyle(SkyColor.textSecondary).lineLimit(3)
            ProvenanceRow(sourceCount: uapCase.sourceCount, independentCount: uapCase.independentReportCount)
        }
        .modifier(A11yCard(uapCase: uapCase))
    }

    // MARK: Pieces

    private var topRow: some View {
        HStack(spacing: SkySpacing.x2) {
            CaseStatusLabel(status: uapCase.v2Status)
            if uapCase.hasRecentUpdate { UpdateBadge() }
            Spacer()
            if uapCase.isDemo { DemoBadge() }
        }
    }

    private var footer: some View {
        HStack {
            Text(regionTime).font(.caption2).foregroundStyle(SkyColor.textTertiary)
            Spacer()
            ProvenanceRow(sourceCount: uapCase.sourceCount, independentCount: uapCase.independentReportCount)
        }
    }

    private var regionTime: String {
        let region = uapCase.localityName ?? uapCase.regionName
        if let occurred = uapCase.occurredAtStart {
            return "\(region) · \(SkyFormat.dateOnly(occurred))"
        }
        return region
    }

    private var seed: Int { abs(uapCase.id.hashValue) % 100 }
}

/// Builds the combined accessibility label, e.g.
/// "調査継続。北海道東部の3つの発光体。独立報告3件、出典5件。最終更新…。詳細を開く。"
private struct A11yCard: ViewModifier {
    let uapCase: UAPCase
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityHint(SkyStrings.t("action.openDetail"))
            .accessibilityAddTraits(.isButton)
    }
    private var label: String {
        var parts: [String] = [SkyStrings.t(uapCase.v2Status.labelKey), uapCase.title]
        parts.append(SkyStrings.t("label.independent", String(uapCase.independentReportCount)))
        parts.append(SkyStrings.t("label.sources", String(uapCase.sourceCount)))
        if let v = uapCase.lastVerifiedAt {
            parts.append(SkyStrings.t("label.lastVerified", SkyFormat.dateTime(v)))
        }
        if uapCase.isDemo { parts.append(SkyStrings.t("label.demo")) }
        return parts.joined(separator: "。")
    }
}
