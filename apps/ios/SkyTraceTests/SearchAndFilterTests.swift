import XCTest
@testable import SkyTrace

final class SearchAndFilterTests: XCTestCase {

    func testTextSearchMatchesTitleAndRegion() {
        let hits = CaseSearch.run(query: "東京", filters: .none, in: DemoCases.all)
        XCTAssertTrue(hits.contains { $0.id == DemoCases.tokyoAircraft.id })
    }

    func testEmptyQueryReturnsAll() {
        let hits = CaseSearch.run(query: "  ", filters: .none, in: DemoCases.all)
        XCTAssertEqual(hits.count, DemoCases.all.count)
    }

    func testStatusFilter() {
        var f = CaseFilter(); f.statuses = [.withdrawn]
        let hits = CaseSearch.run(query: "", filters: f, in: DemoCases.all)
        XCTAssertTrue(hits.allSatisfy { $0.status == .withdrawn })
        XCTAssertEqual(hits.count, 1)
    }

    func testUnresolvednessThreshold() {
        var f = CaseFilter(); f.minUnresolvedness = 60
        let hits = CaseSearch.run(query: "", filters: f, in: DemoCases.all)
        XCTAssertTrue(hits.allSatisfy { $0.scores.unresolvedness >= 60 })
    }

    func testUpdatesOnlyFilter() {
        var f = CaseFilter(); f.withUpdatesOnly = true
        let hits = CaseSearch.run(query: "", filters: f, in: DemoCases.all)
        XCTAssertTrue(hits.allSatisfy(\.hasRecentUpdate))
    }

    func testNoResultsForNonsense() {
        let hits = CaseSearch.run(query: "zzzznotathing", filters: .none, in: DemoCases.all)
        XCTAssertTrue(hits.isEmpty)
    }
}
