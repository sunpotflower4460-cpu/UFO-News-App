import SwiftUI

/// A shimmering skeleton block for loading states (no lone centre spinner).
struct SkeletonBlock: View {
    var height: CGFloat = 16
    var width: CGFloat? = nil
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = -1

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(SkyColor.surfaceInteractive)
            .frame(width: width, height: height)
            .overlay(
                GeometryReader { geo in
                    if !reduceMotion {
                        LinearGradient(colors: [.clear, SkyColor.textTertiary.opacity(0.18), .clear],
                                       startPoint: .leading, endPoint: .trailing)
                            .frame(width: geo.size.width * 0.5)
                            .offset(x: phase * geo.size.width)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .onAppear {
                guard !reduceMotion, !UITestFlags.disableAnimations else { return }
                withAnimation(.linear(duration: 1.3).repeatForever(autoreverses: false)) {
                    phase = 1.5
                }
            }
            .accessibilityHidden(true)
    }
}

/// A full skeleton card used while the Today feed loads.
struct SkeletonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: SkySpacing.x3) {
            SkeletonBlock(height: 14, width: 90)
            SkeletonBlock(height: 20)
            SkeletonBlock(height: 14, width: 220)
            SkeletonBlock(height: 14, width: 160)
        }
        .cardSurface()
    }
}

/// Empty state with a situation-specific message and optional action.
struct EmptyStateView: View {
    let messageKey: String
    var systemImage: String = "sparkles"
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: SkySpacing.x3) {
            Image(systemName: systemImage)
                .font(.system(size: 34)).foregroundStyle(SkyColor.textTertiary)
            Text(SkyStrings.t(messageKey))
                .font(SkyTypography.body).foregroundStyle(SkyColor.textSecondary)
                .multilineTextAlignment(.center)
            if let actionTitle, let action {
                Button(actionTitle, action: action).buttonStyle(.bordered).tint(SkyColor.signalCyan)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(SkySpacing.x8)
    }
}

/// A calm inline banner (offline / partial / demo / error).
struct InlineBanner: View {
    enum Kind { case offline, partial, demo, error }
    let kind: Kind
    var onRetry: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: SkySpacing.x2) {
            Image(systemName: symbol).foregroundStyle(SkyColor.signal(role))
            Text(SkyStrings.t(messageKey)).font(SkyTypography.supporting)
                .foregroundStyle(SkyColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            if let onRetry {
                Button(SkyStrings.t("action.retry"), action: onRetry)
                    .font(SkyTypography.metadata.weight(.semibold))
                    .foregroundStyle(SkyColor.signalCyan)
            }
        }
        .padding(SkySpacing.x3)
        .background(SkyColor.signal(role).opacity(0.10),
                    in: RoundedRectangle(cornerRadius: SkyRadius.chip))
        .accessibilityElement(children: .combine)
    }

    private var role: SignalRole {
        switch kind { case .offline: .cyan; case .partial: .amber; case .demo: .amber; case .error: .red }
    }
    private var symbol: String {
        switch kind {
        case .offline: "wifi.slash"; case .partial: "exclamationmark.circle"
        case .demo: "testtube.2"; case .error: "exclamationmark.triangle"
        }
    }
    private var messageKey: String {
        switch kind {
        case .offline: "state.offline.body"; case .partial: "state.partial.body"
        case .demo: "state.demo.body"; case .error: "state.error.body"
        }
    }
}

/// A small "fetched at …" stale-data badge.
struct StaleBadge: View {
    let date: Date
    var body: some View {
        Text(SkyStrings.t("state.stale", SkyFormat.relative(date)))
            .font(.caption2).foregroundStyle(SkyColor.textTertiary)
    }
}

/// Full-screen error state with retry.
struct ErrorStateView: View {
    var onRetry: () -> Void
    var body: some View {
        VStack(spacing: SkySpacing.x3) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 34)).foregroundStyle(SkyColor.signalRed)
            Text(SkyStrings.t("state.error.title"))
                .font(SkyTypography.sectionHeading).foregroundStyle(SkyColor.textPrimary)
            Text(SkyStrings.t("state.error.body"))
                .font(SkyTypography.supporting).foregroundStyle(SkyColor.textSecondary)
                .multilineTextAlignment(.center)
            Button(SkyStrings.t("action.retry"), action: onRetry)
                .buttonStyle(.borderedProminent).tint(SkyColor.signalCyan)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(SkySpacing.x8)
    }
}

#Preview("States") {
    ScrollView {
        VStack(spacing: 16) {
            SkeletonCard()
            InlineBanner(kind: .offline, onRetry: {})
            InlineBanner(kind: .partial)
            InlineBanner(kind: .demo)
            EmptyStateView(messageKey: "empty.today")
        }.padding()
    }
    .background(SkyColor.canvas)
}
