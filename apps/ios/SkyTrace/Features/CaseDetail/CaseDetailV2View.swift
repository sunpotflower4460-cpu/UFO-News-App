import SwiftUI

/// V2 Case Detail — the strongest, most trustworthy screen. Renders the exact
/// 12-section hierarchy (docs/uiux 03 §7 / 09 §12) as editorial sections, not a
/// stack of generic cards. Atmosphere appears in the header only; the body is a
/// stable Editorial Surface. Reachable from the debug Design Gallery during V2
/// bring-up; the production tab wiring switches over once Today V2 lands.
struct CaseDetailV2View: View {
    let caseID: String
    @Environment(AppEnvironment.self) private var env
    @State private var model: CaseDetailViewModel?
    @State private var related: [RelatedCaseRef] = []
    @State private var allCases: [UAPCase] = []
    @State private var linkToOpen: IdentifiedURL?
    @State private var paywall: PaywallContext?

    var body: some View {
        Group {
            if let model, let c = model.state.value {
                content(model, c)
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
            allCases = (try? await env.caseRepository.allCases()) ?? []
            if let c = model?.state.value { related = c.relatedRefs(in: allCases) }
        }
        .sheet(item: $linkToOpen) { SafariView(url: $0.url) }
        .sheet(item: $paywall) { PaywallView(context: $0) }
    }

    private func content(_ model: CaseDetailViewModel, _ c: UAPCase) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SkySpacing.x8) {
                if c.isDemo { InlineBanner(kind: .demo) }
                header(model, c)                                   // 1
                EditorialSurface {
                    VStack(alignment: .leading, spacing: SkySpacing.x8) {
                        whatChanged(c)                             // 2
                        whatHappened(c)                            // 3
                        assessment(c)                              // 4
                        confirmedFacts(c)                          // 5
                        agreements(c)                              // 6
                        contradictions(c)                          // 7
                        evidence(c)                                // 8
                        explanations(c)                            // 9
                        timeline(c)                                // 10
                        sources(c)                                 // 11
                        relatedCases()                             // 12
                        aiDisclosure(model.article)
                    }
                }
            }
            .padding(.horizontal, SkySpacing.screenEdge)
            .padding(.vertical, SkySpacing.x4)
        }
        .toolbar { toolbar(model, c) }
    }

    // MARK: 1. Header (atmosphere allowed here only)

    private func header(_ model: CaseDetailViewModel, _ c: UAPCase) -> some View {
        VStack(alignment: .leading, spacing: SkySpacing.x3) {
            AtmosphereCanvas(dayFraction: 0.2, signals: [
                .init(x: 0.5, y: 0.45, color: c.v2Status.color, emphasized: true)
            ])
            .frame(height: 128)
            .clipShape(RoundedRectangle(cornerRadius: SkyRadius.hero))
            CaseStatusLabel(status: c.v2Status, showsUpdateIndicator: c.hasRecentUpdate)
            Text(c.title).font(SkyTypography.screenHero).foregroundStyle(SkyColor.textPrimary)
            HStack(spacing: SkySpacing.x2) {
                Image(systemName: "mappin.and.ellipse").imageScale(.small)
                Text(c.localityName ?? c.regionName)
                Text("·"); Text(SkyStrings.t(c.locationPrecision.labelKey))
            }
            .font(SkyTypography.metadata).foregroundStyle(SkyColor.textSecondary)
            HStack(spacing: SkySpacing.x4) {
                if let occurred = c.occurredAtStart {
                    timeChip(SkyStrings.t("label.occurred"), SkyFormat.dateOnly(occurred))
                }
                timeChip(SkyStrings.t("label.published"), SkyFormat.dateOnly(c.publishedAt))
                if let v = c.lastVerifiedAt {
                    timeChip(SkyStrings.t("label.lastVerified", "").trimmingCharacters(in: .whitespaces),
                             SkyFormat.dateOnly(v))
                }
            }
            ProvenanceRow(sourceCount: c.sourceCount, independentCount: c.independentReportCount)
        }
    }

    private func timeChip(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label).font(.caption2).foregroundStyle(SkyColor.textTertiary)
            Text(value).font(.caption.monospacedDigit()).foregroundStyle(SkyColor.textSecondary)
        }
    }

    // MARK: 2. What Changed

    @ViewBuilder private func whatChanged(_ c: UAPCase) -> some View {
        let changes = c.whatChanged
        if !changes.isEmpty {
            EditorialSection(title: SkyStrings.t("change.sectionTitle"),
                             systemImage: "sparkles", accent: SkyColor.signalWarm) {
                VStack(alignment: .leading, spacing: SkySpacing.x3) {
                    ForEach(changes) { CaseChangeRow(change: $0) }
                }
            }
        }
    }

    // MARK: 3. What Happened

    private func whatHappened(_ c: UAPCase) -> some View {
        EditorialSection(title: SkyStrings.t("case.whatHappened.v2"), systemImage: "text.alignleft") {
            VStack(alignment: .leading, spacing: SkySpacing.x3) {
                Text(c.summary).font(SkyTypography.body).foregroundStyle(SkyColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                if !c.currentAssessment.isEmpty {
                    Text(c.currentAssessment).font(SkyTypography.supporting)
                        .foregroundStyle(SkyColor.textSecondary).fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    // MARK: 4. Current Assessment

    private func assessment(_ c: UAPCase) -> some View {
        EditorialSection(title: SkyStrings.t("assess.sectionTitle"), systemImage: "gauge.with.dots.needle.50percent") {
            VStack(alignment: .leading, spacing: SkySpacing.x2) {
                ForEach(c.assessmentDimensions) { AssessmentDimensionRow(dimension: $0) }
            }
        }
    }

    // MARK: 5. Confirmed Facts

    @ViewBuilder private func confirmedFacts(_ c: UAPCase) -> some View {
        let facts = c.confirmedFacts
        if !facts.isEmpty {
            EditorialSection(title: SkyStrings.t("case.confirmedFacts"), systemImage: "checkmark.seal") {
                VStack(alignment: .leading, spacing: SkySpacing.x3) {
                    ForEach(facts) { FactStatementRow(fact: $0) }
                }
            }
        }
    }

    // MARK: 6/7. Agreement / Contradictions

    @ViewBuilder private func agreements(_ c: UAPCase) -> some View {
        if !c.agreements.isEmpty {
            EditorialSection(title: SkyStrings.t("evidence.agreements"), systemImage: "checkmark.circle") {
                bullets(c.agreements.map(\.text), role: .green)
            }
        }
    }
    @ViewBuilder private func contradictions(_ c: UAPCase) -> some View {
        if !c.contradictions.isEmpty {
            EditorialSection(title: SkyStrings.t("evidence.contradictions"), systemImage: "exclamationmark.triangle") {
                bullets(c.contradictions.map(\.text), role: .red)
            }
        }
    }

    // MARK: 8. Evidence (grouped by source type)

    @ViewBuilder private func evidence(_ c: UAPCase) -> some View {
        if !c.sources.isEmpty {
            EditorialSection(title: SkyStrings.t("case.evidence"), systemImage: "doc.on.doc") {
                let groups = Dictionary(grouping: c.sources, by: { $0.sourceType })
                VStack(alignment: .leading, spacing: SkySpacing.x3) {
                    ForEach(groups.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { type in
                        Text(SkyStrings.t(type.labelKey))
                            .font(.caption.weight(.semibold)).foregroundStyle(SkyColor.textTertiary)
                        ForEach(groups[type] ?? []) { s in
                            SourceRow(source: s) { url in linkToOpen = IdentifiedURL(url: url) }
                        }
                    }
                }
            }
        }
    }

    // MARK: 9. Explanations Considered

    @ViewBuilder private func explanations(_ c: UAPCase) -> some View {
        if !c.explanationCandidates.isEmpty {
            EditorialSection(title: SkyStrings.t("explanation.sectionTitle"), systemImage: "questionmark.diamond") {
                VStack(spacing: SkySpacing.x3) {
                    ForEach(c.explanationCandidates) { ExplanationCandidateCard(candidate: $0) }
                }
            }
        }
    }

    // MARK: 10. Timeline

    @ViewBuilder private func timeline(_ c: UAPCase) -> some View {
        if !c.timeline.isEmpty {
            EditorialSection(title: SkyStrings.t("case.timeline"), systemImage: "clock.arrow.circlepath") {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(c.timeline.enumerated()), id: \.element.id) { i, entry in
                        TimelineEntryView(entry: entry, isLast: i == c.timeline.count - 1)
                    }
                }
            }
        }
    }

    // MARK: 11. Sources

    private func sources(_ c: UAPCase) -> some View {
        EditorialSection(title: SkyStrings.t("sources.sectionTitle"), systemImage: "doc.text") {
            VStack(spacing: SkySpacing.x3) {
                ForEach(c.sources) { s in
                    SourceRow(source: s) { url in linkToOpen = IdentifiedURL(url: url) }
                }
            }
        }
    }

    // MARK: 12. Related Cases

    @ViewBuilder private func relatedCases() -> some View {
        if !related.isEmpty {
            EditorialSection(title: SkyStrings.t("related.sectionTitle"), systemImage: "square.stack.3d.up") {
                VStack(alignment: .leading, spacing: SkySpacing.x3) {
                    ForEach(related) { ref in
                        if let rc = allCases.first(where: { $0.id == ref.id }) {
                            HStack(spacing: SkySpacing.x3) {
                                CaseStatusGlyph(status: rc.v2Status, size: 20)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(rc.title).font(SkyTypography.supporting.weight(.medium))
                                        .foregroundStyle(SkyColor.textPrimary).lineLimit(2)
                                    Text(SkyStrings.t(ref.relation.labelKey))
                                        .font(.caption2).foregroundStyle(SkyColor.accentSecondary)
                                }
                                Spacer(minLength: 0)
                            }
                        }
                    }
                }
            }
        }
    }

    private func aiDisclosure(_ article: SynthesizedArticle?) -> some View {
        EditorialSection(title: SkyStrings.t("ai.sectionTitle"), systemImage: "sparkles") {
            VStack(alignment: .leading, spacing: SkySpacing.x3) {
                if let article {
                    NavigationLink { LongFormView(article: article) } label: {
                        HStack {
                            Label(SkyStrings.t("case.article"), systemImage: "doc.richtext")
                                .foregroundStyle(SkyColor.signalViolet)
                            Spacer()
                            AIDisclosureBadge(disclosure: article.disclosure)
                            Image(systemName: "chevron.right").foregroundStyle(SkyColor.textTertiary)
                        }
                        .font(SkyTypography.supporting.weight(.semibold))
                        .padding(SkySpacing.x3)
                        .background(SkyColor.signalViolet.opacity(0.10),
                                    in: RoundedRectangle(cornerRadius: SkyRadius.chip))
                    }
                    .buttonStyle(.plain)
                }
                Text(SkyStrings.t("ai.disclosureNote"))
                    .font(SkyTypography.supporting).foregroundStyle(SkyColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: Helpers

    private func bullets(_ items: [String], role: SignalRole) -> some View {
        VStack(alignment: .leading, spacing: SkySpacing.x2) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: SkySpacing.x2) {
                    Image(systemName: "circle.fill").font(.system(size: 5))
                        .foregroundStyle(SkyColor.signal(role)).padding(.top, 6)
                    Text(item).font(SkyTypography.body).foregroundStyle(SkyColor.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
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
            ShareLink(item: c.title) { Image(systemName: "square.and.arrow.up") }
        }
    }
}

#Preview("Case Detail V2") {
    NavigationStack { CaseDetailV2View(caseID: DemoCases.northSeaNotable.id) }
        .environment(AppEnvironment.preview())
        .environment(AppSettings())
}
