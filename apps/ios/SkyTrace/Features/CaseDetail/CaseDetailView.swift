import SwiftUI

struct CaseDetailView: View {
    let caseID: String
    @Environment(AppEnvironment.self) private var env
    @State private var model: CaseDetailViewModel?
    @State private var scoreSheet: ScoreAxis.Kind?
    @State private var linkToOpen: IdentifiedURL?
    @State private var paywall: PaywallContext?

    var body: some View {
        Group {
            if let model, let uapCase = model.state.value {
                detail(model, uapCase)
            } else if let model, case .failed = model.state {
                ErrorStateView { Task { await model.load() } }
            } else {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(SkyColor.canvas)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if model == nil {
                model = CaseDetailViewModel(caseID: caseID, caseRepo: env.caseRepository, library: env.library)
            }
            await model?.load()
        }
        .sheet(item: $scoreSheet.map()) { kind in
            if let scores = model?.state.value?.scores {
                ScoreExplanationSheet(kind: kind.value, value: value(for: kind.value, scores),
                                      algorithmVersion: scores.algorithmVersion)
                    .presentationDetents([.medium])
            }
        }
        .sheet(item: $linkToOpen) { SafariView(url: $0.url) }
        .sheet(item: $paywall) { PaywallView(context: $0) }
    }

    private func detail(_ model: CaseDetailViewModel, _ c: UAPCase) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SkySpacing.x5) {
                if c.isDemo { InlineBanner(kind: .demo) }
                hero(c)
                section(SkyStrings.t("case.summary")) {
                    Text(c.summary).font(SkyTypography.body).foregroundStyle(SkyColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                scores(c)
                if !c.currentAssessment.isEmpty {
                    section(SkyStrings.t("case.assessment")) {
                        Text(c.currentAssessment).font(SkyTypography.body)
                            .foregroundStyle(SkyColor.textPrimary).fixedSize(horizontal: false, vertical: true)
                    }
                }
                EvidenceSection(title: SkyStrings.t("evidence.agreements"), systemImage: "checkmark.circle",
                                role: .green, items: c.agreements.map(\.text))
                EvidenceSection(title: SkyStrings.t("evidence.contradictions"), systemImage: "exclamationmark.triangle",
                                role: .red, items: c.contradictions.map(\.text))
                explanations(c)
                articleSection(model, c)
                EvidenceSection(title: SkyStrings.t("evidence.missing"), systemImage: "questionmark.circle",
                                role: .amber, items: c.missingInformation.map(\.text))
                EvidenceSection(title: SkyStrings.t("evidence.needed"), systemImage: "list.bullet.clipboard",
                                role: .cyan, items: c.neededEvidence.map(\.text))
                timeline(c)
                sources(c)
                aiSection(c)
            }
            .padding(.horizontal, SkySpacing.screenEdge)
            .padding(.vertical, SkySpacing.x4)
            .readingWidth()
        }
        .toolbar { toolbar(model, c) }
    }

    // MARK: Hero

