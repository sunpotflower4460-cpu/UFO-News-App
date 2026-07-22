import XCTest
@testable import SkyTrace

final class SearchAndFilterTests: XCTestCase {

    func testTextSearchMatchesTitleAndRegion() {
        let hits = CaseSearch.run(query: "東京", filters: .none, in: DemoCases.all,
                                  now: FixtureClock.today)
        XCTAssertTrue(hits.contains { $0.id == DemoCases.tokyoAircraft.id })
    }

    func testEmptyQueryReturnsAll() {
        let hits = CaseSearch.run(query: "  ", filters: .none, in: DemoCases.all,
                                  now: FixtureClock.today)
        XCTAssertEqual(hits.count, DemoCases.all.count)
    }

    func testStatusFilter() {
        var f = CaseFilter(); f.statuses = [.withdrawn]
        let hits = CaseSearch.run(query: "", filters: f, in: DemoCases.all,
                                  now: FixtureClock.today)
        XCTAssertTrue(hits.allSatisfy { $0.status == .withdrawn })
        XCTAssertEqual(hits.count, 1)
    }

    func testUnresolvednessThreshold() {
        var f = CaseFilter(); f.minUnresolvedness = 60
        let hits = CaseSearch.run(query: "", filters: f, in: DemoCases.all,
                                  now: FixtureClock.today)
        XCTAssertTrue(hits.allSatisfy { $0.scores.unresolvedness >= 60 })
    }

    func testUpdatesOnlyFilter() {
        var f = CaseFilter(); f.withUpdatesOnly = true
        let hits = CaseSearch.run(query: "", filters: f, in: DemoCases.all,
                                  now: FixtureClock.today)
        XCTAssertTrue(hits.allSatisfy(\.hasRecentUpdate))
    }

    func testNoResultsForNonsense() {
        let hits = CaseSearch.run(query: "zzzznotathing", filters: .none, in: DemoCases.all,
                                  now: FixtureClock.today)
        XCTAssertTrue(hits.isEmpty)
    }

    func testDateWindowUsesInjectedCurrentDate() {
        var filter = CaseFilter(); filter.dateWindow = .past30d
        let fixtureHits = CaseSearch.run(query: "", filters: filter, in: DemoCases.all,
                                         now: FixtureClock.today)
        XCTAssertFalse(fixtureHits.isEmpty)

        let future = Calendar(identifier: .gregorian)
            .date(byAdding: .year, value: 1, to: FixtureClock.today)!
        let futureHits = CaseSearch.run(query: "", filters: filter, in: DemoCases.all,
                                        now: future)
        XCTAssertTrue(futureHits.isEmpty,
                      "Relative date filters must move with the supplied current date")
    }
}
