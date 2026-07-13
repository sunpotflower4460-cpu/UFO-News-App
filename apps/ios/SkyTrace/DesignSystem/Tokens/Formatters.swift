import Foundation

/// Centralised, locale/timezone-aware formatting. Keeps views free of ad-hoc
/// `DateFormatter` usage and honours the "occurred vs published" distinction.
enum SkyFormat {

    /// Medium date + short time in a specific zone (e.g. the observation site).
    static func dateTime(_ date: Date, zone: TimeZone = .current) -> String {
        date.formatted(
            .dateTime.year().month().day().hour().minute()
                .timeZone(zone)
        )
    }

    /// Short time only, in the given zone.
    static func time(_ date: Date, zone: TimeZone = .current) -> String {
        date.formatted(.dateTime.hour().minute().timeZone(zone))
    }

    /// Date only (no time).
    static func dateOnly(_ date: Date) -> String {
        date.formatted(.dateTime.year().month().day())
    }

    /// Relative, e.g. "3時間前" / "3 hours ago".
    static func relative(_ date: Date, now: Date = .now) -> String {
        date.formatted(.relative(presentation: .named))
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
