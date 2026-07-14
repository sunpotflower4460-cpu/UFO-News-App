import SwiftUI

/// The five reading groups of Case Detail (V3 §5.2). Used by the sticky
/// section navigator to jump within the page.
enum CaseSection: String, CaseIterable, Identifiable {
    case overview, assessment, evidence, timeline, sources
    var id: String { rawValue }
    var anchor: String { "case.section.\(rawValue)" }
    var labelKey: String { "case.nav.\(rawValue)" }
}

/// A small horizontal row of section chips that scrolls the page to a section.
/// Not a heavy custom tab UI — just quick in-page navigation. Dynamic-Type
/// safe; each chip is a real, VoiceOver-reachable button.
struct CaseSectionNavigator: View {
    var onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SkySpacing.x2) {
                ForEach(CaseSection.allCases) { section in
                    Button {
                        Haptics.light()
                        onSelect(section.anchor)
                    } label: {
                        Text(SkyStrings.t(section.labelKey))
                            .font(SkyTypography.metadata.weight(.semibold))
                            .foregroundStyle(SkyColor.textPrimary)
                            .padding(.horizontal, SkySpacing.x3)
                            .padding(.vertical, SkySpacing.x2)
                            .background(SkyColor.surfaceInteractive, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint(SkyStrings.t("case.nav.hint"))
                }
            }
        }
    }
}
