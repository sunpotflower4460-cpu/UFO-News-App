import Foundation

/// Abstraction over the subscription backend (StoreKit 2 in production, a local
/// fake in previews/tests). Views never touch StoreKit directly.
protocol SubscriptionProviding: Sendable {
    /// Current products available for purchase.
    func loadProducts() async -> [SubscriptionProduct]
    /// Attempt a purchase for the given product id.
    func purchase(productID: String) async -> PurchaseOutcome
    /// Restore prior purchases (AppStore.sync equivalent).
    func restore() async -> EntitlementState
    /// Current entitlement, recomputed from current transactions/statuses.
    func currentEntitlement() async -> EntitlementState
    /// Observe transactions created or updated while the app is alive. Providers
    /// without a live transaction stream (previews/tests) may return nil.
    func observeTransactionUpdates(
        _ onChange: @escaping @Sendable (EntitlementState) -> Void
    ) -> Task<Void, Never>?
    /// URL to Apple's manage-subscriptions surface, if available.
    var manageSubscriptionsURL: URL? { get }
}

extension SubscriptionProviding {
    func observeTransactionUpdates(
        _ onChange: @escaping @Sendable (EntitlementState) -> Void
    ) -> Task<Void, Never>? { nil }
}
