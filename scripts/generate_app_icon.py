#!/usr/bin/env python3
"""Generate the SkyTrace App Icon as a 1024x1024 RGB PNG (no alpha).

App Store icons must be square, fully opaque (no alpha channel), and have no
rounded corners (the system rounds them). This renders the brand motif — a
luminous "observation aperture" (lens/scan ring) tracing a single point of
light against a deep night sky — using only the Python standard library, so it
runs anywhere without Pillow/ImageMagick.

Palette is drawn from DesignSystem/SkyColor (dark world):
  zenith  #04070E   atmosphere #0B1621   accentPrimary #5FD4C8
  aetherGlow #7FE6DC   auroraViolet #6E5CC8   starField #CED8EC

Output: apps/ios/SkyTrace/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png
"""
import math
import struct
import zlib
from pathlib import Path

N = 1024
ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "apps/ios/SkyTrace/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"


def clamp(x, lo=0.0, hi=1.0):
    return lo if x < lo else hi if x > hi else x


def smoothstep(edge0, edge1, x):
    t = clamp((x - edge0) / (edge1 - edge0))
    return t * t * (3 - 2 * t)


def mix(a, b, t):
    return (a[0] + (b[0] - a[0]) * t,
            a[1] + (b[1] - a[1]) * t,
            a[2] + (b[2] - a[2]) * t)


def add(a, b, s=1.0):
    return (a[0] + b[0] * s, a[1] + b[1] * s, a[2] + b[2] * s)


# Colors as 0..1 floats.
ZENITH = (0x04 / 255, 0x07 / 255, 0x0E / 255)
ATMO = (0x0B / 255, 0x16 / 255, 0x21 / 255)
HORIZON = (0x11 / 255, 0x1E / 255, 0x2B / 255)
ACCENT = (0x5F / 255, 0xD4 / 255, 0xC8 / 255)
GLOW = (0x7F / 255, 0xE6 / 255, 0xDC / 255)
VIOLET = (0x6E / 255, 0x5C / 255, 0xC8 / 255)
STAR = (0xCE / 255, 0xD8 / 255, 0xEC / 255)

# Deterministic starfield: (x, y in 0..1, brightness 0..1, radius px).
STARS = [
    (0.18, 0.16, 0.9, 2.2), (0.30, 0.10, 0.5, 1.6), (0.12, 0.34, 0.6, 1.8),
    (0.83, 0.14, 0.8, 2.4), (0.90, 0.28, 0.45, 1.5), (0.74, 0.09, 0.55, 1.7),
    (0.22, 0.80, 0.5, 1.6), (0.14, 0.66, 0.7, 2.0), (0.35, 0.90, 0.4, 1.4),
    (0.86, 0.82, 0.7, 2.1), (0.92, 0.66, 0.5, 1.6), (0.70, 0.90, 0.55, 1.7),
    (0.50, 0.06, 0.6, 1.8), (0.62, 0.20, 0.35, 1.3), (0.08, 0.50, 0.5, 1.6),
    (0.95, 0.48, 0.6, 1.8), (0.42, 0.74, 0.3, 1.2), (0.58, 0.86, 0.4, 1.4),
]

# Aperture geometry (in normalized units where 1.0 == half the canvas).
CX, CY = 0.5, 0.52          # slightly below center for optical balance
R_INNER = 0.30              # main scan ring radius
R_OUTER = 0.42             # faint outer ring radius
RING_W = 0.018             # main ring half-width
OUTER_W = 0.006
# Traced point of light, sitting on the main ring toward the upper right.
P_ANG = math.radians(-52)
PX = CX + R_INNER * math.cos(P_ANG)
PY = CY + R_INNER * math.sin(P_ANG)


