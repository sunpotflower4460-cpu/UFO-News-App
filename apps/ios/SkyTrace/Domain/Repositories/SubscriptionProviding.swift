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
    /// Current entitlement, recomputed from current transactions.
    func currentEntitlement() async -> EntitlementState
    /// URL to Apple's manage-subscriptions surface, if available.
    var manageSubscriptionsURL: URL? { get }
}
