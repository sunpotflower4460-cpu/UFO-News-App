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
