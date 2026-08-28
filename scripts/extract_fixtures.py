#!/usr/bin/env python3
"""Extract the SkyTrace demo fixtures into JSON for the browser preview.

The iOS app cannot compile on Linux, so this parses the Swift demo fixtures
(the single source of truth for the preview's content) into a JSON document the
static web preview (`docs/preview/`) renders. It reads:

  - Data/Fixtures/DemoCases.swift    → the 9 demo cases (UAPCase(...))
  - Data/Fixtures/DemoFeed.swift     → the daily briefing + global summary
  - Data/Fixtures/DemoArticles.swift → the 3 AI-synthesised articles
  - Resources/Localizable.xcstrings  → Japanese labels for statuses/enums

Nothing here is invented: every string comes from the committed fixtures. The
parser is intentionally strict — if the fixture shape changes it will surface a
mismatch (see scripts/preflight.py, which asserts all 9 cases are extracted).

Usage:  python3 scripts/extract_fixtures.py [--out docs/preview/data.json]
"""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
IOS = ROOT / "apps/ios/SkyTrace"
FIX = IOS / "Data/Fixtures"
CATALOG = IOS / "Resources/Localizable.xcstrings"

# Fixed "today" anchor for the demo data (FixtureClock.today).
ANCHOR = "2026-07-13T22:40:00"


# ---------------------------------------------------------------------------
# Low-level Swift literal helpers
# ---------------------------------------------------------------------------
def balanced(text: str, open_idx: int, open_ch="(", close_ch=")") -> str:
    """Return the substring between the paren at open_idx and its match."""
    depth = 0
    i = open_idx
    in_str = False
    esc = False
    while i < len(text):
        c = text[i]
        if in_str:
            if esc:
                esc = False
            elif c == "\\":
                esc = True
            elif c == '"':
                in_str = False
        else:
            if c == '"':
                in_str = True
            elif c == open_ch:
                depth += 1
            elif c == close_ch:
                depth -= 1
                if depth == 0:
                    return text[open_idx + 1:i]
        i += 1
    raise ValueError("unbalanced parens")


def split_top(argstr: str) -> list[str]:
    """Split a Swift argument list on top-level commas."""
    parts, buf, depth, in_str, esc = [], [], 0, False, False
    for c in argstr:
        if in_str:
            buf.append(c)
            if esc:
                esc = False
            elif c == "\\":
                esc = True
            elif c == '"':
                in_str = False
            continue
        if c == '"':
            in_str = True
            buf.append(c)
        elif c in "([{":
            depth += 1
            buf.append(c)
        elif c in ")]}":
            depth -= 1
            buf.append(c)
        elif c == "," and depth == 0:
            parts.append("".join(buf).strip())
            buf = []
        else:
            buf.append(c)
    if "".join(buf).strip():
        parts.append("".join(buf).strip())
    return parts


_UNESCAPE = {'\\"': '"', "\\\\": "\\", "\\n": "\n", "\\t": "\t", "\\'": "'"}


def unquote(tok: str) -> str:
    tok = tok.strip()
    if tok.startswith('"') and tok.endswith('"'):
        inner = tok[1:-1]
        return re.sub(r'\\["\\nt\']', lambda m: _UNESCAPE[m.group(0)], inner)
    return tok


def str_array(tok: str) -> list[str]:
    tok = tok.strip()
    if not (tok.startswith("[") and tok.endswith("]")):
        return []
    return [unquote(p) for p in split_top(tok[1:-1]) if p.strip()]


def fx_calls(block: str, fname: str) -> list[list[str]]:
    """Return the split argument lists of every `Fx.<fname>(...)` in block."""
    out = []
    for m in re.finditer(r"Fx\." + re.escape(fname) + r"\(", block):
        args = balanced(block, m.end() - 1)
        out.append(split_top(args))
    return out


def named(args: list[str], key: str) -> str | None:
    for a in args:
        if a.startswith(key + ":"):
            return a[len(key) + 1:].strip()
    return None


def positional(args: list[str]) -> list[str]:
    return [a for a in args if not re.match(r"^[A-Za-z_]\w*:", a)]


# ---------------------------------------------------------------------------
# Field helpers
# ---------------------------------------------------------------------------
def scalar_str(block: str, field: str) -> str | None:
    m = re.search(field + r':\s*"((?:\\.|[^"\\])*)"', block)
    return unquote('"' + m.group(1) + '"') if m else None


def scalar_num(block: str, field: str):
    m = re.search(field + r":\s*(-?\d+(?:\.\d+)?)", block)
    if not m:
        return None
    v = m.group(1)
    return float(v) if "." in v else int(v)


def scalar_enum(block: str, field: str) -> str | None:
    m = re.search(field + r":\s*\.(\w+)", block)
    return m.group(1) if m else None


