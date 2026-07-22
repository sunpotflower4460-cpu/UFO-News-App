import XCTest
@testable import SkyTrace

final class SubscriptionTests: XCTestCase {

    func testPurchaseUnlocksPlus() async {
        let provider = FakeSubscriptionProvider(initial: .free)
        let store = await SubscriptionStore(provider: provider)
        await store.refresh()
        let before = await store.isPlus
        XCTAssertFalse(before)

        _ = await store.purchase(SubscriptionIDs.monthly)
        let after = await store.isPlus
        XCTAssertTrue(after)
    }

    func testFailedPurchaseKeepsFreeAndShowsError() async {
        let provider = FakeSubscriptionProvider(initial: .free, shouldFailPurchase: true)
        let store = await SubscriptionStore(provider: provider)
        let outcome = await store.purchase(SubscriptionIDs.monthly)
        if case .failed = outcome {} else { XCTFail("Expected failure") }
        let isPlus = await store.isPlus
        let message = await store.lastMessageKey
        XCTAssertFalse(isPlus)
        XCTAssertEqual(message, "state.error.body")
    }

    func testPendingPurchaseSetsMessage() async {
        let provider = FakeSubscriptionProvider(initial: .free, purchaseIsPending: true)
        let store = await SubscriptionStore(provider: provider)
        let outcome = await store.purchase(SubscriptionIDs.yearly)
        XCTAssertEqual(outcome, .pending)
        let key = await store.lastMessageKey
        XCTAssertEqual(key, "paywall.pending")
    }

    func testRestoreReflectsProviderState() async {
        let provider = FakeSubscriptionProvider(initial: .active(expiresAt: nil))
        let store = await SubscriptionStore(provider: provider)
        await store.restore()
        let isPlus = await store.isPlus
        XCTAssertTrue(isPlus)
    }

    func testUnknownRestoreShowsRetryableErrorInsteadOfNothingToRestore() async {
        let provider = SequencedSubscriptionProvider(states: [.unknown])
        let store = await SubscriptionStore(provider: provider)
        await store.restore()
        let key = await store.lastMessageKey
        XCTAssertEqual(key, "state.error.body")
    }

    func testEmptyProductLoadExposesRetryState() async {
        let provider = SequencedSubscriptionProvider(states: [.free])
        let store = await SubscriptionStore(provider: provider)
        await store.loadProductsIfNeeded()
        let failed = await store.productLoadFailed
        let loading = await store.isLoadingProducts
        XCTAssertTrue(failed)
        XCTAssertFalse(loading)
    }

    func testEntitlementStatesUnlockCorrectly() {
        XCTAssertTrue(EntitlementState.active(expiresAt: nil).isPlusUnlocked)
        XCTAssertTrue(EntitlementState.gracePeriod(expiresAt: nil).isPlusUnlocked)
        XCTAssertFalse(EntitlementState.billingRetry.isPlusUnlocked,
                       "Billing retry without grace is not entitled to service")
        XCTAssertFalse(EntitlementState.expired.isPlusUnlocked)
        XCTAssertFalse(EntitlementState.revoked.isPlusUnlocked)
        XCTAssertFalse(EntitlementState.free.isPlusUnlocked)
    }

    func testGracePeriodDoesNotLockKnownAccess() {
        XCTAssertTrue(EntitlementState.gracePeriod(expiresAt: nil).isPlusUnlocked)
    }

    func testTransientUnknownDoesNotEraseKnownActiveEntitlement() async {
        let provider = SequencedSubscriptionProvider(states: [
            .active(expiresAt: nil),
            .unknown,
        ])
        let store = await SubscriptionStore(provider: provider)

        await store.refresh()
        let firstRead = await store.isPlus
        XCTAssertTrue(firstRead)

        await store.refresh()
        let secondRead = await store.isPlus
        XCTAssertTrue(secondRead,
                      "A transient unknown StoreKit read must preserve known access")
    }

