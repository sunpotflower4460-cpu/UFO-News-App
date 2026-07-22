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

    func testCloseZoomDoesNotClusterCasesHundredsOfKilometresApart() {
        var a = DemoCases.starlink
        var b = DemoCases.tokyoAircraft
        a.latitude = 0; a.longitude = 0
        b.latitude = 0; b.longitude = 1

        let clusters = MapClustering.clusters(from: [a, b], longitudeSpan: 0.1)
        XCTAssertEqual(clusters.count, 2,
                       "Street-level zoom must not keep a multi-degree clustering floor")
    }

    func testDatelineNeighboursClusterAroundDateline() {
        var east = DemoCases.starlink
        var west = DemoCases.tokyoAircraft
        east.latitude = 10; east.longitude = 179.5
        west.latitude = 10; west.longitude = -179.5

        let clusters = MapClustering.clusters(from: [east, west], longitudeSpan: 30)
        XCTAssertEqual(clusters.count, 1)
        XCTAssertGreaterThan(abs(clusters[0].coordinate.longitude), 170,
                             "Circular longitude averaging must not move the cluster to Greenwich")
    }

    @MainActor
    func testWithheldLocationsNeverReachMapClusters() async {
        var visible = DemoCases.starlink
        var withheld = DemoCases.tokyoAircraft
        visible.locationPrecision = .exact
        withheld.locationPrecision = .withheld
        let repo = ControlledCaseRepository(cases: [visible, withheld])
        let model = MapViewModel(caseRepo: repo)

        await model.load()

        XCTAssertEqual(model.plottableCases.map(\.id), [visible.id])
        XCTAssertEqual(model.clusters.flatMap(\.cases).map(\.id), [visible.id])
    }

    @MainActor
    func testNewestSearchWinsWhenOlderRepositoryCallFinishesLast() async {
        let repo = ControlledCaseRepository(cases: DemoCases.all, delaysByQuery: [
            "old": .milliseconds(120),
            "new": .milliseconds(5),
        ], ignoresCancellation: true)
        let library = LibraryStore(suiteName: "test.\(UUID().uuidString)")
        let model = ResearchViewModel(caseRepo: repo, library: library,
                                      now: { FixtureClock.today })

        model.query = "old"
        let oldTask = Task { await model.runSearch() }
        try? await Task.sleep(for: .milliseconds(15))
        model.query = "new"
        await model.runSearch()
        await oldTask.value

        XCTAssertEqual(model.results.map(\.id), [DemoCases.tokyoAircraft.id])
        XCTAssertFalse(model.isRunning)
    }
}

private actor ControlledCaseRepository: CaseRepository {
    let cases: [UAPCase]
    let delaysByQuery: [String: Duration]
    let ignoresCancellation: Bool

    init(cases: [UAPCase], delaysByQuery: [String: Duration] = [:],
         ignoresCancellation: Bool = false) {
        self.cases = cases
        self.delaysByQuery = delaysByQuery
        self.ignoresCancellation = ignoresCancellation
    }

    func allCases() async throws -> [UAPCase] { cases }

    func caseDetail(id: String) async throws -> UAPCase {
        guard let result = cases.first(where: { $0.id == id }) else {
            throw RepositoryError.notFound
        }
        return result
    }

    func article(for caseID: String) async throws -> SynthesizedArticle? { nil }

    func search(query: String, filters: CaseFilter) async throws -> [UAPCase] {
        if let delay = delaysByQuery[query] {
            if ignoresCancellation {
                try? await Task.sleep(for: delay)
            } else {
                try await Task.sleep(for: delay)
            }
        }
        switch query {
        case "old": return [DemoCases.starlink]
        case "new": return [DemoCases.tokyoAircraft]
        default: return CaseSearch.run(query: query, filters: filters, in: cases,
                                       now: FixtureClock.today)
        }
    }
}
