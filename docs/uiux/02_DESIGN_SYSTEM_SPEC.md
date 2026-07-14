# SkyTrace Design System Specification

## 1. System name

**Aether Editorial System**

A semantic design system for three visual materials:

- Atmosphere — contextual world layer;
- Glass — controls and navigation layer;
- Editorial — reading and evidence layer.

All implementation uses semantic tokens. Feature code must not hard-code hex colors, radii, spacing, or font sizes.

## 2. Color system

### 2.1 Semantic token names

```swift
SkyColor.canvas
SkyColor.atmosphereTop
SkyColor.atmosphereBottom
SkyColor.surfacePrimary
SkyColor.surfaceSecondary
SkyColor.surfaceElevated
SkyColor.textPrimary
SkyColor.textSecondary
SkyColor.textTertiary
SkyColor.separator
SkyColor.accentPrimary
SkyColor.accentSecondary
SkyColor.signalWarm
SkyColor.statusNew
SkyColor.statusReview
SkyColor.statusInsufficient
SkyColor.statusLikelyKnown
SkyColor.statusExplained
SkyColor.statusDisputed
SkyColor.statusCorrected
SkyColor.error
SkyColor.warning
SkyColor.success
```

### 2.2 Dark appearance baseline

| Token | Value | Use |
|---|---:|---|
| canvas | `#070C12` | root background |
| atmosphereTop | `#0B1621` | upper sky field |
| atmosphereBottom | `#091018` | lower atmospheric field |
| surfacePrimary | `#101923` | article and principal surface |
| surfaceSecondary | `#131F29` | grouped background |
| surfaceElevated | `#182631` | selected or raised content |
| textPrimary | `#F2F5F7` | main text |
| textSecondary | `#AAB6C1` | supporting text |
| textTertiary | `#7C8995` | metadata; do not use below footnote size |
| separator | `#2A3945` | subtle rules |
| accentPrimary | `#5FD4C8` | primary atmospheric accent |
| accentSecondary | `#78BDF2` | location, links, secondary highlight |
| signalWarm | `#E2C17B` | time, meaningful change, historic note |
| error | `#FF7777` | destructive/error only |
| warning | `#F1B765` | caution |
| success | `#73D39B` | completed/available, not “truth” |

Contrast targets on the root canvas:

- textPrimary: approximately 17.9:1;
- textSecondary: approximately 9.5:1;
- textTertiary: approximately 5.5:1;
- accentPrimary: approximately 11:1.

### 2.3 Light appearance baseline

| Token | Value | Use |
|---|---:|---|
| canvas | `#F4F8FA` | daylight atmosphere |
| atmosphereTop | `#EAF4F8` | upper sky field |
| atmosphereBottom | `#F8FAF7` | horizon/daylight field |
| surfacePrimary | `#FFFFFF` | article and principal surface |
| surfaceSecondary | `#EEF4F6` | grouped background |
| surfaceElevated | `#E5EEF1` | selected or raised content |
| textPrimary | `#14212A` | main text |
| textSecondary | `#51616C` | supporting text |
| textTertiary | `#687985` | metadata |
| separator | `#CBD7DC` | subtle rules |
| accentPrimary | `#087A73` | controls, links, selected state |
| accentSecondary | `#176FA3` | map and secondary link |
| signalWarm | `#8B651C` | time and meaningful change |
| error | `#B4232B` | destructive/error only |
| warning | `#8A5A00` | caution |
| success | `#257A4E` | completion/availability |

### 2.4 Color rules

- Background and neutral surfaces occupy roughly 80% of the screen.
- Primary accent roughly 12%; warm signal roughly 5%; status colors collectively 3% or less.
- Never place long body text in accent colors.
- Never encode case state only through hue.
- Red is not used to make a report feel urgent or mysterious.
- Background gradients must derive from atmosphere and time, not generic purple/blue presets.
- When Increase Contrast is enabled, reduce transparency and use stronger separators and surface differentiation.

