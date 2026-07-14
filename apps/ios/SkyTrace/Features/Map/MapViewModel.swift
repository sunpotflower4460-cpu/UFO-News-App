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
            allCases = try await caseRepo.allCases()
            loadFailed = false
        } catch {
            loadFailed = true
        }
        didLoad = true
    }

    var filteredCases: [UAPCase] {
        CaseSearch.run(query: "", filters: filter, in: allCases)
    }

    var clusters: [MapCluster] {
        MapClustering.clusters(from: filteredCases, longitudeSpan: longitudeSpan)
    }

    /// Cases with a plottable (non-withheld) location.
    var plottableCases: [UAPCase] {
        filteredCases.filter { $0.locationPrecision != .withheld }
    }
}
