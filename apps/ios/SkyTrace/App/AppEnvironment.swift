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
        self.feedRepository = FixtureFeedRepository()
        self.caseRepository = FixtureCaseRepository()
        self.briefingRepository = FixtureBriefingRepository()
        self.subscription = subscription ?? SubscriptionStore(provider: StoreKitSubscriptionService())
    }

    private func rebuildRepositories() {
        switch dataSource {
        case .fixture:
            feedRepository = FixtureFeedRepository()
            caseRepository = FixtureCaseRepository()
            briefingRepository = FixtureBriefingRepository()
        case .localAPI:
            // Phase 2 wires a URLSession-backed client here. Until then, fall
            // back to fixtures so the toggle never yields an empty app.
            feedRepository = FixtureFeedRepository()
            caseRepository = FixtureCaseRepository()
            briefingRepository = FixtureBriefingRepository()
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
