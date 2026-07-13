import SwiftUI
import MapKit

struct MapView: View {
    @Environment(AppEnvironment.self) private var env
    @State private var model: MapViewModel?
    @State private var camera: MapCameraPosition = .region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 20, longitude: 20),
                           span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 200)))
    @State private var selected: UAPCase?
    @State private var clusterCases: [UAPCase] = []
    @State private var showMoreFilters = false
    @State private var showList = false
    @State private var paywall: PaywallContext?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                mapLayer
                filterBar
            }
            .background(SkyColor.canvas)
            .navigationTitle(SkyStrings.t("map.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showList = true } label: { Image(systemName: "list.bullet") }
                        .accessibilityLabel(SkyStrings.t("map.altList"))
                }
            }
            .skyDestinations()
        }
        .task {
            if model == nil { model = MapViewModel(caseRepo: env.caseRepository) }
            await model?.load()
        }
        .sheet(item: $selected) { c in caseSheet(c) }
        .sheet(isPresented: Binding(get: { !clusterCases.isEmpty }, set: { if !$0 { clusterCases = [] } })) {
            clusterSheet
        }
        .sheet(isPresented: $showMoreFilters) { moreFiltersSheet }
        .sheet(isPresented: $showList) { listSheet }
        .sheet(item: $paywall) { PaywallView(context: $0) }
    }

    // MARK: Map

    @ViewBuilder
    private var mapLayer: some View {
        if let model {
            MapReader { _ in
                Map(position: $camera) {
                    ForEach(model.clusters) { cluster in
                        Annotation(annotationTitle(cluster), coordinate: cluster.coordinate) {
                            pin(cluster)
                        }
                        if let radius = cluster.cases.first?.locationPrecision.uncertaintyRadiusMeters,
                           !cluster.isCluster {
                            MapCircle(center: cluster.coordinate, radius: radius)
                                .foregroundStyle(SkyColor.signal(cluster.status.signal).opacity(0.12))
                                .stroke(SkyColor.signal(cluster.status.signal).opacity(0.4), lineWidth: 1)
                        }
                    }
                }
                .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
                .onMapCameraChange { context in
                    model.longitudeSpan = context.region.span.longitudeDelta
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }

    private func pin(_ cluster: MapCluster) -> some View {
        Button {
            Haptics.selection()
            if cluster.isCluster { clusterCases = cluster.cases } else { selected = cluster.cases.first }
        } label: {
            ZStack {
                Circle().fill(SkyColor.signal(cluster.status.signal))
                    .frame(width: cluster.isCluster ? 34 : 24, height: cluster.isCluster ? 34 : 24)
                if cluster.isCluster {
                    Text("\(cluster.cases.count)").font(.caption.weight(.bold)).foregroundStyle(SkyColor.canvas)
                } else {
                    Image(systemName: cluster.status.systemImage).font(.caption2).foregroundStyle(SkyColor.canvas)
                }
            }
            .overlay(Circle().strokeBorder(.white.opacity(0.7), lineWidth: 1))
        }
        .accessibilityLabel(annotationTitle(cluster))
    }

    private func annotationTitle(_ cluster: MapCluster) -> String {
        cluster.isCluster ? "\(cluster.cases.count)" : (cluster.cases.first?.title ?? "")
    }

    // MARK: Filter bar

    @ViewBuilder
    private var filterBar: some View {
        if let model {
            @Bindable var m = model
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SkySpacing.x2) {
                    Menu {
                        Picker(SkyStrings.t("map.filter.period"), selection: $m.filter.dateWindow) {
                            ForEach(CaseFilter.DateWindow.allCases) { Text(SkyStrings.t($0.labelKey)).tag($0) }
                        }
                    } label: {
                        SkyChip(text: SkyStrings.t(model.filter.dateWindow.labelKey),
                                systemImage: "calendar", isSelected: model.filter.dateWindow != .anyTime)
                    }
                    ForEach(CaseStatus.allCases) { status in
                        Button {
                            toggleStatus(status, m)
                        } label: {
                            SkyChip(text: SkyStrings.t(status.labelKey), systemImage: status.systemImage,
                                    isSelected: model.filter.statuses.contains(status))
                        }
                    }
                    Button { showMoreFilters = true } label: {
                        SkyChip(text: SkyStrings.t("map.filter.more"), systemImage: "slider.horizontal.3",
                                isSelected: model.filter.minUnresolvedness > 0 || model.filter.withUpdatesOnly)
                    }
                }
                .padding(.horizontal, SkySpacing.screenEdge)
            }
            .padding(.vertical, SkySpacing.x2)
            .background(.ultraThinMaterial)
            .overlay(alignment: .bottom) {
                Text(SkyStrings.t("map.results", String(model.plottableCases.count)))
                    .font(.caption2).foregroundStyle(SkyColor.textSecondary)
                    .padding(4).background(.ultraThinMaterial, in: Capsule())
                    .offset(y: 22)
            }
        }
    }

    private func toggleStatus(_ status: CaseStatus, _ m: MapViewModel) {
        if m.filter.statuses.contains(status) { m.filter.statuses.remove(status) }
        else { m.filter.statuses.insert(status) }
        Haptics.selection()
    }

    // MARK: Sheets

    private func caseSheet(_ c: UAPCase) -> some View {
        NavigationStack {
            ScrollView {
                CaseCard(uapCase: c, variant: .mapSheet)
                    .padding(SkySpacing.x4)
                NavigationLink(value: CaseLink(id: c.id)) {
                    Text(SkyStrings.t("action.seeDetail")).frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent).tint(SkyColor.signalCyan)
                .padding(.horizontal, SkySpacing.x4)
            }
            .background(SkyColor.canvas)
            .skyDestinations()
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }

    private var clusterSheet: some View {
        NavigationStack {
            List(clusterCases) { c in
                NavigationLink(value: CaseLink(id: c.id)) { CaseCard(uapCase: c, variant: .compact) }
                    .listRowBackground(Color.clear).listRowSeparator(.hidden)
            }
            .listStyle(.plain).scrollContentBackground(.hidden).background(SkyColor.canvas)
            .navigationTitle("\(clusterCases.count)").navigationBarTitleDisplayMode(.inline)
            .skyDestinations()
        }
        .presentationDetents([.medium, .large])
    }

    @ViewBuilder
    private var moreFiltersSheet: some View {
        if let model {
            @Bindable var m = model
            NavigationStack {
                Form {
                    Section(SkyStrings.t("map.filter.unresolved")) {
                        VStack(alignment: .leading) {
                            Text("\(Int(m.filter.minUnresolvedness))+").font(.caption).monospacedDigit()
                            Slider(value: Binding(get: { Double(m.filter.minUnresolvedness) },
                                                  set: { m.filter.minUnresolvedness = Int($0) }),
                                   in: 0...100, step: 10)
                        }
                    }
                    Section {
                        Toggle(SkyStrings.t("filter.updatesOnly"), isOn: $m.filter.withUpdatesOnly)
                    }
                }
                .scrollContentBackground(.hidden).background(SkyColor.canvas)
                .navigationTitle(SkyStrings.t("map.filter.more"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) {
                    Button(SkyStrings.t("action.close")) { showMoreFilters = false } } }
            }
            .presentationDetents([.medium])
        }
    }

    private var listSheet: some View {
        NavigationStack {
            List(model?.plottableCases ?? []) { c in
                NavigationLink(value: CaseLink(id: c.id)) { CaseCard(uapCase: c, variant: .compact) }
                    .listRowBackground(Color.clear).listRowSeparator(.hidden)
            }
            .listStyle(.plain).scrollContentBackground(.hidden).background(SkyColor.canvas)
            .navigationTitle(SkyStrings.t("map.altList")).navigationBarTitleDisplayMode(.inline)
            .skyDestinations()
        }
    }
}

#Preview("Map") {
    MapView().environment(AppEnvironment.preview()).environment(AppSettings())
}
