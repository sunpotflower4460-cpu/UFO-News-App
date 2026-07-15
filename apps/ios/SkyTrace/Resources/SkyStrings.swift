import Foundation

/// Central localization access point.
///
/// Backed by `Resources/Localizable.xcstrings` (Apple String Catalog): the OS
/// resolves each key for the current locale, so adding a language is a matter of
/// translating the catalog — no code change. Source language is Japanese, so an
/// untranslated language falls back to Japanese (English when the device is set
/// to English), which preserves the pre-catalog behaviour.
///
/// The `t(_:)` API is intentionally unchanged from the previous in-code table so
/// the ~330 call sites keep working verbatim. Keys are plain identifiers
/// (e.g. `"tab.today"`); the catalog stores the localized value per language.
enum SkyStrings {

    /// Resolve a key for the current locale via the String Catalog. Uses
    /// `NSLocalizedString` so that plural entries (compiled to `.stringsdict`)
    /// return their `%#@…@` format for the `String(format:locale:)` calls below
    /// to expand with the count argument.
    static func t(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Localizable", bundle: .main, comment: "")
    }

    /// Resolve with a single positional substitution. The format string is
    /// localized first, then filled — `locale:` keeps numeric args locale-aware.
    static func t(_ key: String, _ arg: CVarArg) -> String {
        String(format: t(key), locale: .current, arg)
    }

    static func t(_ key: String, _ a: CVarArg, _ b: CVarArg) -> String {
        String(format: t(key), locale: .current, a, b)
    }
}