    func testNewestConcurrentRefreshWinsAcrossRepeatedInterleavings() async {
        for iteration in 0..<10 {
            let provider = DelayedSubscriptionProvider(responses: [
                (.free, .milliseconds(80 + iteration * 3)),
                (.active(expiresAt: nil), .milliseconds(2)),
            ])
            let store = await SubscriptionStore(provider: provider)

            async let older: Void = store.refresh()
            try? await Task.sleep(for: .milliseconds(10))
            async let newer: Void = store.refresh()
            _ = await (older, newer)

            let finalState = await store.entitlement
            XCTAssertTrue(finalState.isPlusUnlocked,
                          "The newest refresh must win even when an older call finishes last")
            let refreshing = await store.isRefreshing
            XCTAssertFalse(refreshing)
        }
    }

    func testSuccessfulPurchaseCannotBeOverwrittenByOlderFreeRefresh() async {
        let provider = PurchaseRaceProvider()
        let store = await SubscriptionStore(provider: provider)

        async let staleRefresh: Void = store.refresh()
        try? await Task.sleep(for: .milliseconds(10))
        let outcome = await store.purchase(SubscriptionIDs.monthly)
        await staleRefresh

        XCTAssertEqual(outcome, .success)
        let finalState = await store.entitlement
        XCTAssertTrue(finalState.isPlusUnlocked,
                      "A pre-purchase free read must not relock newly purchased access")
    }

    func testRapidDuplicatePurchaseInvokesProviderOnlyOnce() async {
        let provider = CountingPurchaseProvider()
        let store = await SubscriptionStore(provider: provider)

        async let first = store.purchase(SubscriptionIDs.monthly)
        try? await Task.sleep(for: .milliseconds(10))
        let duplicate = await store.purchase(SubscriptionIDs.monthly)
        let original = await first

        XCTAssertEqual(original, .userCancelled)
        XCTAssertEqual(duplicate, .pending)
        let calls = await provider.purchaseCount
        XCTAssertEqual(calls, 1)
    }
}

private actor PurchaseRaceProvider: SubscriptionProviding {
    private var entitlementReads = 0

    nonisolated var manageSubscriptionsURL: URL? { nil }
    func loadProducts() async -> [SubscriptionProduct] { [] }
    func purchase(productID: String) async -> PurchaseOutcome { .success }
    func restore() async -> EntitlementState { .unknown }
    func currentEntitlement() async -> EntitlementState {
        entitlementReads += 1
        if entitlementReads == 1 {
            try? await Task.sleep(for: .milliseconds(100))
            return .free
        }
        try? await Task.sleep(for: .milliseconds(2))
        return .active(expiresAt: nil)
    }
}

private actor CountingPurchaseProvider: SubscriptionProviding {
    private(set) var purchaseCount = 0

    nonisolated var manageSubscriptionsURL: URL? { nil }
    func loadProducts() async -> [SubscriptionProduct] { [] }
    func purchase(productID: String) async -> PurchaseOutcome {
        purchaseCount += 1
        try? await Task.sleep(for: .milliseconds(80))
        return .userCancelled
    }
    func restore() async -> EntitlementState { .unknown }
    func currentEntitlement() async -> EntitlementState { .free }
}

private actor DelayedSubscriptionProvider: SubscriptionProviding {
    private var responses: [(EntitlementState, Duration)]

    init(responses: [(EntitlementState, Duration)]) { self.responses = responses }

    nonisolated var manageSubscriptionsURL: URL? { nil }
    func loadProducts() async -> [SubscriptionProduct] { [] }
    func purchase(productID: String) async -> PurchaseOutcome { .userCancelled }
    func restore() async -> EntitlementState { .unknown }
    func currentEntitlement() async -> EntitlementState {
        guard !responses.isEmpty else { return .unknown }
        let (state, delay) = responses.removeFirst()
        try? await Task.sleep(for: delay)
        return state
    }
}

private actor SequencedSubscriptionProvider: SubscriptionProviding {
    private var states: [EntitlementState]

    init(states: [EntitlementState]) { self.states = states }

    nonisolated var manageSubscriptionsURL: URL? { nil }
    func loadProducts() async -> [SubscriptionProduct] { [] }
    func purchase(productID: String) async -> PurchaseOutcome { .userCancelled }
    func restore() async -> EntitlementState { await currentEntitlement() }
    func currentEntitlement() async -> EntitlementState {
        guard !states.isEmpty else { return .unknown }
        return states.removeFirst()
    }
}
