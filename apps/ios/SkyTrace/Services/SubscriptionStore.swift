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
    private(set) var isLoadingProducts = false
    private(set) var productLoadFailed = false
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
        products = []
        productLoadFailed = false
        lastMessageKey = nil
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
        guard !Task.isCancelled else { return }

        apply(newEntitlement)
        if newProducts.isEmpty {
            // Preserve a previously loaded catalogue through a transient failure,
            // but expose an actionable error when the first load produced none.
            if products.isEmpty { productLoadFailed = true }
        } else {
            products = newProducts
            productLoadFailed = false
        }
    }

    func loadProductsIfNeeded(force: Bool = false) async {
        guard force || products.isEmpty else { return }
        guard !isLoadingProducts else { return }
        isLoadingProducts = true
        productLoadFailed = false
        defer { isLoadingProducts = false }

        let loaded = await provider.loadProducts()
        guard !Task.isCancelled else { return }
        if loaded.isEmpty {
            productLoadFailed = true
        } else {
            products = loaded
            productLoadFailed = false
        }
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
        lastMessageKey = nil
        isPurchasing = true
        defer { isPurchasing = false }
        let outcome = await provider.purchase(productID: productID)
        guard !Task.isCancelled else { return .userCancelled }
        switch outcome {
        case .success:
            apply(await provider.currentEntitlement())
            Haptics.success()
        case .pending:
            lastMessageKey = "paywall.pending"
        case .failed:
            lastMessageKey = "state.error.body"
            Haptics.error()
        case .userCancelled:
            break
        }
        return outcome
    }

    func restore() async {
        lastMessageKey = nil
        let state = await provider.restore()
        guard !Task.isCancelled else { return }
        apply(state)
        switch state {
        case .unknown:
            lastMessageKey = "state.error.body"
            Haptics.error()
        default:
            lastMessageKey = state.isPlusUnlocked ? "paywall.restored" : "paywall.nothingToRestore"
            if state.isPlusUnlocked { Haptics.success() }
        }
    }

    /// `.unknown` means StoreKit could not prove a state; it must not erase a
    /// previously resolved entitlement. Explicit free/expired/revoked states do.
    private func apply(_ newState: EntitlementState) {
        if case .unknown = newState, entitlement.isResolved { return }
        entitlement = newState
    }
}
