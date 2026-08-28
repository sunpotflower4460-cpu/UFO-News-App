#!/usr/bin/env python3
"""Linux-runnable pre-build verification for SkyTrace.

The iOS app compiles only on macOS + Xcode, so this harness runs every check
that *can* run on Linux and fails fast when a repository-level invariant breaks.
It is the closest thing to "build verification" available off-macOS and is wired
into `make verify` and CI (.github/workflows/preflight.yml).

Checks:
  1. Python tooling compiles
  2. Resource JSON is valid (xcstrings / storekit / asset Contents.json)
  3. Resource XML is valid (xcprivacy / xcscheme / Info.plist)
  4. project.pbxproj integrity (brace/paren balance, no dangling object refs)
  5. Every Swift source is referenced in project.pbxproj (nothing dropped)
  6. String Catalog covers every literal SkyStrings.t("…") key, ja+en populated
  7. Legal site links are relative and resolve (GitHub Pages sub-path safe)
  8. docs/preview/data.json is in sync with the Swift fixtures

Exit code is non-zero if any check fails. `--strict` additionally enforces the
App Store release-readiness gates (normally informational).
"""
from __future__ import annotations

import argparse
import glob
import json
import re
import subprocess
import sys
import tempfile
import xml.dom.minidom as minidom
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
IOS = ROOT / "apps/ios"
APP = IOS / "SkyTrace"
PBXPROJ = IOS / "SkyTrace.xcodeproj/project.pbxproj"
CATALOG = APP / "Resources/Localizable.xcstrings"
SITE = ROOT / "docs/site"
PREVIEW_DATA = ROOT / "docs/preview/data.json"

results: list[tuple[str, bool, str]] = []


def check(name: str, ok: bool, detail: str = "") -> None:
    results.append((name, ok, detail))


# 1. Python compiles ---------------------------------------------------------
def c_python() -> None:
    scripts = sorted(glob.glob(str(ROOT / "scripts/*.py")))
    r = subprocess.run([sys.executable, "-m", "py_compile", *scripts],
                       capture_output=True, text=True)
    check("python-compiles", r.returncode == 0,
          r.stderr.strip() or f"{len(scripts)} scripts")


# 2/3. Resource validity -----------------------------------------------------
def c_resources() -> None:
    jsons = [CATALOG, IOS / "SkyTrace.storekit",
             *(Path(p) for p in glob.glob(str(APP / "Resources/Assets.xcassets/**/Contents.json"), recursive=True))]
    bad = []
    for f in jsons:
        try:
            json.loads(Path(f).read_text(encoding="utf-8"))
        except Exception as e:
            bad.append(f"{Path(f).name}: {e}")
    check("resource-json", not bad, "; ".join(bad) or f"{len(jsons)} files valid")

    xmls = [*(Path(p) for p in glob.glob(str(IOS / "**/*.xcprivacy"), recursive=True)),
            *(Path(p) for p in glob.glob(str(IOS / "**/*.xcscheme"), recursive=True)),
            *(Path(p) for p in glob.glob(str(IOS / "**/*.plist"), recursive=True))]
    badx = []
    for f in xmls:
        try:
            minidom.parse(str(f))
        except Exception as e:
            badx.append(f"{Path(f).name}: {e}")
    check("resource-xml", not badx, "; ".join(badx) or f"{len(xmls)} files valid")


# 4. pbxproj integrity -------------------------------------------------------
def c_pbxproj() -> None:
    s = PBXPROJ.read_text(encoding="utf-8")
    bal = s.count("{") == s.count("}") and s.count("(") == s.count(")")
    check("pbxproj-balanced", bal,
          f"braces {s.count('{')}/{s.count('}')} parens {s.count('(')}/{s.count(')')}")
    ids = set(re.findall(r"\b([0-9A-F]{24})\b", s))
    defined = set(re.findall(r"^\s*([0-9A-F]{24})\b", s, re.M))
    dangling = sorted(ids - defined)
    check("pbxproj-refs", not dangling,
          "dangling: " + ", ".join(dangling[:5]) if dangling else f"{len(ids)} ids resolve")


# 5. Source coverage ---------------------------------------------------------
def c_sources() -> None:
    s = PBXPROJ.read_text(encoding="utf-8")
    swift = [Path(p) for p in glob.glob(str(APP / "**/*.swift"), recursive=True)]
    swift += [Path(p) for p in glob.glob(str(IOS / "SkyTraceTests/**/*.swift"), recursive=True)]
    swift += [Path(p) for p in glob.glob(str(IOS / "SkyTraceUITests/**/*.swift"), recursive=True)]
    missing = [f.name for f in swift if f.name not in s]
    check("source-coverage", not missing,
          f"not in project: {', '.join(missing[:6])}" if missing else f"{len(swift)} swift files referenced")