    private func hero(_ c: UAPCase) -> some View {
        VStack(alignment: .leading, spacing: SkySpacing.x3) {
            ObservationGlyph(seed: abs(c.id.hashValue) % 100)
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: SkyRadius.hero))
            HStack { StatusBadge(status: c.status); if c.hasRecentUpdate { UpdateBadge() } }
            Text(c.title).font(SkyTypography.screenHero).foregroundStyle(SkyColor.textPrimary)
            HStack(spacing: SkySpacing.x2) {
                Image(systemName: "mappin.and.ellipse").imageScale(.small)
                Text(c.localityName ?? c.regionName)
                Text("·")
                Text(SkyStrings.t(c.locationPrecision.labelKey))
            }
            .font(SkyTypography.metadata).foregroundStyle(SkyColor.textSecondary)
            timeGrid(c)
        }
    }

    private func timeGrid(_ c: UAPCase) -> some View {
        VStack(alignment: .leading, spacing: SkySpacing.x1) {
            if let occurred = c.occurredAtStart {
                timeRow(SkyStrings.t("label.occurred"), SkyFormat.dateTime(occurred, zone: c.timeZone))
            }
            timeRow(SkyStrings.t("label.published"), SkyFormat.dateTime(c.publishedAt))
            if let verified = c.lastVerifiedAt {
                timeRow(SkyStrings.t("label.lastVerified", "").trimmingCharacters(in: .whitespaces),
                        SkyFormat.dateTime(verified))
            }
        }
        .padding(SkySpacing.x3)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SkyColor.surfaceSecondary, in: RoundedRectangle(cornerRadius: SkyRadius.chip))
    }

    private func timeRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.caption).foregroundStyle(SkyColor.textTertiary)
            Spacer()
            Text(value).font(.caption.monospacedDigit()).foregroundStyle(SkyColor.textSecondary)
        }
    }

    // MARK: Sections

    private func scores(_ c: UAPCase) -> some View {
        section(SkyStrings.t("score.sectionTitle")) {
            ScoreQuadrant(scores: c.scores) { kind in scoreSheet = kind }
        }
    }

    @ViewBuilder
    private func explanations(_ c: UAPCase) -> some View {
        if !c.explanationCandidates.isEmpty {
            section(SkyStrings.t("explanation.sectionTitle")) {
                VStack(spacing: SkySpacing.x3) {
                    ForEach(c.explanationCandidates) { ExplanationCandidateCard(candidate: $0) }
                }
            }
        }
    }

    @ViewBuilder
    private func articleSection(_ model: CaseDetailViewModel, _ c: UAPCase) -> some View {
        if let article = model.article {
            section(SkyStrings.t("case.article")) {
                VStack(alignment: .leading, spacing: SkySpacing.x3) {
                    AIDisclosureBadge(disclosure: article.disclosure)
                    Text(article.headline).font(SkyTypography.cardHeadline).foregroundStyle(SkyColor.textPrimary)
                    Text(article.dek).font(SkyTypography.supporting).foregroundStyle(SkyColor.textSecondary)
                    let freeBlocks = article.blocks.filter { !$0.isPremiumGated }
                    let gatedBlocks = article.blocks.filter { $0.isPremiumGated }
                    ForEach(freeBlocks) { ArticleBlockView(block: $0) }

                    if env.subscription.isPlus {
                        ForEach(gatedBlocks) { ArticleBlockView(block: $0) }
                        if let note = article.correctionNote {
                            Text(note).font(.caption).foregroundStyle(SkyColor.signalAmber)
                        }
                    } else if !gatedBlocks.isEmpty {
                        PremiumLockView(
                            title: SkyStrings.t("premium.locked.title"),
                            unlocks: [SkyStrings.t("paywall.feature.synthesis"),
                                      SkyStrings.t("paywall.feature.evidence")],
                            ctaTitle: SkyStrings.t("paywall.cta"),
                            onUnlock: { paywall = PaywallContext(trigger: .synthesis) }
                        )
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func timeline(_ c: UAPCase) -> some View {
        if !c.timeline.isEmpty {
            section(SkyStrings.t("case.timeline")) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(c.timeline.enumerated()), id: \.element.id) { i, entry in
                        TimelineEntryView(entry: entry, isLast: i == c.timeline.count - 1)
                    }
                }
                .cardSurface()
            }
        }
    }

    @ViewBuilder
    private func sources(_ c: UAPCase) -> some View {
        if !c.sources.isEmpty {
            section(SkyStrings.t("sources.sectionTitle")) {
                VStack(spacing: SkySpacing.x3) {
                    ForEach(c.sources) { source in
                        SourceRow(source: source) { url in linkToOpen = IdentifiedURL(url: url) }
                    }
                }
                .cardSurface()
            }
        }
    }

    private func aiSection(_ c: UAPCase) -> some View {
        VStack(alignment: .leading, spacing: SkySpacing.x2) {
            SectionHeader(title: SkyStrings.t("ai.sectionTitle"), systemImage: "info.circle")
            Text(SkyStrings.t("ai.disclosureNote"))
                .font(SkyTypography.supporting).foregroundStyle(SkyColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            NavigationLink { LegalPageView(page: .ai) } label: {
                Label(SkyStrings.t("legal.ai"), systemImage: "chevron.right")
                    .font(SkyTypography.metadata).foregroundStyle(SkyColor.signalCyan)
            }
        }
        .cardSurface()
    }

    @ToolbarContentBuilder
    private func toolbar(_ model: CaseDetailViewModel, _ c: UAPCase) -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button { Task { await model.toggleBookmark() } } label: {
                Image(systemName: model.isBookmarked ? "bookmark.fill" : "bookmark")
            }
            .accessibilityLabel(SkyStrings.t(model.isBookmarked ? "action.bookmarked" : "action.bookmark"))
        }
        ToolbarItem(placement: .primaryAction) {
            ShareLink(item: shareText(c)) { Image(systemName: "square.and.arrow.up") }
                .accessibilityLabel(SkyStrings.t("action.share"))
        }
    }

    // MARK: Helpers

    private func section<Content: View>(_ title: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: SkySpacing.x3) {
            SectionHeader(title: title)
            content()
        }
    }

    private func value(for kind: ScoreAxis.Kind, _ scores: CaseScores) -> Int {
        switch kind {
        case .evidenceQuality: scores.evidenceQuality
        case .independence: scores.independence
        case .knownPhenomenaMatch: scores.knownPhenomenaMatch
        case .unresolvedness: scores.unresolvedness
        }
    }

    private func shareText(_ c: UAPCase) -> String {
        SkyStrings.t("share.caseText", c.regionName, c.title)
    }
}

/// Helper to present a non-Identifiable enum via `.sheet(item:)`.
private struct IdentifiableKind: Identifiable { let value: ScoreAxis.Kind; var id: String { value.rawValue } }
private extension Binding where Value == ScoreAxis.Kind? {
    func map() -> Binding<IdentifiableKind?> {
        Binding<IdentifiableKind?>(
            get: { wrappedValue.map { IdentifiableKind(value: $0) } },
            set: { wrappedValue = $0?.value }
        )
    }
}

#Preview("Case · Free") {
    NavigationStack { CaseDetailView(caseID: DemoCases.northSeaNotable.id) }
        .environment(AppEnvironment.preview(entitlement: .free))
        .environment(AppSettings())
}
#Preview("Case · Plus") {
    NavigationStack { CaseDetailView(caseID: DemoCases.northSeaNotable.id) }
        .environment(AppEnvironment.preview(entitlement: .active(expiresAt: nil)))
        .environment(AppSettings())
}