def date_field(block: str, field: str) -> dict | None:
    m = re.search(
        field + r":\s*FixtureClock\.day\(\s*(-?\d+)\s*"
        r"(?:,\s*hour:\s*(\d+))?\s*(?:,\s*minute:\s*(\d+))?\s*\)",
        block,
    )
    if not m:
        return None
    return {"day": int(m.group(1)),
            "hour": int(m.group(2)) if m.group(2) else 21,
            "minute": int(m.group(3)) if m.group(3) else 0}


# ---------------------------------------------------------------------------
# Parsers
# ---------------------------------------------------------------------------
def parse_cases(text: str) -> list[dict]:
    cases = []
    for m in re.finditer(r"static let (\w+)\s*=\s*UAPCase\(", text):
        block = balanced(text, m.end() - 1)
        c = {
            "var": m.group(1),
            "id": scalar_str(block, "id"),
            "slug": scalar_str(block, "slug"),
            "title": scalar_str(block, "title"),
            "summary": scalar_str(block, "summary"),
            "status": scalar_enum(block, "status"),
            "countryCode": scalar_str(block, "countryCode"),
            "regionName": scalar_str(block, "regionName"),
            "localityName": scalar_str(block, "localityName"),
            "latitude": scalar_num(block, "latitude"),
            "longitude": scalar_num(block, "longitude"),
            "locationPrecision": scalar_enum(block, "locationPrecision"),
            "sourceCount": scalar_num(block, "sourceCount"),
            "independentReportCount": scalar_num(block, "independentReportCount"),
            "currentAssessment": scalar_str(block, "currentAssessment"),
            "occurredAtStart": date_field(block, "occurredAtStart"),
            "occurredAtEnd": date_field(block, "occurredAtEnd"),
            "publishedAt": date_field(block, "publishedAt"),
            "lastVerifiedAt": date_field(block, "lastVerifiedAt"),
            "updatedAt": date_field(block, "updatedAt"),
        }
        sm = re.search(
            r"scores:\s*CaseScores\(\s*evidenceQuality:\s*(\d+),\s*"
            r"independence:\s*(\d+),\s*knownPhenomenaMatch:\s*(\d+),\s*"
            r"unresolvedness:\s*(\d+)", block)
        if sm:
            c["scores"] = {
                "evidenceQuality": int(sm.group(1)),
                "independence": int(sm.group(2)),
                "knownPhenomenaMatch": int(sm.group(3)),
                "unresolvedness": int(sm.group(4)),
            }
        stm = re.search(r"shapeTags:\s*(\[[^\]]*\])", block)
        c["shapeTags"] = str_array(stm.group(1)) if stm else []

        c["agreements"] = [unquote(positional(a)[1]) for a in fx_calls(block, "agree")]
        c["contradictions"] = [unquote(positional(a)[1]) for a in fx_calls(block, "contra")]
        c["missingInformation"] = [unquote(positional(a)[1]) for a in fx_calls(block, "gap")]

        cands = []
        for a in fx_calls(block, "candidate"):
            pos = positional(a)
            cands.append({
                "category": pos[1].lstrip("."),
                "label": unquote(pos[2]),
                "matchScore": int(pos[3]),
                "match": str_array(named(a, "match") or "[]"),
                "nonMatch": str_array(named(a, "nonMatch") or "[]"),
                "limits": unquote(named(a, "limits")) if named(a, "limits") else None,
                "excluded": (named(a, "excluded") == "true"),
            })
        c["explanationCandidates"] = cands

        srcs = []
        for a in fx_calls(block, "source"):
            pos = positional(a)
            srcs.append({
                "id": unquote(pos[0]),
                "outlet": unquote(pos[1]),
                "type": pos[2].lstrip("."),
                "title": unquote(pos[3]),
                "role": (named(a, "role") or ".supports").lstrip("."),
            })
        c["sources"] = srcs

        tl = []
        for a in fx_calls(block, "timeline"):
            pos = positional(a)
            tl.append({
                "daysAgo": int(pos[1]),
                "summary": unquote(pos[2]),
                "status": (named(a, "status") or "").lstrip("."),
                "scoreNote": unquote(named(a, "scoreNote")) if named(a, "scoreNote") else None,
            })
        c["timeline"] = tl
        cases.append(c)
    return cases


def parse_article_blocks(block_list_src: str) -> list[dict]:
    blocks = []
    # Preserve order: scan for any Fx.<kind>( across the blocks region.
    for m in re.finditer(r"Fx\.(heading|fact|inference|unknown)\(", block_list_src):
        kind = m.group(1)
        args = split_top(balanced(block_list_src, m.end() - 1))
        pos = positional(args)
        b = {"kind": kind, "text": unquote(pos[1]),
             "gated": named(args, "gated") == "true"}
        if kind == "inference":
            conf = named(args, "confidence")
            b["confidence"] = float(conf) if conf else None
            b["gated"] = named(args, "gated") != "false"
        blocks.append(b)
    return blocks


