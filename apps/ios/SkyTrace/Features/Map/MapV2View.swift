import SwiftUI
import MapKit

/// V2 Map (docs/uiux 03 §4): full-screen MapKit, semantic status-geometry
/// markers, clusters that show new/updated composition (not just a number),
/// uncertain-location rings, quick filters, and a persistent bottom sheet with
/// three detents that doubles as the list (map/list parity). Reachable from the
/// debug Design Gallery during bring-up; existing Map tab is untouched.
struct MapV2View: View {
    @Environment(AppEnvironment.self) private var env
    @State private var model: MapViewModel?
    @State private var camera: MapCameraPosition = .region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 25, longitude: 15),
                           span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 200)))
    @State private var selected: UAPCase?
    @State private var showSheet = true

    var body: some View {
        mapLayer
            .overlay(alignment: .top) { filterBar }
            .background(SkyColor.canvas)
            .navigationTitle(SkyStrings.t("map.title"))
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if model == nil { model = MapViewModel(caseRepo: env.caseRepository) }
                await model?.load()
            }
            .sheet(isPresented: $showSheet) { bottomSheet }
    }

    @ViewBuilder private var mapLayer: some View {
        if let model {
            Map(position: $camera) {
                ForEach(model.clusters) { cluster in
                    Annotation(annotationTitle(cluster), coordinate: cluster.coordinate) {
                        marker(cluster)
                    }
                    if !cluster.isCluster,
                       let c = cluster.cases.first,
                       let radius = c.locationPrecision.uncertaintyRadiusMeters {
                        MapCircle(center: cluster.coordinate, radius: radius)
                            .foregroundStyle(c.v2Status.color.opacity(0.10))
                            .stroke(c.v2Status.color.opacity(0.4), lineWidth: 1)
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
            .onMapCameraChange { ctx in model.longitudeSpan = ctx.region.span.longitudeDelta }
            .ignoresSafeArea(edges: .bottom)
        }
    }

    private func marker(_ cluster: MapCluster) -> some View {
        Button {
            Haptics.selection()
            if cluster.isCluster {
                withAnimation { camera = .region(region(around: cluster)) }
            } else {
                selected = cluster.cases.first
            }
        } label: {
            if cluster.isCluster {
                let newCount = cluster.cases.filter { $0.v2Status == .newReport }.count
                let updated = cluster.cases.filter(\.hasRecentUpdate).count
                VStack(spacing: 0) {
                    Text("\(cluster.cases.count)").font(.caption.weight(.bold)).foregroundStyle(SkyColor.canvas)
                    if newCount + updated > 0 {
                        Text("新\(newCount)・更\(updated)").font(.system(size: 7)).foregroundStyle(SkyColor.canvas)
                    }
                }
                .padding(6)
                .background(SkyColor.accentPrimary, in: Circle())
                .overlay(Circle().strokeBorder(.white.opacity(0.7), lineWidth: 1))
            } else {
                CaseStatusGlyph(status: cluster.cases.first?.v2Status ?? .underReview, size: 22,
                                showsUpdateIndicator: cluster.cases.first?.hasRecentUpdate ?? false)
                    .padding(5)
                    .background(SkyColor.surfacePrimary.opacity(0.9), in: Circle())
                    .overlay(Circle().strokeBorder(SkyColor.borderSubtle, lineWidth: 1))
            }
        }
        .accessibilityLabel(annotationTitle(cluster))
    }

    private func annotationTitle(_ cluster: MapCluster) -> String {
        cluster.isCluster ? SkyStrings.t("map.results", String(cluster.cases.count))
                          : (cluster.cases.first?.title ?? "")
    }

    private func region(around cluster: MapCluster) -> MKCoordinateRegion {
        MKCoordinateRegion(center: cluster.coordinate,
                           span: MKCoordinateSpan(latitudeDelta: 12, longitudeDelta: 12))
    }

    @ViewBuilder private var filterBar: some View {
        if let model {
            @Bindable var m = model
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SkySpacing.x2) {
                    Menu {
                        Picker(SkyStrings.t("map.filter.period"), selection: $m.filter.dateWindow) {
                            ForEach(CaseFilter.DateWindow.allCases) { Text(SkyStrings.t($0.labelKey)).tag($0) }
                        }
                    } label: {
                        SkyChip(text: SkyStrings.t(model.filter.dateWindow.labelKey), systemImage: "calendar",
                                isSelected: model.filter.dateWindow != .anyTime)
                    }
                    ForEach(SkyCaseStatus.allCases) { status in
                        Button { toggle(status, m) } label: {
                            HStack(spacing: 4) {
                                CaseStatusGlyph(status: status, size: 13)
                                Text(SkyStrings.t(status.labelKey)).font(SkyTypography.metadata)
                            }
                            .padding(.horizontal, SkySpacing.x3).padding(.vertical, SkySpacing.x2)
                            .background(isOn(status, model) ? status.color.opacity(0.22) : SkyColor.surfaceInteractive,
                                        in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, SkySpacing.screenEdge)
            }
            .padding(.vertical, SkySpacing.x2)
            .background(.ultraThinMaterial)
        }
    }

    private var bottomSheet: some View {
        NavigationStack {
            Group {
                if let model {
                    List {
                        if let selected {
                            Section {
                                CaseCard(uapCase: selected, variant: .mapSheet)
                                    .listRowBackground(Color.clear).listRowSeparator(.hidden)
                                NavigationLink { CaseDetailV2View(caseID: selected.id) } label: {
                                    Text(SkyStrings.t("action.seeDetail")).foregroundStyle(SkyColor.accentPrimary)
                                }
                                .listRowBackground(SkyColor.surfaceSecondary)
                            }
                        }
                        Section {
                            ForEach(model.plottableCases) { c in
                                NavigationLink { CaseDetailV2View(caseID: c.id) } label: {
                                    CaseCard(uapCase: c, variant: .compact)
                                }
                                .listRowBackground(Color.clear).listRowSeparator(.hidden)
                            }
                        } header: {
                            Text(SkyStrings.t("map.results", String(model.plottableCases.count)))
                        }
                    }
                    .listStyle(.plain).scrollContentBackground(.hidden).background(SkyColor.canvas)
                    .navigationTitle(SkyStrings.t("map.altList"))
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        .presentationDetents([.height(120), .medium, .large])
        .presentationBackgroundInteraction(.enabled(upThrough: .medium))
        .interactiveDismissDisabled()
    }

    private func toggle(_ s: SkyCaseStatus, _ m: MapViewModel) {
        // Map V2 status → legacy statuses that render as it, so filtering works
        // against the current fixture model.
        let legacy = CaseStatus.allCases.filter { SkyCaseStatus($0) == s }
        let anyOn = legacy.contains { m.filter.statuses.contains($0) }
        for l in legacy { if anyOn { m.filter.statuses.remove(l) } else { m.filter.statuses.insert(l) } }
        Haptics.selection()
    }
    private func isOn(_ s: SkyCaseStatus, _ m: MapViewModel) -> Bool {
        CaseStatus.allCases.contains { SkyCaseStatus($0) == s && m.filter.statuses.contains($0) }
    }
}

#Preview("Map V2") {
    NavigationStack { MapV2View() }
        .environment(AppEnvironment.preview()).environment(AppSettings())
}
