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

    func testFailedPurchaseKeepsFree() async {
        let provider = FakeSubscriptionProvider(initial: .free, shouldFailPurchase: true)
        let store = await SubscriptionStore(provider: provider)
        let outcome = await store.purchase(SubscriptionIDs.monthly)
        if case .failed = outcome {} else { XCTFail("Expected failure") }
        let isPlus = await store.isPlus
        XCTAssertFalse(isPlus)
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

    func testEntitlementStatesUnlockCorrectly() {
        XCTAssertTrue(EntitlementState.active(expiresAt: nil).isPlusUnlocked)
        XCTAssertTrue(EntitlementState.gracePeriod(expiresAt: nil).isPlusUnlocked)
        XCTAssertTrue(EntitlementState.billingRetry.isPlusUnlocked)
        XCTAssertFalse(EntitlementState.expired.isPlusUnlocked)
        XCTAssertFalse(EntitlementState.revoked.isPlusUnlocked)
        XCTAssertFalse(EntitlementState.free.isPlusUnlocked)
    }

    func testGracePeriodDoesNotLockKnownAccess() {
        // Grace period must still show Plus (network/billing hiccup tolerance).
        XCTAssertTrue(EntitlementState.gracePeriod(expiresAt: nil).isPlusUnlocked)
    }
}
