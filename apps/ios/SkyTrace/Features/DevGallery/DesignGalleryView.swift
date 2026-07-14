import SwiftUI

/// Debug-only gallery of the Aether Editorial System: tokens, status geometry,
/// atmosphere, editorial surfaces. Reached from Settings ▸ Developer (DEBUG).
/// Never shipped in Release (gated by `FeatureFlags.showsDeveloperTools`).
struct DesignGalleryView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SkySpacing.x8) {
                NavigationLink {
                    TodayV2View()
                } label: {
                    Label("Today V2 (World Sky Pulse)", systemImage: "sun.max")
                        .font(SkyTypography.cardHeadline).foregroundStyle(SkyColor.accentPrimary)
                }
                NavigationLink {
                    MapV2View()
                } label: {
                    Label("Map V2 (markers, clusters, list parity)", systemImage: "map")
                        .font(SkyTypography.cardHeadline).foregroundStyle(SkyColor.accentPrimary)
                }
                NavigationLink {
                    CaseDetailV2View(caseID: DemoCases.northSeaNotable.id)
                } label: {
                    Label("Case Detail V2 (12 sections)", systemImage: "doc.richtext")
                        .font(SkyTypography.cardHeadline).foregroundStyle(SkyColor.accentPrimary)
                }
                atmosphere
                statuses
                assessment
                swatches
                editorial
            }
            .padding(SkySpacing.x4)
        }
        .background(SkyColor.canvas)
        .navigationTitle("Design Gallery")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var atmosphere: some View {
        EditorialSection(title: "AtmosphereCanvas", systemImage: "sparkles") {
            AtmosphereCanvas(dayFraction: 0.25, signals: [
                .init(x: 0.18, y: 0.25, color: SkyColor.statusNew, emphasized: true),
                .init(x: 0.5, y: 0.55, color: SkyColor.statusReview),
                .init(x: 0.82, y: 0.35, color: SkyColor.statusDisputed),
            ])
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: SkyRadius.hero))
        }
    }

    private var statuses: some View {
        EditorialSection(title: "Status geometry (8)", systemImage: "circle.grid.2x2") {
            VStack(alignment: .leading, spacing: SkySpacing.x3) {
                ForEach(SkyCaseStatus.allCases) { s in
                    HStack(spacing: SkySpacing.x4) {
                        CaseStatusGlyph(status: s, size: 28)
                        CaseStatusLabel(status: s, showsUpdateIndicator: s == .corrected)
                        Spacer()
                    }
                }
            }
        }
    }

    private var assessment: some View {
        let c = DemoCases.northSeaNotable
        return EditorialSection(title: "Assessment / Changes / Facts", systemImage: "list.bullet.rectangle") {
            VStack(alignment: .leading, spacing: SkySpacing.x4) {
                VStack(alignment: .leading, spacing: SkySpacing.x2) {
                    ForEach(c.assessmentDimensions.prefix(4)) { AssessmentDimensionRow(dimension: $0) }
                }
                if let change = c.whatChanged.first { CaseChangeRow(change: change) }
                if let fact = c.confirmedFacts.first { FactStatementRow(fact: fact) }
            }
        }
    }

    private var swatches: some View {
        EditorialSection(title: "Colour tokens", systemImage: "paintpalette") {
            let rows: [(String, Color)] = [
                ("atmosphereTop", SkyColor.atmosphereTop),
                ("surfacePrimary", SkyColor.surfacePrimary),
                ("surfaceElevated", SkyColor.surfaceElevated),
                ("accentPrimary", SkyColor.accentPrimary),
                ("accentSecondary", SkyColor.accentSecondary),
                ("signalWarm", SkyColor.signalWarm),
                ("success", SkyColor.success),
                ("warning", SkyColor.warning),
                ("error", SkyColor.error),
            ]
            VStack(spacing: SkySpacing.x2) {
                ForEach(rows, id: \.0) { name, color in
                    HStack {
                        RoundedRectangle(cornerRadius: 6).fill(color).frame(width: 40, height: 24)
                            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(SkyColor.separator))
                        Text(name).font(SkyTypography.supporting).foregroundStyle(SkyColor.textSecondary)
                        Spacer()
                    }
                }
            }
        }
    }

    private var editorial: some View {
        EditorialSection(title: "EditorialSurface", systemImage: "text.alignleft") {
            EditorialSurface {
                Text("編集面は安定した背景と読みやすい文字幅を持ち、本文を画像やガラスの上に置きません。操作はガラス、理解は紙面、世界は大気。")
                    .font(SkyTypography.body)
                    .foregroundStyle(SkyColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    NavigationStack { DesignGalleryView() }
}
