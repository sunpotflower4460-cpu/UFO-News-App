import SwiftUI

/// Reusable case card with variants. Media leads every variant (directive §3.3:
/// image → title → outlet → place/time → short fact → update label); no
/// 8-axis score, AI verdict, or unresolvedness number is ever primary card
/// content — status is a small icon-only badge, never the headline. The whole
/// card is a single tap target with a combined VoiceOver label.
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
            leadVisual.frame(height: 150)
            VStack(alignment: .leading, spacing: SkySpacing.x2) {
                Text(uapCase.title).font(SkyTypography.cardHeadline.weight(.semibold))
                    .foregroundStyle(SkyColor.textPrimary)
                    .lineLimit(3)
                outletRegionTime
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
        VStack(alignment: .leading, spacing: 0) {
            leadVisual.frame(height: 120)
            VStack(alignment: .leading, spacing: SkySpacing.x2) {
                Text(uapCase.title).font(SkyTypography.cardHeadline)
                    .foregroundStyle(SkyColor.textPrimary).lineLimit(2)
                outletRegionTime
                Text(uapCase.summary).font(SkyTypography.supporting)
                    .foregroundStyle(SkyColor.textSecondary).lineLimit(2)
                footer
            }
            .padding(SkySpacing.x4)
        }
        .background(SkyColor.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: SkyRadius.card, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: SkyRadius.card, style: .continuous)
            .strokeBorder(SkyColor.borderSubtle, lineWidth: 1))
        .modifier(A11yCard(uapCase: uapCase))
    }

    private var compact: some View {
        HStack(alignment: .top, spacing: SkySpacing.x3) {
            leadThumbnail.frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: SkyRadius.chip, style: .continuous))
            VStack(alignment: .leading, spacing: SkySpacing.x1) {
                Text(uapCase.title).font(SkyTypography.supporting.weight(.semibold))
                    .foregroundStyle(SkyColor.textPrimary).lineLimit(2)
                outletRegionTime
                HStack(spacing: SkySpacing.x2) {
                    if uapCase.hasRecentUpdate { UpdateBadge() }
                    if uapCase.isDemo { DemoBadge() }
                }
            }
            Spacer(minLength: 0)
        }
        .cardSurface(padding: SkySpacing.x3)
        .modifier(A11yCard(uapCase: uapCase))
    }

    private var mapSheet: some View {
        VStack(alignment: .leading, spacing: 0) {
            leadVisual.frame(height: 100)
            VStack(alignment: .leading, spacing: SkySpacing.x2) {
                Text(uapCase.title).font(SkyTypography.cardHeadline).foregroundStyle(SkyColor.textPrimary)
                outletRegionTime
                Text(uapCase.summary).font(SkyTypography.supporting)
                    .foregroundStyle(SkyColor.textSecondary).lineLimit(3)
                ProvenanceRow(sourceCount: uapCase.sourceCount, independentCount: uapCase.independentReportCount)
            }
            .padding(.top, SkySpacing.x3)
        }
        .modifier(A11yCard(uapCase: uapCase))
    }

    // MARK: Pieces

    /// Real media when a rights-cleared asset exists; otherwise the abstract,
    /// non-photographic `ObservationGlyph` — never a blank space, never a stand-
    /// in for evidence quality.
    @ViewBuilder private var leadVisual: some View {
        ZStack(alignment: .topTrailing) {
            if let asset = uapCase.primaryMedia, asset.canDisplayInline, let url = asset.previewURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    default: ObservationGlyph(seed: seed)
                    }
                }
            } else {
                ObservationGlyph(seed: seed)
            }
            badgeRow
                .padding(.horizontal, SkySpacing.x2).padding(.vertical, SkySpacing.x1)
                .background(.black.opacity(0.35), in: Capsule())
                .padding(SkySpacing.x2)
        }
        .clipped()
    }

    @ViewBuilder private var leadThumbnail: some View {
        if let asset = uapCase.primaryMedia, asset.canDisplayInline, let url = asset.previewURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFill()
                default: ObservationGlyph(seed: seed)
                }
            }
        } else {
            ObservationGlyph(seed: seed)
        }
    }

    /// Small, icon-first status marker over the media corner — never the
    /// card's headline element. The DEMO marker always accompanies it so
    /// fixture content is never mistaken for real news (CLAUDE.md §3).
    private var badgeRow: some View {
        HStack(spacing: SkySpacing.x1) {
            StatusBadge(status: uapCase.status, compact: true)
            if uapCase.isDemo { DemoBadge() }
        }
    }

    private var outletRegionTime: some View {
        HStack(spacing: SkySpacing.x2) {
            if let outlet = uapCase.leadOutletName {
                Text(outlet).font(.caption2.weight(.semibold)).foregroundStyle(SkyColor.accentPrimary)
                Text("·").foregroundStyle(SkyColor.textTertiary)
            }
            Text(regionTime).font(.caption2).foregroundStyle(SkyColor.textTertiary)
        }
    }

    private var footer: some View {
        HStack {
            if uapCase.hasRecentUpdate { UpdateBadge() }
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
        parts.append(SkyStrings.t("label.sources", uapCase.sourceCount))
        if let v = uapCase.lastVerifiedAt {
            parts.append(SkyStrings.t("label.lastVerified", SkyFormat.dateTime(v)))
        }
        if uapCase.isDemo { parts.append(SkyStrings.t("label.demo")) }
        return parts.joined(separator: "。")
    }
}
