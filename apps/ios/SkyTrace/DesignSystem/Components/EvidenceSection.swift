import SwiftUI

/// Section header used across Case Detail. Keeps spacing/typography consistent.
struct SectionHeader: View {
    let title: String
    var systemImage: String? = nil
    var body: some View {
        HStack(spacing: SkySpacing.x2) {
            if let systemImage {
                Image(systemName: systemImage).foregroundStyle(SkyColor.signalCyan)
            }
            Text(title).font(SkyTypography.sectionHeading).foregroundStyle(SkyColor.textPrimary)
        }
        .accessibilityAddTraits(.isHeader)
    }
}

/// A list of evidence bullet points (agreements, contradictions, gaps).
struct EvidenceSection: View {
    let title: String
    let systemImage: String
    let role: SignalRole
    let items: [String]

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: SkySpacing.x3) {
                SectionHeader(title: title, systemImage: systemImage)
                VStack(alignment: .leading, spacing: SkySpacing.x2) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        HStack(alignment: .top, spacing: SkySpacing.x2) {
                            Image(systemName: "circle.fill").font(.system(size: 5))
                                .foregroundStyle(SkyColor.signal(role))
                                .padding(.top, 6)
                            Text(item).font(SkyTypography.body)
                                .foregroundStyle(SkyColor.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .cardSurface()
            }
        }
    }
}
