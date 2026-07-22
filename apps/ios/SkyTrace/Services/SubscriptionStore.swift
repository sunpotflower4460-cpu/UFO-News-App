import SwiftUI
import Observation

/// Observable façade over a `SubscriptionProviding` implementation. The UI
/// binds to this; it never touches StoreKit. A transient StoreKit failure never
/// downgrades a previously-known entitlement.
@MainActor
@Observable
final class SubscriptionStore {
    private(set) var entitlement: EntitlementState = .unknown
    private(set) var products: [SubscriptionProduct] = []
    private(set) var isPurchasing = false
    private(set) var isRefreshing = false
    var lastMessageKey: String?

    private var provider: any SubscriptionProviding
    private var observationTask: Task<Void, Never>?

    var manageSubscriptionsURL: URL? { provider.manageSubscriptionsURL }
    var isPlus: Bool { entitlement.isPlusUnlocked }

    init(provider: any SubscriptionProviding) {
        self.provider = provider
    }

    /// Swap the backing provider (used by Debug entitlement overrides). Any live
    /// StoreKit listener is replaced so duplicate listeners cannot accumulate.
    func setProvider(_ newProvider: any SubscriptionProviding) {
        stopObservingTransactions()
        provider = newProvider
        Task { [weak self] in
            guard let self else { return }
            await self.refresh()
            self.startObservingTransactions()
        }
    }

    func refresh() async {
        isRefreshing = true
        defer { isRefreshing = false }

        async let ent = provider.currentEntitlement()
        async let prods = provider.loadProducts()
        let (newEntitlement, newProducts) = await (ent, prods)

        apply(newEntitlement)
        // Preserve StoreKit products through a transient empty read. On first
        // launch an empty list remains empty and the paywall can show retry UI.
        if !newProducts.isEmpty || products.isEmpty { products = newProducts }
    }

    func loadProductsIfNeeded() async {
        guard products.isEmpty else { return }
        let loaded = await provider.loadProducts()
        if !loaded.isEmpty { products = loaded }
    }

    /// Start exactly one app-lifetime transaction listener. It covers renewals,
    /// refunds, Ask to Buy, offer redemptions, and purchases made on other devices.
    func startObservingTransactions() {
        guard observationTask == nil else { return }
        observationTask = provider.observeTransactionUpdates { [weak self] state in
            Task { @MainActor [weak self] in
                self?.apply(state)
            }
        }
    }

    func stopObservingTransactions() {
        observationTask?.cancel()
        observationTask = nil
    }

    @discardableResult
    func purchase(_ productID: String) async -> PurchaseOutcome {
        isPurchasing = true
        defer { isPurchasing = false }
        let outcome = await provider.purchase(productID: productID)
        switch outcome {
        case .success:
            apply(await provider.currentEntitlement())
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
        apply(state)
        lastMessageKey = state.isPlusUnlocked ? "paywall.restored" : "paywall.nothingToRestore"
        if state.isPlusUnlocked { Haptics.success() }
    }

    /// `.unknown` means StoreKit could not prove a state; it must not erase a
    /// previously resolved entitlement. Explicit free/expired/revoked states do.
    private func apply(_ newState: EntitlementState) {
        if case .unknown = newState, entitlement.isResolved { return }
        entitlement = newState
    }
}
