import SwiftUI

/// The case's images/video. Rights-cleared assets render inline (with credit and
/// a rights badge); rights-unknown assets are shown only as a link to the source
/// — SkyTrace never hosts or redistributes unlicensed media (CLAUDE.md §7).
struct CaseMediaSection: View {
    let media: [MediaAsset]
    var onOpenSource: (URL) -> Void

    var body: some View {
        EditorialSection(title: SkyStrings.t("case.media.title"), systemImage: "photo.on.rectangle.angled") {
            VStack(alignment: .leading, spacing: SkySpacing.x4) {
                Text(SkyStrings.t("media.sectionNote"))
                    .font(SkyTypography.metadata).foregroundStyle(SkyColor.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
                ForEach(media) { MediaAssetView(asset: $0, onOpenSource: onOpenSource) }
            }
        }
    }
}

/// One media asset. Cleared → inline preview (real image when the backend
/// provides one, else an abstract observation placeholder) + credit + rights
/// badge, tappable to the source. Rights-unknown → a link-out card only.
struct MediaAssetView: View {
    let asset: MediaAsset
    var onOpenSource: (URL) -> Void

    var body: some View {
        if asset.canDisplayInline {
            inlineCard
        } else {
            linkCard
        }
    }

    // MARK: Cleared — inline

    private var inlineCard: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x2) {
            preview
                .frame(height: 180).frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: SkyRadius.card))
                .overlay(alignment: .center) {
                    if asset.kind == .video {
                        Image(systemName: "play.circle.fill").font(.system(size: 40))
                            .foregroundStyle(.white.opacity(0.9))
                            .shadow(radius: 6)
                    }
                }
                .overlay(alignment: .bottomTrailing) { rightsBadge }
            meta
        }
        .contentShape(Rectangle())
        .onTapGesture { onOpenSource(asset.sourceURL) }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
        .accessibilityHint(SkyStrings.t("media.viewAtSource"))
        .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder private var preview: some View {
        if let url = asset.previewURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFill()
                default: placeholder
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ObservationGlyph(seed: abs(asset.id.hashValue % 997))
            .background(SkyColor.surfaceSecondary)
    }

    private var rightsBadge: some View {
        Text(SkyStrings.t(asset.rights.labelKey))
            .font(.caption2.weight(.semibold)).foregroundStyle(.white)
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(.black.opacity(0.55), in: Capsule())
            .padding(SkySpacing.x2)
    }

    private var meta: some View {
        VStack(alignment: .leading, spacing: 1) {
            if let caption = asset.caption {
                Text(caption).font(SkyTypography.metadata).foregroundStyle(SkyColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack(spacing: SkySpacing.x1) {
                Text(SkyStrings.t("media.credit", asset.attribution))
                if let note = asset.licenseNote { Text("·"); Text(note) }
            }
            .font(.caption2).foregroundStyle(SkyColor.textTertiary)
        }
    }

    // MARK: Rights-unknown — link only

    private var linkCard: some View {
        Button { onOpenSource(asset.sourceURL) } label: {
            HStack(alignment: .top, spacing: SkySpacing.x3) {
                Image(systemName: asset.kind.systemImage)
                    .foregroundStyle(SkyColor.signalCyan).frame(width: 28).padding(.top, 2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(asset.caption ?? SkyStrings.t(asset.kind.labelKey))
                        .font(SkyTypography.supporting.weight(.semibold))
                        .foregroundStyle(SkyColor.textPrimary).lineLimit(2)
                    Text(SkyStrings.t("media.credit", asset.attribution))
                        .font(.caption2).foregroundStyle(SkyColor.textTertiary)
                    Text(SkyStrings.t("media.linkOnlyNote"))
                        .font(.caption2).foregroundStyle(SkyColor.signalWarm)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right.square").foregroundStyle(SkyColor.textTertiary)
            }
            .padding(SkySpacing.x3)
            .background(SkyColor.surfaceSecondary, in: RoundedRectangle(cornerRadius: SkyRadius.chip))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint(SkyStrings.t("sources.openLink"))
    }

    private var accessibilityText: String {
        [asset.caption, SkyStrings.t(asset.kind.labelKey),
         SkyStrings.t("media.credit", asset.attribution),
         SkyStrings.t(asset.rights.labelKey)].compactMap { $0 }.joined(separator: "、")
    }
}
