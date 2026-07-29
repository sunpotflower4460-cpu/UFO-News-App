import SwiftUI

/// Shared shape for the two sections that must never be the first thing a
/// reader sees: the AI's reference notes and the detailed confirmation data.
/// Both default to closed (directive §4.6/§4.7) and both state, in the label
/// itself, that what follows is optional supporting reading — not a verdict.
private struct CollapsibleReferenceSection<Content: View>: View {
    let titleKey: String
    let subtitleKey: String
    let systemImage: String
    let accessibilityIdentifier: String
    @State private var isExpanded = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            content().padding(.top, SkySpacing.x3)
        } label: {
            HStack(spacing: SkySpacing.x2) {
                Image(systemName: systemImage).foregroundStyle(SkyColor.textSecondary).imageScale(.small)
                VStack(alignment: .leading, spacing: 2) {
                    Text(SkyStrings.t(titleKey))
                        .font(SkyTypography.supporting.weight(.semibold))
                        .foregroundStyle(SkyColor.textPrimary)
                    Text(SkyStrings.t(subtitleKey))
                        .font(.caption2).foregroundStyle(SkyColor.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

/// "AIの補足を見る" (directive §4.6): the AI article link, the disclosure note,
/// and the Trust Center entry — collapsed by default, always optional, never
/// the page's lead content. Content order inside: agreement, disagreement,
/// plausible mundane explanations, what's still missing, generation metadata.
struct AIReferenceDisclosure<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        CollapsibleReferenceSection(
            titleKey: "ai.referenceTitle",
            subtitleKey: "ai.referenceSubtitle",
            systemImage: "sparkles",
            accessibilityIdentifier: "caseDetail.aiReference.disclosure",
            content: content
        )
    }
}

/// "詳しい確認データ" (directive §4.7): the multi-axis assessment dimensions,
/// each with a plain-language basis sentence rather than a bare number.
/// Collapsed by default so it reads as optional depth, not the headline.
struct DetailedAssessmentDisclosure<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        CollapsibleReferenceSection(
            titleKey: "assess.sectionTitle",
            subtitleKey: "assess.disclosureSubtitle",
            systemImage: "gauge.with.dots.needle.50percent",
            accessibilityIdentifier: "caseDetail.assessment.disclosure",
            content: content
        )
    }
}

#Preview("Reference Disclosures") {
    ScrollView {
        VStack(alignment: .leading, spacing: SkySpacing.x4) {
            AIReferenceDisclosure { Text("AI reference content") }
            DetailedAssessmentDisclosure { Text("Assessment content") }
        }
        .padding()
    }
    .background(SkyColor.canvas)
}