def parse_articles(text: str) -> dict:
    out = {}
    for m in re.finditer(r"static let (\w+)\s*=\s*SynthesizedArticle\(", text):
        block = balanced(text, m.end() - 1)
        case_id = scalar_str(block, "caseID")
        bm = re.search(r"blocks:\s*\[", block)
        blocks_src = balanced(block, bm.end() - 1, "[", "]") if bm else ""
        out[case_id] = {
            "headline": scalar_str(block, "headline"),
            "dek": scalar_str(block, "dek"),
            "versionNumber": scalar_num(block, "versionNumber"),
            "readingMinutes": scalar_num(block, "readingMinutes"),
            "disclosure": scalar_enum(block, "disclosure"),
            "correctionNote": scalar_str(block, "correctionNote"),
            "blocks": parse_article_blocks(blocks_src),
        }
    return out


def parse_feed(text: str) -> dict:
    bm = re.search(r"briefing\s*=\s*DailyBriefing\(", text)
    bblock = balanced(text, bm.end() - 1)
    toc_m = re.search(r"tableOfContents:\s*(\[[^\]]*\])", bblock)
    blocks_m = re.search(r"blocks:\s*\[", bblock)
    blocks_src = balanced(bblock, blocks_m.end() - 1, "[", "]") if blocks_m else ""
    tw_m = re.search(r"tomorrowWatch:\s*(\[[^\]]*\])", bblock)
    briefing = {
        "headline": scalar_str(bblock, "headline"),
        "summary": scalar_str(bblock, "summary"),
        "tableOfContents": str_array(toc_m.group(1)) if toc_m else [],
        "blocks": parse_article_blocks(blocks_src),
        "sourceCount": scalar_num(bblock, "sourceCount"),
        "usedCaseCount": scalar_num(bblock, "usedCaseCount"),
        "readingMinutes": scalar_num(bblock, "readingMinutes"),
        "disclosure": scalar_enum(bblock, "disclosure"),
        "tomorrowWatch": str_array(tw_m.group(1)) if tw_m else [],
    }
    sm = re.search(r"summary\s*=\s*GlobalSummary\(", text)
    sblock = balanced(text, sm.end() - 1)
    summary = {
        "newReportCount": scalar_num(sblock, "newReportCount"),
        "mergedCaseCount": scalar_num(sblock, "mergedCaseCount"),
        "likelyExplainedCount": scalar_num(sblock, "likelyExplainedCount"),
        "insufficientDataCount": scalar_num(sblock, "insufficientDataCount"),
        "notableUnresolvedCount": scalar_num(sblock, "notableUnresolvedCount"),
    }
    top_m = re.search(r"topCases\s*=?\s*\[([^\]]*)\]", text) or \
        re.search(r"let top\s*=\s*\[([\s\S]*?)\]", text)
    top = []
    if top_m:
        for t in top_m.group(1).split(","):
            t = t.strip().replace("DemoCases.", "")
            if t:
                top.append(t)
    return {"briefing": briefing, "summary": summary, "topVars": top}


def catalog_labels() -> dict:
    cat = json.loads(CATALOG.read_text(encoding="utf-8"))
    strings = cat.get("strings", {})

    def ja(key: str) -> str | None:
        node = strings.get(key, {}).get("localizations", {}).get("ja", {})
        return node.get("stringUnit", {}).get("value")

    prefixes = ("case.status.", "location.precision.", "source.type.",
                "evidence.role.", "explanation.category.", "ai.disclosure.",
                "tab.", "today.", "map.", "research.", "settings.")
    labels = {}
    for k in strings:
        if k.startswith(prefixes):
            v = ja(k)
            if v:
                labels[k] = v
    return labels


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", type=Path, default=ROOT / "docs/preview/data.json")
    args = ap.parse_args()

    cases = parse_cases((FIX / "DemoCases.swift").read_text(encoding="utf-8"))
    articles = parse_articles((FIX / "DemoArticles.swift").read_text(encoding="utf-8"))
    feed = parse_feed((FIX / "DemoFeed.swift").read_text(encoding="utf-8"))
    labels = catalog_labels()

    var_to_id = {c["var"]: c["id"] for c in cases}
    feed["topCaseIDs"] = [var_to_id.get(v) for v in feed.get("topVars", []) if var_to_id.get(v)]

    doc = {
        "anchor": ANCHOR,
        "generatedFrom": "apps/ios/SkyTrace/Data/Fixtures (Swift source of truth)",
        "labels": labels,
        "summary": feed["summary"],
        "briefing": feed["briefing"],
        "topCaseIDs": feed["topCaseIDs"],
        "cases": cases,
        "articles": articles,
    }

    out = args.out if args.out.is_absolute() else ROOT / args.out
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Extracted {len(cases)} cases, {len(articles)} articles, "
          f"{len(labels)} labels → {out.relative_to(ROOT)}")
    return 0 if len(cases) == 9 else 1


if __name__ == "__main__":
    raise SystemExit(main())
