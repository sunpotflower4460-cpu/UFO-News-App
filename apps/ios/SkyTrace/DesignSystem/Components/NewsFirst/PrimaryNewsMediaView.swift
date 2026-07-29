import SwiftUI

/// Media First (directive §4.2): the case's lead image/video appears directly
/// under the header, above any source link or AI content. Rights-cleared media
/// renders inline with a visible "元の画像/映像を見る" action (not just an
/// accessibility hint); rights-unknown media is never rendered as an image —
/// only a link-out card (`MediaAssetView`'s existing gate). No media at all
/// falls back to the same abstract `ObservationGlyph` used elsewhere in the
/// design system, so every case still has a lead visual.
struct PrimaryNewsMediaView: View {
    let uapCase: UAPCase
    var onOpenSource: (URL) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x3) {
            if let lead = uapCase.primaryMedia {
                if lead.canDisplayInline {
                    clearedHero(lead)
                } else {
                    MediaAssetView(asset: lead, onOpenSource: onOpenSource)
                }
            } else {
                glyphFallback
            }
            ForEach(uapCase.additionalMedia) { asset in
                MediaAssetView(asset: asset, onOpenSource: onOpenSource)
            }
        }
    }

    // MARK: Cleared primary asset — large hero + visible CTA

    private func clearedHero(_ asset: MediaAsset) -> some View {
        VStack(alignment: .leading, spacing: SkySpacing.x2) {
            preview(asset)
                .frame(height: 220).frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: SkyRadius.hero))
                .overlay(alignment: .center) {
                    if asset.kind == .video {
                        Image(systemName: "play.circle.fill").font(.system(size: 46))
                            .foregroundStyle(.white.opacity(0.9))
                            .shadow(radius: 6)
                    }
                }
                .overlay(alignment: .bottomTrailing) { rightsBadge(asset) }
            HStack(spacing: SkySpacing.x2) {
                Text(SkyStrings.t("media.credit", asset.attribution))
                if let note = asset.licenseNote { Text("·"); Text(note) }
            }
            .font(.caption2).foregroundStyle(SkyColor.textTertiary)
            if let caption = asset.caption {
                Text(caption).font(SkyTypography.metadata).foregroundStyle(SkyColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button {
                onOpenSource(asset.sourceURL)
            } label: {
                Label(
                    SkyStrings.t(asset.kind == .video ? "news.media.viewOriginalVideo" : "news.media.viewOriginalImage"),
                    systemImage: "arrow.up.right.square"
                )
                .font(SkyTypography.supporting.weight(.semibold))
                .foregroundStyle(SkyColor.accentPrimary)
            }
            .buttonStyle(.plain)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            [asset.caption, SkyStrings.t(asset.kind.labelKey), SkyStrings.t("media.credit", asset.attribution),
             SkyStrings.t(asset.rights.labelKey)].compactMap { $0 }.joined(separator: "、")
        )
    }

    @ViewBuilder private func preview(_ asset: MediaAsset) -> some View {
        if let url = asset.previewURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFill()
                default: ObservationGlyph(seed: abs(asset.id.hashValue % 997)).background(SkyColor.surfaceSecondary)
                }
            }
        } else {
            ObservationGlyph(seed: abs(asset.id.hashValue % 997)).background(SkyColor.surfaceSecondary)
        }
    }

    private func rightsBadge(_ asset: MediaAsset) -> some View {
        Text(SkyStrings.t(asset.rights.labelKey))
            .font(.caption2.weight(.semibold)).foregroundStyle(.white)
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(.black.opacity(0.55), in: Capsule())
            .padding(SkySpacing.x2)
    }

    // MARK: No media at all — abstract fallback, never a blank space

    private var glyphFallback: some View {
        ObservationGlyph(seed: abs(uapCase.id.hashValue % 997))
            .frame(height: 180).frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: SkyRadius.hero))
            .accessibilityHidden(true)
    }
}

#Preview("Primary News Media — cleared") {
    ScrollView {
        PrimaryNewsMediaView(uapCase: DemoCases.northSeaNotable, onOpenSource: { _ in })
            .padding()
    }
    .background(SkyColor.canvas)
}

#Preview("Primary News Media — no media") {
    ScrollView {
        PrimaryNewsMediaView(uapCase: DemoCases.starlink, onOpenSource: { _ in })
            .padding()
    }
    .background(SkyColor.canvas)
}
