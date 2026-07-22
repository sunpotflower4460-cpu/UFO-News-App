import SwiftUI

/// Contextual, honest paywall. No fake countdowns, no hidden close button, and
/// prices come from StoreKit. After purchase it dismisses back to the content
/// the user was reading (the caller resumes; we don't route home).
struct PaywallView: View {
    let context: PaywallContext
    @Environment(AppEnvironment.self) private var env
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProductID: String?
    @State private var linkToOpen: IdentifiedURL?

    private var subscription: SubscriptionStore { env.subscription }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SkySpacing.x5) {
                    header
                    featureList
                    productPicker
                    cta
                    legalRow
                    Text(SkyStrings.t("paywall.renewNote"))
                        .font(.caption2).foregroundStyle(SkyColor.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(SkySpacing.x5)
                .readingWidth()
            }
            .background(SkyColor.canvas)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(SkyStrings.t("action.close")) { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(SkyStrings.t("paywall.restore")) { Task { await subscription.restore() } }
                        .font(.caption)
                }
            }
            .task {
                await subscription.loadProductsIfNeeded()
                guard !Task.isCancelled else { return }
                selectDefault()
            }
            .sheet(item: $linkToOpen) { SafariView(url: $0.url) }
            .onChange(of: subscription.isPlus) { _, isPlus in if isPlus { dismiss() } }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x2) {
            PremiumBadge()
            Text(SkyStrings.t("paywall.heroTitle"))
                .font(SkyTypography.screenHero).foregroundStyle(SkyColor.textPrimary)
            // Context lead: names why the gate appeared where the reader hit it.
            Text(SkyStrings.t(context.headlineKey))
                .font(SkyTypography.body.weight(.semibold)).foregroundStyle(SkyColor.signalViolet)
                .fixedSize(horizontal: false, vertical: true)
            Text(SkyStrings.t("paywall.heroBody"))
                .font(SkyTypography.body).foregroundStyle(SkyColor.textSecondary)
        }
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x2) {
            ForEach(context.unlocks, id: \.self) { item in
                HStack(spacing: SkySpacing.x2) {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(SkyColor.signalViolet)
                    Text(item).font(SkyTypography.supporting).foregroundStyle(SkyColor.textPrimary)
                }
            }
        }
    }

    private var productPicker: some View {
        VStack(spacing: SkySpacing.x2) {
            ForEach(subscription.products) { product in
                Button { selectedProductID = product.id; Haptics.selection() } label: {
                    productRow(product)
                }
                .buttonStyle(.plain)
            }
            if subscription.products.isEmpty {
                if subscription.isLoadingProducts || !subscription.productLoadFailed {
                    ProgressView().padding()
                } else {
                    InlineBanner(kind: .error) {
                        Task {
                            await subscription.loadProductsIfNeeded(force: true)
                            guard !Task.isCancelled else { return }
                            selectDefault()
                        }
                    }
                }
            }
        }
    }

    private func productRow(_ product: SubscriptionProduct) -> some View {
        let selected = selectedProductID == product.id
        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(product.displayName).font(SkyTypography.supporting.weight(.semibold))
                    .foregroundStyle(SkyColor.textPrimary)
                if let eq = product.equivalentMonthlyPrice {
                    Text(SkyStrings.t("paywall.perMonth", eq))
                        .font(.caption2).foregroundStyle(SkyColor.textTertiary)
                }
                if let intro = product.introDescription {
                    Text(intro).font(.caption2).foregroundStyle(SkyColor.signalGreen)
                }
            }
            Spacer()
            Text(product.displayPrice).font(SkyTypography.cardHeadline.monospacedDigit())
                .foregroundStyle(SkyColor.textPrimary)
            Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                .foregroundStyle(selected ? SkyColor.signalViolet : SkyColor.textTertiary)
        }
        .padding(SkySpacing.x4)
        .background(SkyColor.surfacePrimary, in: RoundedRectangle(cornerRadius: SkyRadius.card))
        .overlay(RoundedRectangle(cornerRadius: SkyRadius.card)
            .strokeBorder(selected ? SkyColor.signalViolet : SkyColor.borderSubtle, lineWidth: selected ? 2 : 1))
    }

    private var cta: some View {
        VStack(spacing: SkySpacing.x2) {
            Button {
                guard let id = selectedProductID else { return }
                Task { await subscription.purchase(id) }
            } label: {
                Group {
                    if subscription.isPurchasing { ProgressView().tint(.white) }
                    else { Text(SkyStrings.t("paywall.cta")) }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent).tint(SkyColor.signalViolet).controlSize(.large)
            .disabled(selectedProductID == nil || subscription.isPurchasing)

            if let key = subscription.lastMessageKey {
                Text(SkyStrings.t(key)).font(.caption).foregroundStyle(SkyColor.textSecondary)
            }
        }
    }

    private var legalRow: some View {
        HStack(spacing: SkySpacing.x4) {
            Button(SkyStrings.t("paywall.terms")) { openLegal(.terms) }
            Button(SkyStrings.t("paywall.privacy")) { openLegal(.privacy) }
            if let url = subscription.manageSubscriptionsURL {
                Button(SkyStrings.t("paywall.manage")) { linkToOpen = IdentifiedURL(url: url) }
            }
        }
        .font(.caption).foregroundStyle(SkyColor.signalCyan)
    }

    private func openLegal(_ page: LegalPage) {
        if let url = page.externalURL { linkToOpen = IdentifiedURL(url: url) }
    }

    private func selectDefault() {
        if selectedProductID == nil {
            selectedProductID = subscription.products.first(where: { $0.period == .yearly })?.id
                ?? subscription.products.first?.id
        }
    }
}

#Preview("Paywall") {
    PaywallView(context: PaywallContext(trigger: .synthesis))
        .environment(AppEnvironment.preview())
}