## 3. Status geometry

Each status has a glyph, text label, and optional color.

| Status | Geometry | Motion | Meaning |
|---|---|---|---|
| New report | central point + thin closed ring | one arrival transition only | newly added report |
| Under review | open ring + small index tick | none by default | active review |
| Information insufficient | open ring with a gap | none | critical information missing |
| Known explanation likely | half-filled circle / semicircle | none | known explanation fits much evidence |
| Explained | compact diamond | none | explanation supported sufficiently |
| Disputed | two offset arcs | none | major source or interpretation conflict |
| Corrected | diamond with small revision mark | one change transition | record corrected |
| Archived | small square outline | none | retained record, no active update |

### Geometry rules

- The same glyph appears on map, rows, detail header, timeline, widgets, and VoiceOver descriptions.
- Do not change meanings between features.
- Minimum visible glyph size: 12 pt; interactive container at least 44 × 44 pt.
- At large Dynamic Type, label text becomes primary and glyph secondary.

## 4. Typography

### 4.1 Font policy

Use system fonts only in v1.

- UI and metadata: system default sans-serif.
- Editorial display headings: system serif design where supported.
- Body copy: system body text, generally sans-serif for maximum legibility; serif may be an optional reading preference later.
- Numbers: monospaced digits only when alignment or comparison benefits.

### 4.2 Semantic styles

| Role | SwiftUI baseline | Notes |
|---|---|---|
| Hero date / context | `.title3` or `.headline` | compact; never logo-sized |
| World summary | `.title2.weight(.semibold)` | max 2–3 lines |
| Screen title | `.largeTitle.weight(.bold)` | use standard navigation behavior |
| Editorial headline | `.title.fontDesign(.serif).weight(.semibold)` | readable, not ornamental |
| Section title | `.title3.weight(.semibold)` | clear hierarchy |
| Card/row title | `.headline` | max 3 lines |
| Body | `.body` | primary prose |
| Supporting body | `.callout` | short summaries |
| Metadata | `.footnote` | never essential by size alone |
| Caption | `.caption` | optional supporting detail only |

### 4.3 Typography rules

- Prefer semantic Dynamic Type styles over fixed point sizes.
- Support all accessibility sizes through AX5.
- Never truncate a case title on Case Detail.
- Compact lists may cap titles at three lines only when the full title is available after opening.
- Minimum body line spacing target: roughly 1.25–1.4× depending on text style.
- Long-form reading width on wide layouts: 560–680 pt.
- Do not center long text.
- Avoid all caps for Japanese. English overlines may use short uppercase labels sparingly.
- Use tabular/monospaced digits for timeline times and comparative quantities.

## 5. Spacing and layout

### 5.1 Base grid

4 pt base grid.

```text
space1  = 4
space2  = 8
space3  = 12
space4  = 16
space5  = 20
space6  = 24
space8  = 32
space10 = 40
space12 = 48
space16 = 64
```

### 5.2 Screen margins

- Compact iPhone: 16 pt standard; 20 pt editorial sections where space allows.
- Large iPhone: 20 pt.
- iPad compact column: 24–32 pt.
- Long-form max-width centered in regular width.

### 5.3 Vertical rhythm

- Section-to-section: 32–48 pt.
- Heading-to-content: 12–16 pt.
- Row internal padding: 12–16 pt.
- Major hero-to-editorial transition: 24–32 pt with a clear material change.

## 6. Shape and radius

| Token | Value | Use |
|---|---:|---|
| radiusSmall | 8 | small labels, thumbnail corners |
| radiusControl | 12 | buttons and segmented controls |
| radiusCard | 16 | true independent cards only |
| radiusPanel | 24 | major sheet/panel |
| radiusCapsule | full | filters and compact status chips |

Rules:

