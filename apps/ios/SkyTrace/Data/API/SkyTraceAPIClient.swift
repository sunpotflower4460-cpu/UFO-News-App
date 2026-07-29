import Foundation

/// Errors the API client can raise. `ProductionFeedRepository` etc. map these
/// onto the app-wide `RepositoryError` so Case Detail/Today never need to know
/// whether they're reading from fixtures or a live backend.
enum APIClientError: Error, Sendable, Equatable {
    case offline
    case notFound
    case decoding
    case server(status: Int, code: String)
    case notConfigured
}

/// URLSession-backed client for `docs/openapi/skytrace-v1.yaml`
/// (directive §9 API Client必須要件): timeout, ETag/If-None-Match, exponential
/// backoff, cancellation, request ID, locale header, and no silent fixture
/// fallback — every failure is surfaced as a typed `APIClientError`, never
/// swallowed into demo data.
actor SkyTraceAPIClient {
    let baseURL: URL
    private let session: URLSession
    private var etagCache: [String: (etag: String, body: Data)] = [:]

    init(baseURL: URL, session: URLSession? = nil) {
        self.baseURL = baseURL
        if let session {
            self.session = session
        } else {
            let config = URLSessionConfiguration.ephemeral
            config.timeoutIntervalForRequest = 15
            config.timeoutIntervalForResource = 30
            self.session = URLSession(configuration: config)
        }
    }

    /// Fetches and decodes `APIEnvelope<T>` at `path`, retrying transient
    /// failures with exponential backoff. A cached ETag is sent automatically;
    /// a matching `304` returns the cached, still-valid body instead of a
    /// fresh network round trip.
    func get<T: Decodable>(_ path: String, maxRetries: Int = 3) async throws -> APIEnvelope<T> {
        var attempt = 0
        var lastError: Error = APIClientError.offline
        while attempt <= maxRetries {
            try Task.checkCancellation()
            do {
                return try await performRequest(path)
            } catch is CancellationError {
                throw CancellationError()
            } catch let error as APIClientError {
                // Only retry transient conditions — never retry a definitive
                // 404 or a decoding failure, which a retry cannot fix.
                guard Self.isRetryable(error), attempt < maxRetries else { throw error }
                lastError = error
            } catch {
                guard attempt < maxRetries else { throw error }
                lastError = error
            }
            attempt += 1
            let backoffSeconds = pow(2.0, Double(attempt - 1))
            try await Task.sleep(nanoseconds: UInt64(backoffSeconds * 1_000_000_000))
        }
        throw lastError
    }

    private static func isRetryable(_ error: APIClientError) -> Bool {
        switch error {
        case .offline: true
        case .server(let status, _): status >= 500
        case .notFound, .decoding, .notConfigured: false
        }
    }

    private func performRequest<T: Decodable>(_ path: String) async throws -> APIEnvelope<T> {
        guard let url = URL(string: path, relativeTo: baseURL) else { throw APIClientError.notConfigured }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(Locale.current.language.languageCode?.identifier ?? "ja", forHTTPHeaderField: "Accept-Language")
        request.setValue(UUID().uuidString, forHTTPHeaderField: "X-Request-Id")
        let cacheKey = url.absoluteString
        if let cached = etagCache[cacheKey] {
            request.setValue(cached.etag, forHTTPHeaderField: "If-None-Match")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw APIClientError.offline
        }
        try Task.checkCancellation()

        guard let http = response as? HTTPURLResponse else { throw APIClientError.offline }

        if http.statusCode == 304, let cached = etagCache[cacheKey] {
            return try Self.decode(cached.body)
        }
        if http.statusCode == 404 { throw APIClientError.notFound }
        guard 200...299 ~= http.statusCode else {
            let code = (try? Self.decodeError(data))?.code ?? "http_\(http.statusCode)"
            throw APIClientError.server(status: http.statusCode, code: code)
        }

        if let etag = http.value(forHTTPHeaderField: "ETag") {
            etagCache[cacheKey] = (etag, data)
        }
        return try Self.decode(data)
    }

    private static func decode<T: Decodable>(_ data: Data) throws -> APIEnvelope<T> {
        do {
            return try Self.jsonDecoder.decode(APIEnvelope<T>.self, from: data)
        } catch {
            throw APIClientError.decoding
        }
    }

    private static func decodeError(_ data: Data) throws -> APIErrorBody {
        try JSONDecoder().decode(APIErrorBody.self, from: data)
    }

    /// Accepts ISO 8601 timestamps both with and without fractional seconds —
    /// the mock server (and, so this client never needs a follow-up change,
    /// a real backend) may emit either depending on whether the instant was
    /// microsecond-precise.
    private static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let withFraction = ISO8601DateFormatter()
        withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let withoutFraction = ISO8601DateFormatter()
        withoutFraction.formatOptions = [.withInternetDateTime]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            if let date = withFraction.date(from: raw) ?? withoutFraction.date(from: raw) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unrecognised date: \(raw)")
        }
        return decoder
    }()
}
