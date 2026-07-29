import Foundation

/// Centralised, locale/timezone-aware formatting. Keeps views free of ad-hoc
/// `DateFormatter` usage and honours the "occurred vs published" distinction.
enum SkyFormat {

    /// Medium date + short time in a specific zone (e.g. the observation site).
    static func dateTime(_ date: Date, zone: TimeZone = .current) -> String {
        var style = Date.FormatStyle.dateTime.year().month().day().hour().minute()
        style.timeZone = zone
        return date.formatted(style)
    }

    /// Short time only, in the given zone.
    static func time(_ date: Date, zone: TimeZone = .current) -> String {
        var style = Date.FormatStyle.dateTime.hour().minute()
        style.timeZone = zone
        return date.formatted(style)
    }

    /// Date only (no time).
    static func dateOnly(_ date: Date) -> String {
        date.formatted(.dateTime.year().month().day())
    }

    /// Relative to the supplied reference instant, e.g. "3時間前" / "3 hours ago".
    /// `Date.FormatStyle.relative` implicitly uses the wall clock and cannot honour
    /// an injected `now`, which made fixture/server-time calculations incorrect.
    static func relative(_ date: Date, now: Date = .now) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: now)
    }

    /// Adaptive freshness: a relative phrase within `window` days ("3日前"),
    /// otherwise an absolute date. Use for freshness signals (last verified /
    /// updated) — not for historical event facts, where an absolute date is
    /// always clearer.
    static func adaptive(_ date: Date, now: Date = .now, window: Int = 14) -> String {
        let days = Calendar.current.dateComponents([.day], from: date, to: now).day ?? 0
        return (days >= 0 && days <= window) ? relative(date, now: now) : dateOnly(date)
    }

    /// Formats an observation instant with both local and user time when the
    /// zones differ, e.g. "現地 21:42 / 端末 04:42".
    static func dualTime(_ date: Date, siteZone: TimeZone, userZone: TimeZone = .current) -> String {
        let site = time(date, zone: siteZone)
        guard siteZone.identifier != userZone.identifier else { return site }
        let user = time(date, zone: userZone)
        return "\(site) · \(user)"
    }
}
