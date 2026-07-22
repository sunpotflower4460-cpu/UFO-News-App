import SwiftUI
import Observation
import MapKit

@MainActor
@Observable
final class MapViewModel {
    var allCases: [UAPCase] = []
    var filter = CaseFilter()
    var longitudeSpan: Double = 200
    var didLoad = false
    var loadFailed = false

    private let caseRepo: any CaseRepository
    init(caseRepo: any CaseRepository) { self.caseRepo = caseRepo }

    func load() async {
        do {
            let loaded = try await caseRepo.allCases()
            try Task.checkCancellation()
            allCases = loaded
            loadFailed = false
            didLoad = true
        } catch is CancellationError {
            // A superseded map load should leave the previous map intact.
            return
        } catch {
            loadFailed = true
            didLoad = true
        }
    }

    var filteredCases: [UAPCase] {
        CaseSearch.run(query: "", filters: filter, in: allCases)
    }

    var clusters: [MapCluster] {
        // Never pass withheld coordinates to the rendering/clustering layer.
        MapClustering.clusters(from: plottableCases, longitudeSpan: longitudeSpan)
    }

    /// Cases with a plottable (non-withheld) location.
    var plottableCases: [UAPCase] {
        filteredCases.filter { $0.locationPrecision != .withheld }
    }
}
