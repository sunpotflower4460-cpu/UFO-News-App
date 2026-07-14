#!/usr/bin/env python3
"""Rename xcresulttool-exported attachments to their human-readable names.

Usage: rename_screenshots.py <export_dir> <output_dir>

`xcrun xcresulttool export attachments` writes UUID-named files plus a
manifest.json mapping each to a suggestedHumanReadableName (the XCTAttachment
name). We copy the PNG attachments to <output_dir>/<name>.png.
"""
import json
import os
import re
import shutil
import sys

src, dst = sys.argv[1], sys.argv[2]
os.makedirs(dst, exist_ok=True)

manifest_path = os.path.join(src, "manifest.json")
copied = 0
if os.path.exists(manifest_path):
    with open(manifest_path) as f:
        data = json.load(f)
    # manifest is a list of per-test entries, each with an "attachments" list.
    entries = data if isinstance(data, list) else data.get("attachments", [])
    for entry in entries:
        atts = entry.get("attachments", []) if isinstance(entry, dict) else []
        if not atts and isinstance(entry, dict) and "exportedFileName" in entry:
            atts = [entry]
        for att in atts:
            exported = att.get("exportedFileName") or att.get("fileName")
            name = att.get("suggestedHumanReadableName") or att.get("name") or exported
            if not exported:
                continue
            src_file = os.path.join(src, exported)
            if not os.path.exists(src_file):
                continue
            base = re.sub(r"[^A-Za-z0-9_.-]", "_", name)
            if not base.lower().endswith(".png"):
                base += ".png"
            shutil.copyfile(src_file, os.path.join(dst, base))
            copied += 1

# Fallback: if nothing was mapped, copy any PNGs found.
if copied == 0:
    for fn in sorted(os.listdir(src)):
        if fn.lower().endswith(".png"):
            shutil.copyfile(os.path.join(src, fn), os.path.join(dst, fn))
            copied += 1

print(f"Copied {copied} screenshot(s) to {dst}")
