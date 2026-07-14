import SwiftUI

/// Stable, highly legible reading surface for case reading, evidence, sources,
/// long-form, methodology (docs/uiux 02 §7.3). No image beneath body text; a
/// comfortable reading measure on wide layouts. This is NOT a glass card.
struct EditorialSurface<Content: View>: View {
    var constrainWidth: Bool = true
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: constrainWidth ? SkySpacing.readingMaxWidth : .infinity,
                   alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

/// An editorial section: heading + content separated by spacing/typography and a
/// short inset rule — not a rounded card (Gate B: "editorial sections do not
/// become card stacks").
struct EditorialSection<Content: View>: View {
    let title: String
    var systemImage: String? = nil
    var accent: Color = SkyColor.accentPrimary
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x3) {
            HStack(spacing: SkySpacing.x2) {
                if let systemImage {
                    Image(systemName: systemImage).foregroundStyle(accent).imageScale(.small)
                }
                Text(title)
                    .font(SkyTypography.sectionHeading)
                    .foregroundStyle(SkyColor.textPrimary)
            }
            .accessibilityAddTraits(.isHeader)
            Rectangle()
                .fill(SkyColor.separator)
                .frame(width: 36, height: 2)
            content()
        }
    }
}
