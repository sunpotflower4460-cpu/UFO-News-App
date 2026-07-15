import SwiftUI
import MapKit

/// V2 Map (docs/uiux 03 §4): full-screen MapKit, semantic status-geometry
/// markers, clusters that show new/updated composition (not just a number),
/// uncertain-location rings, quick filters, and a persistent bottom sheet with
/// three detents that doubles as the list (map/list parity). Reachable from the
/// debug Design Gallery during bring-up; existing Map tab is untouched.
struct MapV2View: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(AppRouter.self) private var router
    @Environment(DataRefreshController.self) private var refresh
    @State private var model: MapViewModel?
    @State private var camera: MapCameraPosition = .region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 25, longitude: 15),
                           span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 200)))
    @State private var selected: UAPCase?
    @State private var showSheet = true
    @State private var sheetDetent: PresentationDetent = .height(120)

    var body: some View {
        mapLayer
            .overlay(alignment: .top) {
                VStack(spacing: SkySpacing.x2) {
                    filterBar
                    if let model, model.loadFailed {
                        InlineBanner(kind: .offline) { Task { await model.load() } }
                            .padding(.horizontal, SkySpacing.screenEdge)
                    }
                }
            }
            .background(SkyColor.canvas)
            .navigationTitle(SkyStrings.t("map.title"))
            .navigationBarTitleDisplayMode(.inline)
            .task(id: refresh.generation) {
                if model == nil { model = MapViewModel(caseRepo: env.caseRepository) }
                await model?.load()
                focusRequestedCase()
            }
            .onChange(of: router.mapFocusCaseID) { _, _ in focusRequestedCase() }
            .sheet(isPresented: $showSheet) { bottomSheet }
    }

    /// Consume a cross-tab focus request (e.g. "View on map" from Case Detail):
    /// select the case, centre the camera on it, raise the sheet, then clear the
    /// request so it fires once. No-op until the cases have loaded.
    private func focusRequestedCase() {
        guard let id = router.mapFocusCaseID,
              let model, let c = model.allCases.first(where: { $0.id == id }) else { return }
        selected = c
        withAnimation {
            camera = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: c.latitude, longitude: c.longitude),
                span: MKCoordinateSpan(latitudeDelta: 8, longitudeDelta: 8)))
        }
        sheetDetent = .medium
        router.mapFocusCaseID = nil
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
                // Select → raise the sheet and scroll the list to this case.
                selected = cluster.cases.first
                sheetDetent = .medium
            }
        } label: {
            if cluster.isCluster {
                let updated = cluster.cases.filter(\.hasRecentUpdate).count
                // Count in a legible style; "has updates" shown as a warm ring
                // dot rather than 7pt text (Dynamic-Type safe).
                Text("\(cluster.cases.count)")
                    .font(.caption.weight(.bold)).foregroundStyle(SkyColor.canvas)
                    .padding(7)
                    .background(SkyColor.accentPrimary, in: Circle())
                    .overlay(Circle().strokeBorder(.white.opacity(0.7), lineWidth: 1))
                    .overlay(alignment: .topTrailing) {
                        if updated > 0 {
                            Circle().fill(SkyColor.signalWarm)
                                .frame(width: 10, height: 10)
                                .overlay(Circle().strokeBorder(SkyColor.canvas, lineWidth: 1.5))
                                .offset(x: 3, y: -3)
                        }
                    }
            } else {
                CaseStatusGlyph(status: cluster.cases.first?.v2Status ?? .underReview, size: 22,
                                showsUpdateIndicator: cluster.cases.first?.hasRecentUpdate ?? false)
                    .padding(5)
                    .background(SkyColor.surfacePrimary.opacity(0.9), in: Circle())
                    .overlay(Circle().strokeBorder(SkyColor.borderSubtle, lineWidth: 1))
            }
        }
        .accessibilityLabel(clusterA11yLabel(cluster))
    }

    private func annotationTitle(_ cluster: MapCluster) -> String {
        cluster.isCluster ? SkyStrings.t("map.results", String(cluster.cases.count))
                          : (cluster.cases.first?.title ?? "")
    }

    private func clusterA11yLabel(_ cluster: MapCluster) -> String {
        guard cluster.isCluster else { return cluster.cases.first?.title ?? "" }
        let updated = cluster.cases.filter(\.hasRecentUpdate).count
        var label = SkyStrings.t("map.results", String(cluster.cases.count))
        if updated > 0 { label += "、" + SkyStrings.t("label.updatedCount", String(updated)) }
        return label
    }

    /// Zoom to fit all member points (with padding) rather than a fixed span.
    private func region(around cluster: MapCluster) -> MKCoordinateRegion {
        let coords = cluster.cases.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }
        guard let first = coords.first else {
            return MKCoordinateRegion(center: cluster.coordinate,
                                      span: MKCoordinateSpan(latitudeDelta: 12, longitudeDelta: 12))
        }
        var minLat = first.latitude, maxLat = first.latitude
        var minLon = first.longitude, maxLon = first.longitude
        for c in coords {
            minLat = min(minLat, c.latitude); maxLat = max(maxLat, c.latitude)
            minLon = min(minLon, c.longitude); maxLon = max(maxLon, c.longitude)
        }
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                            longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: max((maxLat - minLat) * 1.6, 2),
                                    longitudeDelta: max((maxLon - minLon) * 1.6, 2))
        return MKCoordinateRegion(center: center, span: span)
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
                    ForEach(presentStatuses) { status in
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
                    ScrollViewReader { proxy in
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
                                .id("selected")
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
                        .refreshable { await model.load() }
                        .navigationTitle(SkyStrings.t("map.altList"))
                        .navigationBarTitleDisplayMode(.inline)
                        .onChange(of: selected?.id) { _, id in
                            guard id != nil else { return }
                            withAnimation { proxy.scrollTo("selected", anchor: .top) }
                        }
                    }
                }
            }
        }
        .presentationDetents([.height(120), .medium, .large], selection: $sheetDetent)
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

    /// Only the statuses that actually occur in the loaded cases, in the V2
    /// vocabulary order — so no filter chip is a dead no-op.
    private var presentStatuses: [SkyCaseStatus] {
        guard let model else { return [] }
        let present = Set(model.allCases.map { SkyCaseStatus($0.status) })
        return SkyCaseStatus.allCases.filter { present.contains($0) }
    }
}

#Preview("Map V2") {
    NavigationStack { MapV2View() }
        .environment(AppEnvironment.preview()).environment(AppSettings()).environment(AppRouter())
        .environment(DataRefreshController())
}
