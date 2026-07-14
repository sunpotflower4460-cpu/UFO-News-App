import SwiftUI

/// Value-based navigation targets, so any list can push detail with
/// `NavigationLink(value:)` and a single `navigationDestination` install.
struct CaseLink: Hashable { let id: String }
struct BriefingLink: Hashable { let date: Date }

extension View {
    /// Installs the shared case + briefing destinations on a NavigationStack.
    func skyDestinations() -> some View {
        navigationDestination(for: CaseLink.self) { link in
            CaseDetailView(caseID: link.id)
        }
        .navigationDestination(for: BriefingLink.self) { link in
            BriefingDetailView(date: link.date)
        }
    }
}

/// Context passed to the paywall so its headline/CTA fit where it was triggered.
struct PaywallContext: Identifiable {
    enum Trigger { case briefing, synthesis, filters, tracking }
    let id = UUID()
    let trigger: Trigger

    var unlocks: [String] {
        [
            SkyStrings.t("paywall.feature.briefing"),
            SkyStrings.t("paywall.feature.synthesis"),
            SkyStrings.t("paywall.feature.evidence"),
            SkyStrings.t("paywall.feature.filters"),
            SkyStrings.t("paywall.feature.tracking"),
        ]
    }
}
