import Foundation
import MapKit

/// A rendered map item: either a single case or a proximity cluster. SwiftUI's
/// `Map` doesn't cluster on its own, so we group by screen-space proximity that
/// scales with the current zoom (longitude span).
struct MapCluster: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let cases: [UAPCase]
    var isCluster: Bool { cases.count > 1 }
    /// The dominant status colour for the pin.
    var status: CaseStatus { cases.first?.status ?? .underReview }
}

enum MapClustering {
    /// Groups cases whose coordinates fall within a zoom-dependent threshold.
    static func clusters(from cases: [UAPCase], longitudeSpan: Double) -> [MapCluster] {
        // Threshold shrinks as you zoom in (smaller span → less grouping).
        let threshold = max(2.0, longitudeSpan * 0.12)
        var groups: [[UAPCase]] = []

        for c in cases {
            if let idx = groups.firstIndex(where: { group in
                guard let anchor = group.first else { return false }
                return distanceDegrees(anchor.coordinate, c.coordinate) < threshold
            }) {
                groups[idx].append(c)
            } else {
                groups.append([c])
            }
        }

        return groups.map { group in
            let lat = group.map(\.latitude).reduce(0, +) / Double(group.count)
            let lon = group.map(\.longitude).reduce(0, +) / Double(group.count)
            let id = group.map(\.id).sorted().joined(separator: "|")
            return MapCluster(id: id, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), cases: group)
        }
    }

    private static func distanceDegrees(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> Double {
        let dLat = a.latitude - b.latitude
        let dLon = a.longitude - b.longitude
        return (dLat * dLat + dLon * dLon).squareRoot()
    }
}
