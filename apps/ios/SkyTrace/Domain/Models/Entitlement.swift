import Foundation

/// User entitlement state. A transient network failure must never instantly
/// drop a known-valid entitlement (see ARCHITECTURE 15.2).
enum EntitlementState: Equatable, Sendable {
    case unknown
    case loading
    case free
    case active(expiresAt: Date?)
    case gracePeriod(expiresAt: Date?)
    case billingRetry
    case expired
    case revoked

    /// Whether Plus content should currently be unlocked.
    var isPlusUnlocked: Bool {
        switch self {
        case .active, .gracePeriod, .billingRetry: true
        default: false
        }
    }

    var labelKey: String {
        switch self {
        case .unknown, .loading: "entitlement.loading"
        case .free: "entitlement.free"
        case .active: "entitlement.active"
        case .gracePeriod: "entitlement.grace"
        case .billingRetry: "entitlement.retry"
        case .expired: "entitlement.expired"
        case .revoked: "entitlement.revoked"
        }
    }
}

/// A purchasable subscription product, decoupled from StoreKit so previews and
/// tests never need the StoreKit runtime.
struct SubscriptionProduct: Identifiable, Sendable, Hashable {
    enum Period: String, Sendable { case monthly, yearly }

    let id: String
    var period: Period
    var displayName: String
    /// Localized price string sourced from StoreKit (never hardcoded).
    var displayPrice: String
    /// Localized "per month" equivalent for yearly plans, when derivable.
    var equivalentMonthlyPrice: String?
    var hasIntroOffer: Bool
    var introDescription: String?
}

/// Result of a purchase attempt, surfaced to the UI without StoreKit types.
enum PurchaseOutcome: Sendable, Equatable {
    case success
    case pending
    case userCancelled
    case failed(message: String)
}
