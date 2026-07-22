import Foundation
import StoreKit

/// Production subscription provider using StoreKit 2. During development it is
/// driven by the local `SkyTrace.storekit` configuration (no App Store Connect
/// credentials required). Views never call StoreKit directly — only this type.
actor StoreKitSubscriptionService: SubscriptionProviding {
    private var productsByID: [String: Product] = [:]

    nonisolated var manageSubscriptionsURL: URL? {
        URL(string: "https://apps.apple.com/account/subscriptions")
    }

    func loadProducts() async -> [SubscriptionProduct] {
        do {
            let products = try await Product.products(for: SubscriptionIDs.all)
            for p in products { productsByID[p.id] = p }
            return products
                .sorted { $0.price < $1.price }
                .map(Self.map)
        } catch {
            return []
        }
    }

    func purchase(productID: String) async -> PurchaseOutcome {
        // Note: `await` cannot live inside the `??` autoclosure, so resolve first.
        var product = productsByID[productID]
        if product == nil {
            product = (try? await Product.products(for: [productID]))?.first
        }
        guard let product else {
            return .failed(message: "商品を取得できませんでした。")
        }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    return .success
                case .unverified:
                    return .failed(message: "購入の検証に失敗しました。")
                }
            case .pending:
                return .pending
            case .userCancelled:
                return .userCancelled
            @unknown default:
                return .failed(message: "不明なエラーが発生しました。")
            }
        } catch {
            return .failed(message: error.localizedDescription)
        }
    }

    func restore() async -> EntitlementState {
        try? await AppStore.sync()
        return await currentEntitlement()
    }

    /// Resolve the subscription group's signed renewal status. Unlike reading
    /// expiration dates alone, this distinguishes grace period, billing retry,
    /// expiration, and revocation. Apple only grants service for subscribed and
    /// in-grace-period states.
    func currentEntitlement() async -> EntitlementState {
        do {
            let products = try await Product.products(for: SubscriptionIDs.all)
            guard !products.isEmpty else {
                // Empty products normally means StoreKit/App Store Connect is not
                // configured or temporarily unavailable; it does not prove Free.
                return .unknown
            }
            for product in products { productsByID[product.id] = product }

            var states: [EntitlementState] = []
            var sawSubscriptionStatus = false

            for product in products {
                guard let subscription = product.subscription else { continue }
                let statuses = try await subscription.status
                if !statuses.isEmpty { sawSubscriptionStatus = true }

                for status in statuses {
                    guard case .verified(let transaction) = status.transaction,
                          SubscriptionIDs.all.contains(transaction.productID) else {
                        continue
                    }
                    states.append(Self.map(status.state,
                                           expiresAt: transaction.expirationDate))
                }
            }

            if let best = states.max(by: { Self.rank($0) < Self.rank($1) }) {
                return best
            }
            return sawSubscriptionStatus ? .unknown : .free
        } catch {
            // On a transient product/status failure, currentEntitlements can still
            // prove paid access. An empty fallback is ambiguous, so return unknown
            // and let SubscriptionStore preserve a previously-known valid state.
            return await fallbackCurrentEntitlement()
        }
    }

    /// Observe purchases, renewals, refunds, Ask to Buy, and changes made on
    /// other devices for the app lifetime. The returned task is retained and
    /// cancelled by SubscriptionStore so only one listener exists.
    nonisolated func observeTransactionUpdates(
        _ onChange: @escaping @Sendable (EntitlementState) -> Void
    ) -> Task<Void, Never>? {
        Task.detached { [self] in
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await transaction.finish()
                }
                let state = await self.currentEntitlement()
                onChange(state)
            }
        }
    }

    // MARK: Entitlement mapping

    private func fallbackCurrentEntitlement() async -> EntitlementState {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  SubscriptionIDs.all.contains(transaction.productID) else { continue }
            if transaction.revocationDate != nil { continue }
            return .active(expiresAt: transaction.expirationDate)
        }
        return .unknown
    }

    private static func map(_ state: Product.SubscriptionInfo.RenewalState,
                            expiresAt: Date?) -> EntitlementState {
        switch state {
        case .subscribed:
            return .active(expiresAt: expiresAt)
        case .inGracePeriod:
            return .gracePeriod(expiresAt: expiresAt)
        case .inBillingRetryPeriod:
            return .billingRetry
        case .expired:
            return .expired
        case .revoked:
            return .revoked
        default:
            return .unknown
        }
    }

    /// Higher rank wins when Family Sharing or multiple statuses produce more
    /// than one record for the subscription group.
    private static func rank(_ state: EntitlementState) -> Int {
        switch state {
        case .active: 60
        case .gracePeriod: 50
        case .billingRetry: 40
        case .expired: 30
        case .revoked: 20
        case .free: 10
        case .unknown, .loading: 0
        }
    }

    // MARK: Product mapping

    private static func map(_ product: Product) -> SubscriptionProduct {
        let period: SubscriptionProduct.Period =
            (product.subscription?.subscriptionPeriod.unit == .year) ? .yearly : .monthly
        var equivalent: String? = nil
        if period == .yearly {
            let monthly = product.price / 12
            equivalent = product.priceFormatStyle.format(monthly)
        }
        let intro = product.subscription?.introductoryOffer
        return SubscriptionProduct(
            id: product.id, period: period,
            displayName: product.displayName,
            displayPrice: product.displayPrice,
            equivalentMonthlyPrice: equivalent,
            hasIntroOffer: intro != nil,
            introDescription: intro.map { _ in "無料体験あり" }
        )
    }
}
