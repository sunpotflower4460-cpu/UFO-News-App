import SwiftUI

/// The Trust Center (V3 §Trust): a first-class hub that states SkyTrace's stance
/// up front, explains the status vocabulary in plain language, and links to the
/// detailed editorial / AI / scoring / sources / corrections policies. Pulls the
/// product's core commitments (CLAUDE.md §2/§6/§7) out of scattered Settings rows
/// into one legible place. Read-only, no account required.
struct TrustCenterView: View {
    /// Policy pages surfaced here, in reading order.
    private let policies: [LegalPage] = [.editorial, .ai, .scores, .sources, .correction]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SkySpacing.x8) {
                hero
                stance
                statuses
                detailedPolicies
            }
            .padding(.horizontal, SkySpacing.screenEdge)
            .padding(.vertical, SkySpacing.x5)
            .readingWidth()
        }
        .background(SkyColor.canvas)
        .navigationTitle(SkyStrings.t("trust.title"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x3) {
            Image(systemName: "checkmark.shield")
                .font(.system(size: 30)).foregroundStyle(SkyColor.accentPrimary)
            Text(SkyStrings.t("trust.hero"))
                .font(SkyTypography.body).foregroundStyle(SkyColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var stance: some View {
        EditorialSection(title: SkyStrings.t("trust.stance.title"), systemImage: "hand.raised") {
            VStack(alignment: .leading, spacing: SkySpacing.x3) {
                ForEach(["trust.stance.1", "trust.stance.2", "trust.stance.3", "trust.stance.4"], id: \.self) { key in
                    HStack(alignment: .top, spacing: SkySpacing.x2) {
                        Image(systemName: "checkmark.circle.fill").imageScale(.small)
                            .foregroundStyle(SkyColor.accentPrimary).padding(.top, 2)
                        Text(SkyStrings.t(key)).font(SkyTypography.supporting)
                            .foregroundStyle(SkyColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private var statuses: some View {
        EditorialSection(title: SkyStrings.t("trust.status.title"), systemImage: "circle.hexagongrid") {
            VStack(alignment: .leading, spacing: SkySpacing.x4) {
                ForEach(SkyCaseStatus.allCases) { status in
                    HStack(alignment: .top, spacing: SkySpacing.x3) {
                        CaseStatusGlyph(status: status, size: 22).padding(.top, 1)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(SkyStrings.t(status.labelKey))
                                .font(SkyTypography.supporting.weight(.semibold))
                                .foregroundStyle(SkyColor.textPrimary)
                            Text(SkyStrings.t(status.meaningKey))
                                .font(SkyTypography.metadata).foregroundStyle(SkyColor.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .accessibilityElement(children: .combine)
                }
                Text(SkyStrings.t("trust.status.note"))
                    .font(SkyTypography.metadata).foregroundStyle(SkyColor.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var detailedPolicies: some View {
        EditorialSection(title: SkyStrings.t("trust.learnMore"), systemImage: "text.book.closed") {
            VStack(spacing: 0) {
                ForEach(policies) { page in
                    NavigationLink {
                        LegalPageView(page: page)
                    } label: {
                        HStack(spacing: SkySpacing.x3) {
                            Image(systemName: page.systemImage).frame(width: 24)
                                .foregroundStyle(SkyColor.accentSecondary)
                            Text(SkyStrings.t(page.titleKey))
                                .font(SkyTypography.supporting).foregroundStyle(SkyColor.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right").font(.caption)
                                .foregroundStyle(SkyColor.textTertiary)
                        }
                        .contentShape(Rectangle())
                        .padding(.vertical, SkySpacing.x3)
                    }
                    .buttonStyle(.plain)
                    if page != policies.last { Divider().overlay(SkyColor.separator) }
                }
            }
        }
    }
}

#Preview("Trust Center") {
    NavigationStack { TrustCenterView() }
        .environment(AppEnvironment.preview())
        .environment(AppSettings())
}
