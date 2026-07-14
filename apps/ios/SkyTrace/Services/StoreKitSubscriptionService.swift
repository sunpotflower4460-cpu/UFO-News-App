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

    func currentEntitlement() async -> EntitlementState {
        var best: EntitlementState = .free
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard SubscriptionIDs.all.contains(transaction.productID) else { continue }
            if let revoked = transaction.revocationDate, revoked <= Date() {
                best = .revoked
                continue
            }
            if let expiry = transaction.expirationDate, expiry < Date() {
                if case .free = best { best = .expired }
                continue
            }
            best = .active(expiresAt: transaction.expirationDate)
        }
        return best
    }

    /// Observe transaction updates for the app lifetime. Returns a task the app
    /// stores so entitlement stays fresh on renewals/refunds.
    func observeTransactionUpdates(_ onChange: @escaping @Sendable (EntitlementState) -> Void) -> Task<Void, Never> {
        Task.detached {
            for await update in Transaction.updates {
                if case .verified(let transaction) = update {
                    await transaction.finish()
                }
                let state = await self.currentEntitlement()
                onChange(state)
            }
        }
    }

    // MARK: Mapping

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
