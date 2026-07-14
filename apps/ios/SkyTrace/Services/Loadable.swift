import Foundation

/// Generic async view state. Keeps a cached value so a refresh failure can still
/// show the last good data (never a hard crash / blank screen).
enum Loadable<Value: Sendable>: Sendable {
    case idle
    case loading
    case loaded(Value)
    case partial(Value)
    case failed(RepositoryError, cached: Value?)

    var value: Value? {
        switch self {
        case .loaded(let v), .partial(let v): v
        case .failed(_, let cached): cached
        default: nil
        }
    }

    var isLoading: Bool { if case .loading = self { true } else { false } }
    var isPartial: Bool { if case .partial = self { true } else { false } }

    var error: RepositoryError? {
        if case .failed(let e, _) = self { e } else { nil }
    }
}
