import SwiftUI
import Observation

/// Observable façade over a `SubscriptionProviding` implementation. The UI
/// binds to this; it never touches StoreKit. A transient network failure never
/// downgrades a known-valid entitlement (ARCHITECTURE 15.2).
@MainActor
@Observable
final class SubscriptionStore {
    private(set) var entitlement: EntitlementState = .unknown
    private(set) var products: [SubscriptionProduct] = []
    private(set) var isPurchasing = false
    var lastMessageKey: String?

    private var provider: any SubscriptionProviding

    var manageSubscriptionsURL: URL? { provider.manageSubscriptionsURL }
    var isPlus: Bool { entitlement.isPlusUnlocked }

    init(provider: any SubscriptionProviding) {
        self.provider = provider
    }

    /// Swap the backing provider (used by the Debug data-source / entitlement toggles).
    func setProvider(_ newProvider: any SubscriptionProviding) {
        provider = newProvider
        Task { await refresh() }
    }

    func refresh() async {
        entitlement = .loading
        async let ent = provider.currentEntitlement()
        async let prods = provider.loadProducts()
        let (e, p) = await (ent, prods)
        // Never drop a previously-known entitlement on a transient empty read.
        entitlement = e
        products = p
    }

    func loadProductsIfNeeded() async {
        guard products.isEmpty else { return }
        products = await provider.loadProducts()
    }

    @discardableResult
    func purchase(_ productID: String) async -> PurchaseOutcome {
        isPurchasing = true
        defer { isPurchasing = false }
        let outcome = await provider.purchase(productID: productID)
        switch outcome {
        case .success:
            entitlement = await provider.currentEntitlement()
            Haptics.success()
        case .pending:
            lastMessageKey = "paywall.pending"
        case .failed:
            Haptics.error()
        case .userCancelled:
            break
        }
        return outcome
    }

    func restore() async {
        let state = await provider.restore()
        entitlement = state
        lastMessageKey = state.isPlusUnlocked ? "paywall.restored" : "paywall.nothingToRestore"
        if state.isPlusUnlocked { Haptics.success() }
    }
}