# 6. String catalog coverage -------------------------------------------------
def c_catalog() -> None:
    cat = json.loads(CATALOG.read_text(encoding="utf-8"))
    keys = cat.get("strings", {})
    used = set()
    for f in glob.glob(str(APP / "**/*.swift"), recursive=True):
        used |= set(re.findall(r'\bt\(\s*"([^"\\]+)"', Path(f).read_text(encoding="utf-8")))
    missing = sorted(k for k in used if k not in keys)
    check("catalog-keys", not missing,
          f"missing: {', '.join(missing[:6])}" if missing else f"{len(used)} literal keys resolve")
    incomplete = [k for k, v in keys.items()
                  if "ja" not in v.get("localizations", {}) or "en" not in v.get("localizations", {})]
    check("catalog-ja-en", not incomplete,
          f"{len(incomplete)} keys missing ja/en" if incomplete else f"{len(keys)} keys have ja+en")


# 7. Legal site links --------------------------------------------------------
def c_site() -> None:
    import os
    pages = glob.glob(str(SITE / "**/*.html"), recursive=True)
    broken, absolute = [], []
    for pg in pages:
        d = os.path.dirname(pg)
        for href in re.findall(r'href="([^"]+)"', Path(pg).read_text(encoding="utf-8")):
            if href.startswith(("http://", "https://", "mailto:", "#", "data:")):
                continue
            if href.startswith("/"):
                absolute.append((Path(pg).name, href))
                continue
            target = os.path.normpath(os.path.join(d, href))
            if not (os.path.exists(target) or os.path.exists(os.path.join(target, "index.html"))):
                broken.append((Path(pg).name, href))
    check("site-links", not broken and not absolute,
          (f"broken={broken[:3]} " if broken else "") + (f"root-absolute={absolute[:3]}" if absolute else "")
          or f"{len(pages)} pages, links relative & resolve")


# 8. Preview data sync -------------------------------------------------------
def c_preview() -> None:
    if not PREVIEW_DATA.exists():
        check("preview-sync", False, "docs/preview/data.json missing (run extract_fixtures.py)")
        return
    with tempfile.NamedTemporaryFile("r", suffix=".json", delete=False) as tf:
        tmp = tf.name
    r = subprocess.run([sys.executable, str(ROOT / "scripts/extract_fixtures.py"), "--out", tmp],
                       capture_output=True, text=True)
    if r.returncode != 0:
        check("preview-sync", False, r.stderr.strip() or "extractor failed")
        return
    fresh = Path(tmp).read_text(encoding="utf-8")
    committed = PREVIEW_DATA.read_text(encoding="utf-8")
    check("preview-sync", fresh == committed,
          "data.json out of sync — run scripts/extract_fixtures.py"
          if fresh != committed else "in sync with fixtures")


# strict: release readiness --------------------------------------------------
def c_readiness() -> None:
    r = subprocess.run([sys.executable, str(ROOT / "scripts/release_readiness.py"), "--strict"],
                       capture_output=True, text=True)
    check("release-readiness (strict)", r.returncode == 0,
          "manual App Store gates remain open" if r.returncode else "all gates pass")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--strict", action="store_true",
                    help="also enforce App Store release-readiness gates")
    args = ap.parse_args()

    for fn in (c_python, c_resources, c_pbxproj, c_sources, c_catalog, c_site, c_preview):
        try:
            fn()
        except Exception as e:  # a check crashing is itself a failure
            check(fn.__name__, False, f"check crashed: {e}")
    if args.strict:
        c_readiness()

    width = max(len(n) for n, _, _ in results)
    print("SkyTrace preflight\n" + "-" * (width + 12))
    hard_fail = False
    for name, ok, detail in results:
        icon = "PASS" if ok else "FAIL"
        if not ok and name != "release-readiness (strict)":
            hard_fail = True
        print(f"  [{icon}] {name.ljust(width)}  {detail}")
    print("-" * (width + 12))
    readiness_fail = any(not ok for n, ok, _ in results if n == "release-readiness (strict)")
    print("RESULT:", "FAIL" if (hard_fail or (args.strict and readiness_fail)) else "PASS")
    return 1 if (hard_fail or (args.strict and readiness_fail)) else 0


if __name__ == "__main__":
    raise SystemExit(main())
