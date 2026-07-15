#!/usr/bin/env python3
"""Build Resources/Localizable.xcstrings from the SkyStrings in-code Pair table.

One-time / repeatable migration helper. Parses every
    "key": .init(ja: "…", en: "…"),
entry out of SkyStrings.swift (entries may span lines; no triple-quoted or
interpolated strings exist in the table) and emits an Apple String Catalog with
ja + en localizations. Source language is `ja` (matches the current runtime
fallback: English only when the device is English, Japanese otherwise).

Target languages are declared as empty entries so Xcode surfaces them for
translation; until translated they fall back to the source language.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "apps/ios/SkyTrace/Resources/SkyStrings.swift"
OUT = ROOT / "apps/ios/SkyTrace/Resources/Localizable.xcstrings"

# Languages the catalog should expose (ja+en populated now; rest filled in B3).
TARGET_LANGS = ["ja", "en", "es", "fr", "de", "pt-PT",
                "zh-Hans", "zh-Hant", "ko", "ar", "hi", "ru"]

# "key": .init(ja: "…", en: "…")  — DOTALL so the .init(...) can span lines.
ENTRY = re.compile(
    r'"(?P<key>[^"\\]+)"\s*:\s*\.init\(\s*'
    r'ja:\s*"(?P<ja>(?:\\.|[^"\\])*)"\s*,\s*'
    r'en:\s*"(?P<en>(?:\\.|[^"\\])*)"\s*\)',
    re.DOTALL,
)

SWIFT_UNESCAPE = {'\\"': '"', "\\\\": "\\", "\\n": "\n", "\\t": "\t", "\\'": "'"}


def unescape(s: str) -> str:
    return re.sub(r'\\["\\nt\']', lambda m: SWIFT_UNESCAPE[m.group(0)], s)


def main() -> int:
    text = SRC.read_text(encoding="utf-8")
    strings: dict[str, dict] = {}
    for m in ENTRY.finditer(text):
        key = m.group("key")
        ja = unescape(m.group("ja"))
        en = unescape(m.group("en"))
        loc = {
            "ja": {"stringUnit": {"state": "translated", "value": ja}},
            "en": {"stringUnit": {"state": "translated", "value": en}},
        }
        strings[key] = {"extractionState": "manual", "localizations": loc}

    catalog = {"sourceLanguage": "ja", "strings": dict(sorted(strings.items())), "version": "1.0"}
    OUT.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(strings)} keys → {OUT.relative_to(ROOT)}")
    print(f"Declared languages: {', '.join(TARGET_LANGS)} (ja+en populated)")
    return 0 if strings else 1


if __name__ == "__main__":
    sys.exit(main())
