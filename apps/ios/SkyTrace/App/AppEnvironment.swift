import SwiftUI
import Observation

/// The dependency container. Holds repositories + services and can rebuild them
/// when the Debug data-source toggle changes. Injected via the SwiftUI
/// environment so features never construct their own dependencies.
@MainActor
@Observable
final class AppEnvironment {
    private(set) var feedRepository: any FeedRepository
    private(set) var caseRepository: any CaseRepository
    private(set) var briefingRepository: any BriefingRepository
    let library: LibraryStore
    let subscription: SubscriptionStore
    var flags: FeatureFlags
    var dataSource: DataSourceMode {
        didSet { rebuildRepositories() }
    }

    init(dataSource: DataSourceMode = .fixture,
         flags: FeatureFlags = .releaseDefaults,
         subscription: SubscriptionStore? = nil,
         library: LibraryStore = LibraryStore()) {
        self.dataSource = dataSource
        self.flags = flags
        self.library = library
        // Initialise stored existential properties before applying the selected
        // source below. They are never exposed before init completes.
        self.feedRepository = FixtureFeedRepository()
        self.caseRepository = FixtureCaseRepository()
        self.briefingRepository = FixtureBriefingRepository()
        self.subscription = subscription ?? SubscriptionStore(provider: StoreKitSubscriptionService())
        rebuildRepositories()
    }

    private func rebuildRepositories() {
        switch dataSource {
        case .fixture:
            feedRepository = FixtureFeedRepository()
            caseRepository = FixtureCaseRepository()
            briefingRepository = FixtureBriefingRepository()
        case .localAPI:
            // Production must never silently fall back to demo cases. Until the
            // URLSession-backed repositories are connected, expose an explicit
            // unavailable state so a Release build cannot masquerade as live news.
            feedRepository = UnconfiguredFeedRepository()
            caseRepository = UnconfiguredCaseRepository()
            briefingRepository = UnconfiguredBriefingRepository()
        }
    }

    // MARK: Previews / tests

    /// A fully in-memory environment for SwiftUI previews and unit tests.
    static func preview(entitlement: EntitlementState = .free) -> AppEnvironment {
        let sub = SubscriptionStore(provider: FakeSubscriptionProvider(initial: entitlement))
        let env = AppEnvironment(
            dataSource: .fixture,
            flags: FeatureFlags(),
            subscription: sub,
            library: LibraryStore(suiteName: "preview")
        )
        return env
    }
}

// MARK: - Release-safe production placeholders

/// These repositories deliberately fail instead of serving fixtures. They are a
/// compile-safe seam for the Phase 2 URLSession repositories and a guard against
/// publishing fabricated/demo information as current news.
private struct UnconfiguredFeedRepository: FeedRepository {
    func todayFeed() async throws -> TodayFeed { throw notConfigured }
}

private struct UnconfiguredCaseRepository: CaseRepository {
    func allCases() async throws -> [UAPCase] { throw notConfigured }
    func caseDetail(id: String) async throws -> UAPCase { throw notConfigured }
    func article(for caseID: String) async throws -> SynthesizedArticle? { throw notConfigured }
    func search(query: String, filters: CaseFilter) async throws -> [UAPCase] { throw notConfigured }
}

private struct UnconfiguredBriefingRepository: BriefingRepository {
    func briefing(for date: Date) async throws -> DailyBriefing { throw notConfigured }
}

private let notConfigured = RepositoryError.unknown("production_data_source_not_configured")