- Do not put every section inside a rounded rectangle.
- Editorial sections are primarily separated through spacing, typography, and rules.
- Use cards only for independent, tappable units or content requiring a distinct background.
- Nested cards are prohibited unless a clear interaction requires them.

## 7. Materials

### 7.1 Atmosphere

Use for:

- World Sky Pulse;
- map background context;
- launch continuity;
- widget visual field.

Characteristics:

- very subtle gradient;
- low-frequency, data-linked changes;
- no star-photo wallpaper;
- no continuous particle simulation;
- static or simplified fallback under Reduce Motion, Low Power Mode, or thermal pressure.

### 7.2 Glass

Use for:

- system tab bar;
- navigation controls;
- map filters;
- search controls;
- temporary floating controls;
- sheet control chrome.

Rules:

- prefer standard SwiftUI components that inherit platform material;
- custom Liquid Glass only when a standard component cannot express the interaction;
- never stack multiple glass layers;
- provide an opaque/high-contrast alternative for Reduce Transparency and Increase Contrast;
- do not tint large glass surfaces heavily.

### 7.3 Editorial Surface

Use for:

- case reading;
- evidence explanations;
- sources;
- long-form;
- methodology;
- paywall details;
- settings.

Characteristics:

- stable background;
- minimal visual noise;
- no image directly beneath body text;
- generous spacing;
- visible hierarchy under all appearance and accessibility settings.

## 8. Elevation and shadow

Prefer material and contrast over drop shadow.

- Default editorial sections: no shadow.
- Floating controls: system material handles separation.
- Major bottom sheet: system shadow/elevation.
- Custom shadow, if required: soft, low opacity, one level only.
- No neon glow around text or cards.
- Signal points may use a small luminance halo but never to encode meaning by glow alone.

## 9. Iconography

- Use SF Symbols for standard actions.
- Use custom status glyphs only for the stable case vocabulary.
- Symbols require accessibility labels when meaning is not adjacent in text.
- Do not mix outline styles inconsistently.
- Avoid UFO saucers, alien heads, military reticles, and radar icons in primary navigation.
- Navigation suggestions:
  - Today: `sparkles.rectangle.stack` or a simpler editorial/world symbol chosen after testing;
  - Map: `map`;
  - Search: `magnifyingglass`;
  - Settings: `gearshape`.
- Final symbols must be checked in current SF Symbols and should not depend on a symbol unavailable at the chosen deployment target.

## 10. Imagery and media

- A case card must work without an image.
- Media is evidence, not decoration.
- Preserve aspect ratio and show provenance/context near media.
- Mark illustrative or reconstructed imagery explicitly.
- Do not crop evidence media in a way that removes relevant context; allow full-view inspection.
- Sensitive or low-quality media should not be artificially sharpened in a way that implies added evidence.

## 11. Controls

- Minimum touch target: 44 × 44 pt.
- Primary button labels describe the action: “地図で見る,” “更新を追跡,” “出典を開く.”
- Avoid generic “OK” where a specific label is possible.
- Destructive actions use confirmation only when consequences are meaningful.
- Filter chips are concise and removable; advanced filter complexity lives in a sheet.
- Menus are used for secondary actions, not core navigation.

## 12. Dividers and rules

The visual metaphor is editorial, not spreadsheet.

- Use short or inset rules where possible.
- Full-width separators only for dense source or settings lists.
- Warm accent rules may denote time or revision history sparingly.
- Never use thick borders around every component.

## 13. Design token implementation

Recommended structure:

```text
DesignSystem/
  Color/
    SkyColor.swift
    Assets.xcassets
  Typography/
    SkyTypography.swift
  Spacing/
    SkySpacing.swift
  Shape/
    SkyShape.swift
  Material/
    SkyMaterial.swift
  Motion/
    SkyMotion.swift
  Components/
    ...
```

Tokens are referenced semantically. A feature must not use `Color(hex:)` or literal padding values except in a documented one-off visual calculation.

