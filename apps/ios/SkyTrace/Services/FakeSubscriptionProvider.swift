import Foundation

/// In-memory subscription provider for previews, tests, and the Debug
/// entitlement override. No StoreKit runtime required.
actor FakeSubscriptionProvider: SubscriptionProviding {
    private var state: EntitlementState
    private var shouldFailPurchase: Bool
    private var purchaseIsPending: Bool

    init(initial: EntitlementState = .free,
         shouldFailPurchase: Bool = false,
         purchaseIsPending: Bool = false) {
        self.state = initial
        self.shouldFailPurchase = shouldFailPurchase
        self.purchaseIsPending = purchaseIsPending
    }

    nonisolated var manageSubscriptionsURL: URL? {
        URL(string: "https://apps.apple.com/account/subscriptions")
    }

    func loadProducts() async -> [SubscriptionProduct] {
        [
            SubscriptionProduct(id: SubscriptionIDs.monthly, period: .monthly,
                                displayName: "SkyTrace Plus（月額）", displayPrice: "¥600",
                                equivalentMonthlyPrice: nil, hasIntroOffer: false, introDescription: nil),
            SubscriptionProduct(id: SubscriptionIDs.yearly, period: .yearly,
                                displayName: "SkyTrace Plus（年額）", displayPrice: "¥5,800",
                                equivalentMonthlyPrice: "¥483", hasIntroOffer: true,
                                introDescription: "7日間の無料体験"),
        ]
    }

    func purchase(productID: String) async -> PurchaseOutcome {
        try? await Task.sleep(for: .milliseconds(400))
        if shouldFailPurchase { return .failed(message: "決済を完了できませんでした。") }
        if purchaseIsPending { return .pending }
        state = .active(expiresAt: Calendar.current.date(byAdding: .month, value: 1, to: FixtureClock.today))
        return .success
    }

    func restore() async -> EntitlementState {
        try? await Task.sleep(for: .milliseconds(300))
        return state
    }

    func currentEntitlement() async -> EntitlementState { state }

    /// Debug helper for the developer override menu.
    func override(_ new: EntitlementState) { state = new }
}

/// Product identifiers. Placeholder IDs — changed once App Store Connect is set
/// up (see MANUAL_ACTIONS.md). Never hardcode prices; those come from StoreKit.
enum SubscriptionIDs {
    static let monthly = "com.example.skytrace.plus.monthly"
    static let yearly = "com.example.skytrace.plus.yearly"
    static let all = [monthly, yearly]
    static let groupID = "skytrace_plus"
}
