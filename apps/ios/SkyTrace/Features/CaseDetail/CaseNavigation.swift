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

/// Context passed to the paywall so its headline/features fit where it was
/// triggered — the gate leads with the feature the reader just reached for,
/// then lists the rest, rather than a generic wall.
struct PaywallContext: Identifiable {
    enum Trigger: String { case briefing, synthesis, filters, tracking }
    let id = UUID()
    let trigger: Trigger

    /// A one-line lead that names why the gate appeared here.
    var headlineKey: String { "paywall.context.\(trigger.rawValue)" }

    /// All Plus features, with the triggering feature first. `evidence` is a
    /// general benefit and always follows the lead.
    var unlocks: [String] {
        let ordered: [Trigger] = ([trigger] + Trigger.ordered.filter { $0 != trigger })
        var keys = ordered.map { "paywall.feature.\($0.rawValue)" }
        keys.insert("paywall.feature.evidence", at: 1)
        return keys.map { SkyStrings.t($0) }
    }
}

private extension PaywallContext.Trigger {
    static let ordered: [PaywallContext.Trigger] = [.synthesis, .briefing, .filters, .tracking]
}
