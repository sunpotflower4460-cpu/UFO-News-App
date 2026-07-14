import SwiftUI

struct ResearchView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var model: ResearchViewModel?
    @State private var showFilters = false
    @State private var paywall: PaywallContext?

    var body: some View {
        NavigationStack {
            Group {
                if let model {
                    if model.isSearching { searchResults(model) } else { discover(model) }
                } else { Color.clear }
            }
            .background(SkyColor.canvas)
            .navigationTitle(SkyStrings.t("research.title"))
            .searchable(text: searchBinding, prompt: SkyStrings.t("research.searchPrompt"))
            .onSubmit(of: .search) { Task { await model?.runSearch() } }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showFilters = true } label: {
                        Image(systemName: model?.filter.isActive == true
                              ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    }
                    .accessibilityLabel(SkyStrings.t("research.filtersTitle"))
                }
            }
            .skyDestinations()
        }
        .task {
            if model == nil { model = ResearchViewModel(caseRepo: env.caseRepository, library: env.library) }
            await model?.load()
        }
        .sheet(isPresented: $showFilters) { if let model { FiltersSheet(model: model) } }
        .sheet(item: $paywall) { PaywallView(context: $0) }
    }

    private var searchBinding: Binding<String> {
        Binding(get: { model?.query ?? "" },
                set: { model?.query = $0; Task { await model?.runSearch() } })
    }

    // MARK: Discover

    private func discover(_ model: ResearchViewModel) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: SkySpacing.x5) {
                if !env.subscription.isPlus {
                    plusPromo
                }
                if !model.recentlyViewed.isEmpty {
                    carousel(SkyStrings.t("research.recent"), model.recentlyViewed)
                }
                if !model.updatedThisWeek.isEmpty {
                    listSection(SkyStrings.t("research.updatedThisWeek"), model.updatedThisWeek)
                }
                savedSection(model)
                listSection(SkyStrings.t("research.collections"), model.allCasesForCollections)
            }
            .padding(.horizontal, SkySpacing.screenEdge)
            .padding(.vertical, SkySpacing.x4)
        }
    }

    private var plusPromo: some View {
        Button { paywall = PaywallContext(trigger: .filters) } label: {
            HStack {
                Image(systemName: "sparkles").foregroundStyle(SkyColor.signalViolet)
                VStack(alignment: .leading) {
                    Text(SkyStrings.t("research.plusDeepDives"))
                        .font(SkyTypography.supporting.weight(.semibold)).foregroundStyle(SkyColor.textPrimary)
                    Text(SkyStrings.t("paywall.heroBody")).font(.caption2).foregroundStyle(SkyColor.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(SkyColor.textTertiary)
            }
            .cardSurface()
        }
        .buttonStyle(.plain)
    }

    private func carousel(_ title: String, _ items: [UAPCase]) -> some View {
        VStack(alignment: .leading, spacing: SkySpacing.x3) {
            SectionHeader(title: title, systemImage: "clock.arrow.circlepath")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SkySpacing.x3) {
                    ForEach(items) { c in
                        NavigationLink(value: CaseLink(id: c.id)) {
                            CaseCard(uapCase: c, variant: .standard).frame(width: 300)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func listSection(_ title: String, _ items: [UAPCase]) -> some View {
        VStack(alignment: .leading, spacing: SkySpacing.x3) {
            SectionHeader(title: title, systemImage: "square.stack.3d.up")
            ForEach(items) { c in
                NavigationLink(value: CaseLink(id: c.id)) { CaseCard(uapCase: c, variant: .compact) }
                    .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func savedSection(_ model: ResearchViewModel) -> some View {
        VStack(alignment: .leading, spacing: SkySpacing.x3) {
            SectionHeader(title: SkyStrings.t("research.saved"), systemImage: "bookmark")
            if model.saved.isEmpty {
                EmptyStateView(messageKey: "empty.saved", systemImage: "bookmark")
            } else {
                ForEach(model.saved) { c in
                    NavigationLink(value: CaseLink(id: c.id)) { CaseCard(uapCase: c, variant: .compact) }
                        .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: Results

    private func searchResults(_ model: ResearchViewModel) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: SkySpacing.x3) {
                HStack {
                    Text(SkyStrings.t("research.resultCount", String(model.results.count)))
                        .font(SkyTypography.metadata).foregroundStyle(SkyColor.textSecondary)
                    Spacer()
                    if model.filter.isActive {
                        Button(SkyStrings.t("research.clearFilters")) { model.clearFilters() }
                            .font(.caption).foregroundStyle(SkyColor.signalCyan)
                    }
                }
                if model.results.isEmpty {
                    EmptyStateView(messageKey: "empty.search", systemImage: "magnifyingglass")
                } else {
                    ForEach(model.results) { c in
                        NavigationLink(value: CaseLink(id: c.id)) { CaseCard(uapCase: c, variant: .standard) }
                            .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, SkySpacing.screenEdge)
            .padding(.vertical, SkySpacing.x4)
        }
    }
}

private extension ResearchViewModel {
    var allCasesForCollections: [UAPCase] { results.isEmpty ? DemoCases.all : results }
}

/// Structured filter sheet shared with the Research hub.
struct FiltersSheet: View {
    @Bindable var model: ResearchViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(SkyStrings.t("map.filter.status")) {
                    ForEach(CaseStatus.allCases) { status in
                        Button {
                            if model.filter.statuses.contains(status) { model.filter.statuses.remove(status) }
                            else { model.filter.statuses.insert(status) }
                        } label: {
                            HStack {
                                Label(SkyStrings.t(status.labelKey), systemImage: status.systemImage)
                                    .foregroundStyle(SkyColor.textPrimary)
                                Spacer()
                                if model.filter.statuses.contains(status) {
                                    Image(systemName: "checkmark").foregroundStyle(SkyColor.signalCyan)
                                }
                            }
                        }
                    }
                }
                Section(SkyStrings.t("map.filter.period")) {
                    Picker(SkyStrings.t("map.filter.period"), selection: $model.filter.dateWindow) {
                        ForEach(CaseFilter.DateWindow.allCases) { Text(SkyStrings.t($0.labelKey)).tag($0) }
                    }.pickerStyle(.segmented)
                }
                Section {
                    Toggle(SkyStrings.t("filter.updatesOnly"), isOn: $model.filter.withUpdatesOnly)
                }
            }
            .scrollContentBackground(.hidden).background(SkyColor.canvas)
            .navigationTitle(SkyStrings.t("research.filtersTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(SkyStrings.t("research.clearFilters")) { model.clearFilters() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(SkyStrings.t("action.close")) { Task { await model.runSearch() }; dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview("Research") {
    ResearchView().environment(AppEnvironment.preview()).environment(AppSettings())
}
