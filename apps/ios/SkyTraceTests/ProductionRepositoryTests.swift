import XCTest
@testable import SkyTrace

/// Verifies the Phase 2 production seam end to end: `AppEnvironment` only
/// switches away from `UnconfiguredCaseRepository` when an explicit
/// `apiBaseURL` is set, `SkyTraceAPIClient` decodes the v1 envelope + ETag/304
/// correctly, and `APIMapping` produces a valid `UAPCase` from the wire DTOs.
final class ProductionRepositoryTests: XCTestCase {

    // MARK: AppEnvironment wiring

    @MainActor
    func testLocalAPIWithNoBaseURLStaysUnconfigured() async {
        let env = AppEnvironment(
            dataSource: .localAPI,
            subscription: SubscriptionStore(provider: FakeSubscriptionProvider()),
            library: LibraryStore(suiteName: "test.\(UUID().uuidString)")
        )
        do {
            _ = try await env.caseRepository.allCases()
            XCTFail("Must stay unconfigured until apiBaseURL is set")
        } catch let error as RepositoryError {
            XCTAssertEqual(error, .unknown("production_data_source_not_configured"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    /// The Premium SNS feed must obey the exact same "never fall back to
    /// fixtures" rule as every other repository — a reader must never see
    /// demo social posts relabelled as live ones just because the API host
    /// is unset.
    @MainActor
    func testSocialReportsRepositoryStaysUnconfiguredWithNoBaseURL() async {
        let env = AppEnvironment(
            dataSource: .localAPI,
            subscription: SubscriptionStore(provider: FakeSubscriptionProvider()),
            library: LibraryStore(suiteName: "test.\(UUID().uuidString)")
        )
        do {
            _ = try await env.socialReportsRepository.socialReports()
            XCTFail("Must stay unconfigured until apiBaseURL is set")
        } catch let error as RepositoryError {
            XCTAssertEqual(error, .unknown("production_data_source_not_configured"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    @MainActor
    func testSettingAPIBaseURLSwitchesAwayFromUnconfigured() async throws {
        // `AppEnvironment` builds its own client internally, so this proves
        // the *wiring* (an unreachable host must fail some other way than the
        // "not configured" sentinel) — decoding/mapping correctness against a
        // real payload is covered by the stub-backed tests below.
        let env = AppEnvironment(
            dataSource: .localAPI,
            apiBaseURL: URL(string: "https://stub.invalid"),
            subscription: SubscriptionStore(provider: FakeSubscriptionProvider()),
            library: LibraryStore(suiteName: "test.\(UUID().uuidString)")
        )
        do {
            _ = try await env.caseRepository.allCases()
        } catch let error as RepositoryError {
            XCTAssertNotEqual(error, .unknown("production_data_source_not_configured"),
                              "Setting apiBaseURL must switch away from the Unconfigured repository")
        } catch {
            // A network-layer throw (not RepositoryError) also proves it
            // attempted a real request rather than returning the sentinel.
        }
    }

    func testProductionCaseRepositoryDecodesAndMapsAListOfCases() async throws {
        StubURLProtocol.stub(path: "/v1/cases") { _ in
            (200, ["ETag": "\"abc\""], Self.caseListEnvelopeJSON)
        }
        let client = SkyTraceAPIClient(baseURL: URL(string: "https://stub.invalid")!, session: Self.stubSession)
        let cases = try await ProductionCaseRepository(client: client).allCases()
        XCTAssertEqual(cases.first?.id, "case_demo_001")
    }

    func testProductionSocialReportsRepositoryDecodesAndMapsWithNoScoreField() async throws {
        StubURLProtocol.stub(path: "/v1/social/reports") { _ in
            (200, ["ETag": "\"s1\""], Self.socialReportEnvelopeJSON)
        }
        let client = SkyTraceAPIClient(baseURL: URL(string: "https://stub.invalid")!, session: Self.stubSession)
        let reports = try await ProductionSocialReportsRepository(client: client).socialReports()
        let report = try XCTUnwrap(reports.first)
        XCTAssertEqual(report.source.sourceType, .social)
        XCTAssertEqual(report.caseTitle, "アタカマ砂漠で観測された整列する光の列")
        XCTAssertEqual(report.caseShapeTags, ["光点", "整列"])
        // Structural guard mirroring the Python contract test: the mapped
        // Swift type must not have grown a score/likelihood field either.
        let mirror = Mirror(reflecting: report)
        XCTAssertEqual(Set(mirror.children.compactMap(\.label)),
                       ["id", "caseID", "caseTitle", "caseStatus", "source", "media", "caseShapeTags", "isDemo"])
    }

    // MARK: SkyTraceAPIClient

    func testClientDecodesEnvelopeAndMapsToDomainCase() async throws {
        StubURLProtocol.stub(path: "/v1/cases/case_demo_001") { _ in
            (200, ["ETag": "\"case-1\""], Self.singleCaseEnvelopeJSON)
        }
        let client = SkyTraceAPIClient(baseURL: URL(string: "https://stub.invalid")!, session: Self.stubSession)
        let envelope: APIEnvelope<APICase> = try await client.get("/v1/cases/case_demo_001")
        XCTAssertEqual(envelope.schemaVersion, "1.0.0")
        let mapped = APIMapping.uapCase(envelope.data)
        XCTAssertEqual(mapped.id, "case_demo_001")
        XCTAssertTrue(mapped.isDemo)
        XCTAssertEqual(mapped.sources.first?.outletName, "Demo Official Records Office")
    }

    func testClientHonoursIfNoneMatchAndReturnsCachedBodyOn304() async throws {
        var requestCount = 0
        StubURLProtocol.stub(path: "/v1/cases/case_demo_001") { request in
            requestCount += 1
            if request.value(forHTTPHeaderField: "If-None-Match") == "\"case-1\"" {
                return (304, [:], Data())
            }
            return (200, ["ETag": "\"case-1\""], Self.singleCaseEnvelopeJSON)
        }
        let client = SkyTraceAPIClient(baseURL: URL(string: "https://stub.invalid")!, session: Self.stubSession)
        let first: APIEnvelope<APICase> = try await client.get("/v1/cases/case_demo_001")
        let second: APIEnvelope<APICase> = try await client.get("/v1/cases/case_demo_001")
        XCTAssertEqual(first.data.id, second.data.id, "A 304 must resolve to the same previously-cached body")
        XCTAssertEqual(requestCount, 2, "Both requests must reach the network — 304 is a revalidation, not a skip")
    }

    func test404DoesNotRetryAndSurfacesNotFound() async throws {
        var attempts = 0
        StubURLProtocol.stub(path: "/v1/cases/missing") { _ in
            attempts += 1
            return (404, [:], #"{"code":"case_not_found","message":"case_not_found","requestId":"r1"}"#.data(using: .utf8)!)
        }
        let client = SkyTraceAPIClient(baseURL: URL(string: "https://stub.invalid")!, session: Self.stubSession)
        do {
            let _: APIEnvelope<APICase> = try await client.get("/v1/cases/missing")
            XCTFail("Expected notFound")
        } catch APIClientError.notFound {
            XCTAssertEqual(attempts, 1, "A definitive 404 must not be retried")
        } catch {
            XCTFail("Expected APIClientError.notFound, got \(error)")
        }
    }

    // MARK: Fixtures

    private static let stubSession: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        return URLSession(configuration: config)
    }()

    private static let singleCaseEnvelopeJSON: Data = """
    {
      "schemaVersion": "1.0.0", "generatedAt": "2026-07-29T08:16:22.907102Z",
      "retrievedAt": "2026-07-29T08:16:22.907102Z", "verifiedAt": null,
      "contentRevision": 1, "sourceRevision": 1, "rightsState": "approved",
      "locale": "ja", "cacheTTL": 30,
      "data": \(caseJSON)
    }
    """.data(using: .utf8)!

    private static let caseListEnvelopeJSON: Data = """
    {
      "schemaVersion": "1.0.0", "generatedAt": "2026-07-29T08:16:22.907102Z",
      "retrievedAt": "2026-07-29T08:16:22.907102Z", "verifiedAt": null,
      "contentRevision": 1, "sourceRevision": 1, "rightsState": "approved",
      "locale": "ja", "cacheTTL": 30,
      "data": [\(caseJSON)]
    }
    """.data(using: .utf8)!

    private static let socialReportEnvelopeJSON: Data = """
    {
      "schemaVersion": "1.0.0", "generatedAt": "2026-07-29T08:16:22.907102Z",
      "retrievedAt": "2026-07-29T08:16:22.907102Z", "verifiedAt": null,
      "contentRevision": 1, "sourceRevision": 1, "rightsState": "approved",
      "locale": "ja", "cacheTTL": 300,
      "data": [{
        "id": "case_demo_001_src_social_1", "caseId": "case_demo_001",
        "caseTitle": "アタカマ砂漠で観測された整列する光の列", "caseStatus": "explained",
        "caseShapeTags": ["光点", "整列"],
        "source": {
          "id": "src_social_1", "outletName": "Demo Social Platform user", "sourceType": "social",
          "title": "夜空の光点を撮影したという投稿", "publishedAt": "2026-07-13T22:40:00Z",
          "retrievedAt": "2026-07-13T22:40:00Z", "role": "contextualizes",
          "url": "https://example.org/social/post-1"
        },
        "media": [{
          "id": "media_3", "kind": "video", "rightsState": "pending", "displayPermission": "link_only",
          "sourcePageURL": "https://example.org/social/post-1", "mediaURL": null, "thumbnailURL": null,
          "attributionText": "Demo Social Platform user post", "licenseNote": null
        }],
        "isDemo": true
      }]
    }
    """.data(using: .utf8)!

    private static let caseJSON = """
    {
      "id": "case_demo_001", "slug": "demo-satellite-pass",
      "title": "アタカマ砂漠で観測された整列する光の列",
      "summary": "複数の観測者が光点の列を報告。",
      "occurredAtStart": "2026-07-13T22:40:00Z",
      "publishedAt": "2026-07-13T22:40:00Z", "updatedAt": "2026-07-13T22:40:00Z",
      "lastVerifiedAt": "2026-07-13T22:40:00Z",
      "locationPrecision": "approximate", "latitude": -23.65, "longitude": -70.4,
      "countryCode": "CL", "regionName": "アントファガスタ州", "localityName": "アタカマ砂漠",
      "status": "explained", "sourceCount": 1, "independentReportCount": 1, "isDemo": true,
      "sources": [{
        "id": "src_1", "outletName": "Demo Official Records Office", "sourceType": "official",
        "title": "夜間可視衛星パスの記録", "publishedAt": "2026-07-13T22:40:00Z",
        "retrievedAt": "2026-07-13T22:40:00Z", "role": "supports", "url": "https://example.org/records/pass-1"
      }],
      "media": []
    }
    """
}

/// Minimal `URLProtocol` stub — intercepts requests whose path matches and
/// returns a canned (status, headers, body); a request to an unregistered
/// path fails loudly instead of hitting the real network.
final class StubURLProtocol: URLProtocol {
    typealias Handler = (URLRequest) -> (Int, [String: String], Data)
    private static var handlers: [String: Handler] = [:]

    static func stub(path: String, _ handler: @escaping Handler) {
        handlers[path] = handler
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let path = request.url?.path, let handler = Self.handlers[path] else {
            client?.urlProtocol(self, didFailWithError: URLError(.unsupportedURL))
            return
        }
        let (status, headers, body) = handler(request)
        let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: "HTTP/1.1", headerFields: headers)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