def shade(px, py):
    """Return an (r,g,b) 0..1 color for pixel center in 0..1 coordinates."""
    # Vertical sky gradient with a gentle radial darkening toward the corners.
    v = py
    base = mix(ZENITH, ATMO, smoothstep(0.0, 0.62, v))
    base = mix(base, HORIZON, smoothstep(0.62, 1.0, v) * 0.6)

    # Aurora wash near lower third (very low opacity, decorative).
    aur = smoothstep(0.55, 1.0, v) * (0.10 + 0.06 * math.sin(px * math.pi))
    col = mix(base, VIOLET, clamp(aur) * 0.35)

    # Coordinates centered on the aperture, in half-canvas units.
    dx = (px - CX)
    dy = (py - CY)
    dist = math.hypot(dx, dy)

    # Starfield (draw only outside the aperture area so it stays clean).
    if dist > R_OUTER + 0.03:
        for sx, sy, sb, sr in STARS:
            sdx = (px - sx) * N
            sdy = (py - sy) * N
            d2 = sdx * sdx + sdy * sdy
            r2 = sr * sr
            if d2 < (r2 * 9):
                fall = math.exp(-d2 / (2 * r2))
                col = add(col, STAR, sb * fall * 0.9)

    # Faint outer scan ring.
    outer = math.exp(-((dist - R_OUTER) ** 2) / (2 * OUTER_W ** 2))
    col = add(col, ACCENT, outer * 0.30)

    # Main luminous ring: bright core + soft outer glow.
    ring = math.exp(-((dist - R_INNER) ** 2) / (2 * RING_W ** 2))
    # Angular brightening so the ring reads as a sweep (brighter near the point).
    ang = math.atan2(dy, dx)
    sweep = 0.55 + 0.45 * math.cos(ang - P_ANG)
    col = add(col, GLOW, ring * (0.55 + 0.45 * sweep))

    # Broad soft halo inside the ring (aperture depth).
    halo = math.exp(-(dist ** 2) / (2 * (R_INNER * 0.85) ** 2))
    col = add(col, ACCENT, halo * 0.05)

    # The traced point of light with a tight core and a wider bloom.
    pdx = (px - PX) * N
    pdy = (py - PY) * N
    pd2 = pdx * pdx + pdy * pdy
    core = math.exp(-pd2 / (2 * (7.0 ** 2)))
    bloom = math.exp(-pd2 / (2 * (34.0 ** 2)))
    col = add(col, (1.0, 1.0, 1.0), core * 0.95)
    col = add(col, GLOW, bloom * 0.55)

    # Subtle vignette to keep the corners from feeling flat.
    vig = 1.0 - 0.18 * smoothstep(0.55, 1.05, math.hypot(px - 0.5, py - 0.5) * 1.41)
    col = (col[0] * vig, col[1] * vig, col[2] * vig)

    return col


def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)
    raw = bytearray()
    for y in range(N):
        raw.append(0)  # filter type 0 for this scanline
        py = (y + 0.5) / N
        row = bytearray()
        for x in range(N):
            px = (x + 0.5) / N
            r, g, b = shade(px, py)
            row.append(int(clamp(r) * 255 + 0.5))
            row.append(int(clamp(g) * 255 + 0.5))
            row.append(int(clamp(b) * 255 + 0.5))
        raw.extend(row)

    def chunk(tag, data):
        c = struct.pack(">I", len(data)) + tag + data
        crc = zlib.crc32(tag + data) & 0xFFFFFFFF
        return c + struct.pack(">I", crc)

    ihdr = struct.pack(">IIBBBBB", N, N, 8, 2, 0, 0, 0)  # 8-bit, color type 2 (RGB)
    png = (b"\x89PNG\r\n\x1a\n"
           + chunk(b"IHDR", ihdr)
           + chunk(b"IDAT", zlib.compress(bytes(raw), 9))
           + chunk(b"IEND", b""))
    OUT.write_bytes(png)
    print(f"Wrote {OUT} ({len(png)} bytes, {N}x{N} RGB no-alpha)")


if __name__ == "__main__":
    main()
