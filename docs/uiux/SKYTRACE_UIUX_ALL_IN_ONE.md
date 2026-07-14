# SkyTrace UI/UX Blueprint — All in One

This consolidated file contains the complete implementation blueprint. The separate files remain the canonical modular handoff.

## Contents

- [00_README_UIUX_PACKAGE.md](#00-readme-uiux-package)
- [01_UI_UX_MASTER_PLAN.md](#01-ui-ux-master-plan)
- [02_DESIGN_SYSTEM_SPEC.md](#02-design-system-spec)
- [03_SCREEN_BLUEPRINTS.md](#03-screen-blueprints)
- [04_COMPONENT_INVENTORY_AND_STATE_MATRIX.md](#04-component-inventory-and-state-matrix)
- [05_MOTION_HAPTICS_SOUND_SPEC.md](#05-motion-haptics-sound-spec)
- [06_ACCESSIBILITY_ADAPTIVE_LAYOUT.md](#06-accessibility-adaptive-layout)
- [07_APP_ICON_STORE_SURFACE.md](#07-app-icon-store-surface)
- [08_UI_QUALITY_GATES.md](#08-ui-quality-gates)
- [09_CLAUDE_CODE_IMPLEMENTATION_PLAN.md](#09-claude-code-implementation-plan)
- [10_CLAUDE_CODE_KICKOFF_PROMPT.md](#10-claude-code-kickoff-prompt)
- [11_OFFICIAL_REFERENCES.md](#11-official-references)
- [12_導入ガイド_日本語.md](#12-導入ガイド-日本語)
- [13_UIUXマスター概要_日本語.md](#13-uiuxマスター概要-日本語)

---

<a id="00-readme-uiux-package"></a>

# SkyTrace UI/UX Blueprint Package

**Status:** Fourth-pass implementation blueprint  
**Platform:** iPhone-first native iOS app; iPad-adaptive  
**Quality priority:** Visual, interaction, accessibility, editorial trust, and App Store readiness  
**Working product name:** SkyTrace  

## 1. Purpose

This package turns the first three research passes into an implementation-ready system. It is intentionally **outside-in**: build the complete native shell, screen hierarchy, component language, transitions, accessibility behavior, and App Store surface with representative fixture data before binding production APIs.

The product must feel like:

> A living observatory for the world’s sky — beautiful enough to invite curiosity, quiet enough to protect judgment, and precise enough to trace every claim back to evidence.

## 2. Core model

### Experience sequence

1. **Observe** — understand today’s global sky in seconds.
2. **Read** — understand one case without sensationalism.
3. **Trace** — follow location, time, evidence, disagreement, and changes in assessment.

### Material language

- **World = Atmosphere** — time, horizon, global distribution, calm depth.
- **Controls = Glass** — navigation and temporary controls only.
- **Understanding = Editorial Surface** — stable, highly legible reading areas.

### Visual composition ratio

- Living Observatory: **45%**
- Celestial Newspaper: **35%**
- Global Signal Atlas: **20%**

These percentages are not applied uniformly. Each screen uses the mode appropriate to its job.

## 3. Files and reading order

1. `01_UI_UX_MASTER_PLAN.md` — product philosophy, UX rules, information architecture.
2. `02_DESIGN_SYSTEM_SPEC.md` — tokens, color, type, spacing, material, iconography.
3. `03_SCREEN_BLUEPRINTS.md` — detailed screen structures and states.
4. `04_COMPONENT_INVENTORY_AND_STATE_MATRIX.md` — reusable components and state contracts.
5. `05_MOTION_HAPTICS_SOUND_SPEC.md` — transitions and sensory feedback.
6. `06_ACCESSIBILITY_ADAPTIVE_LAYOUT.md` — VoiceOver, Dynamic Type, contrast, motion, iPad.
7. `07_APP_ICON_STORE_SURFACE.md` — icon, screenshots, preview video, widgets, notifications.
8. `08_UI_QUALITY_GATES.md` — completion criteria and rejection rules.
9. `09_CLAUDE_CODE_IMPLEMENTATION_PLAN.md` — native architecture and phased implementation.
10. `10_CLAUDE_CODE_KICKOFF_PROMPT.md` — ready-to-paste autonomous build prompt.
11. `11_OFFICIAL_REFERENCES.md` — official Apple sources and current submission facts.
12. `SKYTRACE_UIUX_ALL_IN_ONE.md` — generated concatenation for one-file handoff.

## 4. Non-negotiable decisions

- Native SwiftUI first. Do not reproduce a web UI inside a wrapper.
- Use standard system navigation and controls where possible so the app inherits platform behavior and Liquid Glass correctly.
- Do not use Glass for article bodies, evidence explanations, assessment text, or sources.
- Never reduce uncertainty to a single “truth percentage.”
- Never visually equate “unexplained” with “extraterrestrial.”
- Color is never the only carrier of state.
- Today begins with global context, not an undifferentiated feed.
- A returning user sees **what changed since the last visit** before repeated background information.
- The map always has an equivalent list path.
- The first UI implementation uses fixtures and previews; production data integration comes after visual and interaction approval.
- Account creation is not required for core browsing. If accounts are later introduced, in-app account deletion is mandatory.

## 5. Build strategy

### Phase A — Visual contract

Create tokens, representative models, fixtures, previews, and all major screens with no production backend dependency.

### Phase B — Interaction contract

Connect navigation, map sheets, search, saved state, loading/empty/offline/error behavior, and accessibility.

### Phase C — Product contract

Bind real services behind protocols without changing the approved visual hierarchy.

### Phase D — Release contract

Complete StoreKit, privacy surfaces, App Store assets, TestFlight validation, performance and accessibility gates.

## 6. Definition of success

The app is not complete because every screen exists. It is complete when:

- A new user can explain the app after ten seconds.
- A returning user can identify meaningful updates without rereading a case.
- A VoiceOver user can understand the same case state and evidence structure.
- Light mode looks intentionally designed rather than inverted.
- No screen looks like a generic “AI app.”
- No loading, empty, offline, error, or locked state breaks the visual language.
- App Store screenshots are honest captures of the shipping experience.
- The interface remains calm when the underlying subject is sensational.

---

<a id="01-ui-ux-master-plan"></a>

# SkyTrace UI/UX Master Plan

## 1. Product position

SkyTrace is a global case-reading and evidence-tracing app for unusual aerial reports and related public information. Its UI must satisfy two apparently opposite needs:

- awaken curiosity;
- restrain premature conclusions.

The product therefore behaves less like a social feed and more like a combination of an observatory, a high-quality editorial publication, and a geographic case atlas.

## 2. North-star experience

> In 30 seconds, understand what changed in the world’s sky today. In 3 minutes, understand one case well enough to describe the confirmed facts, disagreements, current explanations, and source basis.

### Primary user outcomes

- “I understand today’s global picture.”
- “I know what changed since I last looked.”
- “I can distinguish fact, report, interpretation, and missing information.”
- “I can follow the origin of a claim.”
- “I feel invited, not manipulated.”

## 3. Experience architecture: Observe → Read → Trace

### Observe

Purpose: establish context before detail.

Used in:

- launch and Today header;
- global map view;
- widgets;
- compact summaries.

Design qualities:

- atmospheric;
- glanceable;
- time-aware;
- low cognitive load;
- minimal text.

### Read

Purpose: make cases and synthesis understandable.

Used in:

- Daily Briefing;
- Case Detail;
- long-form synthesis;
- methodology and editorial policy;
- paywall explanation.

Design qualities:

- stable surfaces;
- strong typography;
- restrained color;
- clear hierarchy;
- evidence proximity.

### Trace

Purpose: expose relationships and provenance.

Used in:

- Map;
- Search Atlas;
- timeline;
- evidence and sources;
- related cases.

Design qualities:

- spatial and temporal axes;
- explicit legends;
- meaningful geometry;
- list alternatives;
- no decorative network diagrams.

## 4. Product principles

### P1. Content leads; interface frames

The interface can create atmosphere before reading, but it must step back when evidence and prose begin.

### P2. Meaningful change outranks recency

“New” alone is not enough. Priority is given to:

- new independent evidence;
- a changed assessment;
- a correction;
- improved time or location accuracy;
- a new official explanation;
- an important contradiction.

### P3. Uncertainty must be inspectable

Do not display a single confidence or truth score. Show separate dimensions and the basis for each.

Recommended dimensions:

- source independence;
- time consistency;
- location precision;
- media provenance;
- official corroboration;
- known-phenomenon fit;
- unresolved contradictions;
- missing critical information.

### P4. One case, multiple distances

The same case appears at five levels:

1. map signal;
2. compact row;
3. preview sheet;
4. case record;
5. synthesis or comparison.

Each level adds depth without changing identity or status language.

### P5. Returning users deserve a delta

Case Detail begins with `What Changed` when the case has been viewed before. Today includes `Since Your Last Visit`.

### P6. Standard controls, distinctive content

Use native tab bars, navigation, sheets, search, share, menus, and text styles. Distinctiveness lives in World Sky Pulse, status glyphs, case chronology, atmospheric composition, and editorial layout.

### P7. Accessibility is a parallel composition

The accessible experience is not a simplified afterthought. Map, charts, status, and time must have equivalent structured descriptions and list paths.

### P8. Calm is a functional requirement

No flashing, alarm-like pulses, aggressive red, constant particle motion, fake radar sweep, or urgency language unless an actual safety context requires it.

## 5. Navigation architecture

Primary tabs:

1. **Today** — global context and meaningful changes.
2. **Map** — geographic and temporal exploration.
3. **Search** — direct retrieval and thematic discovery.
4. **Settings** — preferences, methodology, privacy, subscription.

### Tab behavior

- Preserve each tab’s navigation stack and scroll position.
- Reselecting the active tab returns to its root; a second reselect scrolls to top where appropriate.
- Search is a dedicated tab because it spans cases, locations, phenomena, dates, sources, and collections.
- Deep links open the correct tab and route, while preserving a clear back path.

### iPad adaptation

Use a sidebar or adaptive tab/sidebar presentation when beneficial, but preserve the same four top-level destinations. Case lists and details may use a split view; do not merely stretch iPhone cards.

## 6. Information model visible to UI

### Case

Required fields for UI fixtures and production contract:

- `id`
- `title`
- `shortTitle`
- `summary`
- `status`
- `priorityReason`
- `eventStart` / `eventEnd`
- `publishedAt`
- `updatedAt`
- `lastViewedAt`
- `locationName`
- `coordinate`
- `locationPrecision`
- `independentReportCount`
- `sourceCount`
- `mediaCount`
- `officialSourceCount`
- `assessmentDimensions`
- `confirmedFacts`
- `agreements`
- `contradictions`
- `explanationsConsidered`
- `timelineEvents`
- `sources`
- `relatedCaseIDs`
- `isSaved`
- `isPlusLocked`
- `availabilityState`

### Case status vocabulary

Use a small, stable set:

- `newReport`
- `underReview`
- `informationInsufficient`
- `knownExplanationLikely`
- `explained`
- `disputed`
- `corrected`
- `archived`

UI copy should use natural Japanese labels, but model identifiers stay stable.

### Status does not equal origin

Status describes the state of understanding, not the nature of the object.

## 7. Content hierarchy

### Today

1. World Sky Pulse
2. Daily Briefing
3. Priority Case
4. Since Your Last Visit
5. Regional movement or curated grouping
6. Case Stream

### Case Detail

1. Header and status
2. What Changed
3. What Happened
4. Current Assessment
5. Confirmed Facts
6. Agreements
7. Contradictions
8. Evidence
9. Explanations Considered
10. Timeline
11. Sources
12. Related Cases

### Long-form synthesis

1. title and scope;
2. AI/editorial disclosure;
3. executive summary;
4. sections with evidence-linked claims;
5. caveats and unresolved questions;
6. cases and sources;
7. revision history.

## 8. Free and Plus boundary

### Always free

- Today global summary;
- core case metadata and basic summary;
- confirmed facts;
- basic timeline;
- source names and direct access where legally possible;
- corrections and methodology;
- accessibility settings;
- privacy and account controls.

### Plus candidates

- multi-case synthesis;
- advanced filters and saved searches;
- long-range comparison;
- richer case update notifications;
- offline research packs;
- deeper relationship exploration;
- personalized briefings.

### Paywall rule

The paywall appears only after the user expresses intent to use a Plus feature. It must state the exact blocked action and show an honest preview. There is always a visible close action.

## 9. Onboarding

Maximum three concise steps; preferably interactive rather than carousel-heavy.

1. **Observe** — today’s world in one view.
2. **Read** — facts, disagreement, and uncertainty are separated.
3. **Trace** — every important claim can lead to evidence.

Do not request location or notification permission during generic onboarding. Ask contextually when the user activates a location feature or follows a case.

## 10. Trust and editorial UX

### Required labels

- Fact / confirmed record
- Witness report
- Analysis
- Inference
- AI-generated synthesis
- Correction
- Missing information

### AI disclosure

Show:

- generated or last revised time;
- number of cases and sources used;
- whether human review occurred;
- known limitations;
- revision history.

Do not use a glowing AI badge as a credibility symbol.

### Sources

Sources are not an appendix only. Important claims link locally to supporting items. The source list distinguishes:

- primary / secondary;
- independent / derivative;
- official / private;
- original publication time;
- archive availability;
- access status.

## 11. Emotional design target

The desired feeling is:

- curiosity without fear;
- wonder without credulity;
- precision without coldness;
- technology without sterility;
- mystery without manipulation.

## 12. Explicit anti-patterns

Reject any implementation that introduces:

- a rotating 3D Earth as the permanent home hero;
- fake radar sweeps;
- purple-blue AI gradients as the default visual identity;
- glass cards covering every surface;
- equal-size cards for all content;
- a four-number dashboard as the home screen;
- “breaking,” “shocking,” or “truth revealed” language without editorial necessity;
- status communicated only by color;
- a truth percentage;
- hidden source links;
- login before browsing;
- notification prompts on first launch;
- a paywall before free value;
- decorative particles consuming battery;
- custom controls that duplicate standard iOS behavior without a strong reason.

## 13. Release stance

Quality-first baseline:

- build with current Xcode and iOS 26 SDK or later;
- native SwiftUI;
- iPhone-first with iPad adaptation;
- use system controls to inherit contemporary platform styling;
- prefer an iOS 26 minimum for the first visual-quality branch if backward compatibility would compromise the design or delay validation;
- decide the public deployment target at release gate after device and audience analysis.

---

<a id="02-design-system-spec"></a>

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

---

<a id="03-screen-blueprints"></a>

# SkyTrace Screen Blueprints

## 0. Global screen rules

Every screen must define:

- purpose;
- primary question answered;
- first meaningful content;
- primary action;
- secondary actions;
- loading, empty, error, offline, and locked behavior;
- VoiceOver reading order;
- compact and regular-width behavior;
- Light, Dark, Increase Contrast, Reduce Transparency, and Reduce Motion behavior.

The interface is not approved if only the ideal loaded state exists.

---

# 1. System launch and app entry

## Purpose

Enter the useful experience immediately while preserving atmosphere.

## Structure

- Use a static system launch screen matching the root canvas color and simplified horizon mark.
- No custom splash delay.
- First app frame shows cached or fixture-backed Today shell immediately.
- Atmosphere may settle over 600–1,000 ms without blocking interaction.

## States

### Cached data available

Show cached Today content with a subtle “更新中” status. Replace sections independently as fresh data arrives.

### No data yet

Show the World Sky Pulse shell and text “世界の空を更新しています.” Do not show zero cases.

### Offline on first launch

Show a calm offline explanation and a retry action. Provide methodology/about content that does not require network access.

---

# 2. Onboarding

## Purpose

Explain the product model, not every feature.

## Maximum length

Three pages or one interactive sequence under approximately 60 seconds.

## Page 1 — Observe

Title: `世界の空を、ひと目で。`

Visual: simplified World Sky Pulse with day/night boundary and a few semantic signals.

Body: today’s global context is summarized without turning reports into alerts.

## Page 2 — Read

Title: `事実と推定を、分けて読む。`

Visual: short case excerpt showing Confirmed Facts, Agreement, Contradiction.

## Page 3 — Trace

Title: `根拠と変化を、最後まで辿る。`

Visual: timeline event connected to a source.

## Actions

- Primary: `はじめる`
- Secondary: `あとで見る` only if needed; onboarding should not trap users.

## Permission policy

- No notification permission prompt here.
- No location permission prompt here.
- If a personalization toggle appears, it remains optional and defaults to privacy-preserving behavior.

---

# 3. Today

## Purpose

Answer: “What matters in the world’s sky today, and what changed for me?”

## Scroll composition

### 3.1 World Sky Pulse

Height target:

- compact iPhone: 220–260 pt;
- large iPhone: 250–300 pt;
- iPad: 300–380 pt within a balanced content frame.

Contents:

- local date;
- optional UTC context where relevant;
- one concise world summary;
- abstract world/horizon field;
- case signals linked to geographic distribution;
- legend for new/updated only;
- last updated time;
- `地図で見る` action.

Interaction:

- tapping a signal opens a small case/region preview, not a full surprise navigation;
- swiping/dragging the atmosphere is not required for core use;
- the visual is descriptive, not a scientific map.

Accessibility alternative:

A grouped summary such as: “本日、新規13件、重要更新4件。報告が多い地域は東アジア、北米西部、南ヨーロッパです.” Provide an action to open the equivalent list.

### 3.2 Daily Briefing

Presentation:

- editorial section, not a floating glass card;
- 3–5 lines;
- `参照Case 12件・資料34件`;
- generated/edited status;
- `全文を読む`.

### 3.3 Priority Case

One large lead only.

Required fields:

- status glyph and label;
- title;
- concise summary;
- location and event time;
- priority reason;
- optional evidence image if it adds meaning;
- updated time.

Priority reason examples:

- `新しい公的資料が追加されました`
- `評価が変更されました`
- `独立した報告が3件増えました`
- `位置精度が改善しました`

### 3.4 Since Your Last Visit

Only shown when meaningful deltas exist.

Each row shows:

- case identity;
- type of change;
- short before → after summary;
- time of change.

Do not repeat unchanged cases.

### 3.5 Curated group

Optional editorial grouping:

- region;
- shared phenomenon;
- historical comparison;
- “explanations added this week.”

Use sparingly—at most one prominent group before the stream.

### 3.6 Case Stream

Use mixed but predictable layouts:

- compact case row;
- regional heading;
- timeline update row;
- occasional media lead.

Avoid multiple horizontal carousels.

## Pull-to-refresh

Use standard refresh behavior. Preserve content and update sections; do not blank the entire screen.

## Empty

A global Today screen should not normally be “empty.” If there are no qualifying new cases, say:

> 本日は、基準を満たす新規Caseはまだありません。過去の更新やアーカイブを閲覧できます。

Show updated/archive options.

## Offline

Show cached briefing, clearly labeled with last refresh time. Disable only actions that require live data.

---

# 4. Map

## Purpose

Answer: “Where and when are cases occurring, and what is related?”

## Base structure

- Full-screen native MapKit map.
- Floating top control cluster: period, filters, location/reset.
- Bottom sheet with three detents.
- Optional timeline scrubber above the bottom sheet.

## Detents

1. **Collapsed:** approximately 88–104 pt; count, period, selected region.
2. **Medium:** about 42–50% of available height; regional/case list.
3. **Expanded:** about 85–90%; selected case preview or detailed list.

Use system sheet behavior and visible grabber. Do not create a nonstandard draggable panel unless system behavior cannot meet accessibility.

## Marker behavior

- Markers use stable status geometry.
- Selection adds outline/scale and text in the sheet.
- Uncertain location uses an area/blurred boundary plus a list explanation.
- Clusters show count and meaningful composition; they are not only numbered circles.

Cluster example:

```text
12件
新規3・更新4
```

## Timeline

Presets:

- 24 hours;
- 7 days;
- 30 days;
- custom.

Dragging changes the visible dataset with restrained insertion/removal transitions. No autoplay by default.

## Filters

Quick filters:

- status;
- media available;
- official source available;
- saved;
- updated since last visit.

Advanced filters open a sheet.

## Map/list parity

The bottom sheet can expand into a fully usable list. Every result visible on the map must be reachable through the list, including uncertain locations and clusters.

## No results

Keep the map context. Show a sheet explaining the active filters and provide `条件を解除` and `期間を広げる`.

## Location permission

Ask only when the user taps a location-based action. If denied, allow manual region selection.

---

# 5. Search

## Purpose

Answer both:

- “Find something I know.”
- “Help me discover patterns I do not yet know.”

## Search root before input

Sections:

- recent cases;
- saved searches;
- recently updated;
- regions;
- phenomena/themes;
- archive entry points.

## Search input

Use system search behavior.

Suggestions are grouped by type:

- Case;
- Place;
- Date/period;
- Phenomenon;
- Source;
- Collection.

Never mix all suggestion types into an unexplained list.

## Results modes

### List

Default and fully accessible. Case-centric results group multiple articles/sources under one Case.

### Atlas

Optional visual exploration mode. Must never be the only way to access results. If data or performance is insufficient for v1, ship List first and keep Atlas behind a feature flag without breaking the information architecture.

## Filter chips

Visible quick filters:

- period;
- region;
- status;
- media;
- official source;
- saved.

Advanced filter sheet includes source independence and evidence dimensions.

## Result row

- status glyph and text;
- title;
- location and event date;
- one-line reason for match;
- source/case grouping count;
- update time.

## Zero results

Show:

- corrected spelling or broadened term suggestions;
- active filters;
- nearby categories;
- `フィルターを解除`.

Do not show a whimsical empty illustration that trivializes the subject.

---

# 6. Case Preview

## Purpose

Provide enough information to decide whether to open the full record without losing map/search context.

## Contents

- status;
- title;
- place and event time;
- concise summary;
- priority/change reason if relevant;
- independent report and source counts;
- save/follow action;
- `詳しく読む`.

## Presentation

- On map: bottom sheet.
- In search/today: contextual preview or direct detail depending on navigation depth.
- Media may appear as a small evidence thumbnail with provenance label.

---

# 7. Case Detail

## Purpose

Answer: “What happened, what is confirmed, what conflicts, what explanations fit, and why is the current assessment what it is?”

## Material transition

Atmosphere is allowed in the header only. As the user scrolls into content, transition to a stable Editorial Surface.

## 7.1 Header

Contents:

- case ID (secondary);
- status glyph and text;
- full title;
- location;
- event date/time;
- last update;
- save/follow;
- share;
- optional map thumbnail/action.

No body text over a busy image.

## 7.2 What Changed

Conditional; first content section for returning users.

Examples:

- `資料が2件追加されました`
- `位置精度：約20km → 約3km`
- `情報不足 → 既知現象の可能性あり`

Every change links to the timeline event or evidence that caused it.

## 7.3 What Happened

Concise factual overview separating:

- reported observation;
- recorded media;
- independently confirmed context;
- unknowns.

## 7.4 Current Assessment

Use dimension rows, not one score.

Each row contains:

- dimension label;
- qualitative state or compact scale;
- short basis;
- disclosure action.

Example:

```text
報告の独立性　中
3件中2件は相互の接触を確認できず
```

The expanded disclosure shows evidence and limitations.

## 7.5 Confirmed Facts

Short, source-linked statements. Avoid cards; use an editorial list with evidence links.

## 7.6 Agreement

Show points independently supported by multiple records.

## 7.7 Contradictions

Show disagreements without implying deception. Include whether a disagreement may arise from viewing angle, memory, timestamp, or missing metadata.

## 7.8 Evidence

Group by evidence type:

- photos/video;
- witness reports;
- official documents;
- aviation/weather/astronomy data;
- expert analysis;
- reporting;
- secondary references.

Evidence rows show:

- title/type;
- source;
- date;
- primary/secondary;
- independent/derivative;
- relevant claim;
- access state.

## 7.9 Explanations Considered

For each explanation:

- supporting information;
- conflicting information;
- missing information;
- current editorial status.

Potential categories can include aircraft, satellites, astronomical objects, weather, drones, imaging artifacts, deliberate fabrication, and unresolved/other. Categories must remain neutral.

## 7.10 Timeline

Vertical chronology distinguishes:

- event occurrence;
- report publication;
- evidence release;
- official statement;
- assessment change;
- correction.

Assessment changes require a “why changed” description.

## 7.11 Sources

Full source inventory with filtering by type. Claims in preceding sections can deep-link here and highlight the relevant source.

## 7.12 Related Cases

Explain the relation:

- same time/region;
- similar appearance;
- same explanation;
- shared source;
- historical comparison.

Do not imply causation from visual similarity alone.

## Locked Plus sections

Show the section’s purpose and a representative preview, then offer Plus. Do not hide free facts or corrections.

---

# 8. Long-form synthesis

## Purpose

Combine multiple cases and sources into a coherent, source-aware reading experience.

## Header metadata

- title;
- subtitle/scope;
- read time;
- last revised;
- AI-generated or AI-assisted disclosure;
- human review state;
- number of cases and sources;
- revision history action.

## Reading layout

- stable Editorial Surface;
- 560–680 pt max reading width on regular width;
- maximum three heading levels;
- inline source markers;
- evidence figures with caption and provenance;
- related Case references styled as citations, not ads;
- reading position persistence.

## Claim interaction

Tapping a citation opens a compact source sheet with:

- source identity;
- supporting passage summary;
- source type;
- publication time;
- open/archive action.

## AI rule

The synthesis may organize and summarize; it must not present generated certainty beyond the underlying evidence. Include caveats and unresolved questions.

---

# 9. Paywall

## Purpose

Explain the exact additional value at the moment of intent.

## Trigger examples

- open a multi-case synthesis;
- save an advanced search;
- enable detailed case-change alerts;
- open long-range comparison;
- download an offline research pack.

## Structure

1. Context: `この機能でできること`
2. Accurate product preview
3. Three or fewer benefits tied to the attempted action
4. Plan and trial information
5. Primary subscribe action
6. Restore purchases
7. Terms and privacy
8. Visible close

## Copy tone

No fear of missing out, no “unlock the truth,” no countdown, no guilt.

## StoreKit

Use StoreKit 2/system subscription surfaces where they improve clarity and compliance. Prices and trial text are loaded from StoreKit, never hard-coded.

---

# 10. Settings

## Purpose

Manage preferences, transparency, privacy, and subscription without carrying the atmospheric hero style.

## Groups

### Display

- system/light/dark;
- reading size or system text explanation;
- map density;
- motion intensity only if additional control is useful beyond system settings;
- time format and units.

### Notifications

- Daily Briefing;
- followed case updates;
- major assessment changes;
- region alerts;
- quiet hours.

### Information and AI

- source policy;
- fact/inference definitions;
- AI processing and disclosure;
- correction policy;
- editorial methodology.

### Data

- saved cases;
- saved searches;
- downloaded/offline content;
- cache;
- export;
- privacy choices.

### Plus

- current plan;
- manage subscription;
- restore purchases.

### Account (only if introduced)

- profile/sign-in;
- data export;
- delete account inside the app.

### About

- version;
- credits;
- contact;
- privacy policy;
- terms.

---

# 11. Widgets

## Small

- today’s new and meaningfully updated counts;
- one concise context line;
- last refresh.

## Medium

- compact World Sky Pulse;
- one priority change or case;
- last refresh.

## Lock Screen

- followed case change count;
- Daily Briefing availability;
- compact global update count.

## Widget rules

- glanceable, not a miniature feed;
- deep-link to the exact content;
- no ambiguous alarm language;
- supports tinted/monochrome system presentations;
- no essential distinction based only on color.

---

# 12. Notifications

Maximum core categories:

1. Daily Briefing;
2. followed Case meaningful update;
3. major assessment change or correction;
4. explicitly selected region alert.

Good:

> 「関東・静止光」の位置精度が改善し、新しい航空データが追加されました。

Bad:

> 衝撃の新情報！今すぐ確認！

Every notification deep-links to the exact delta or case section.

---

# 13. Live Activities

Use only for time-bounded, user-initiated tracking such as:

- a scheduled official briefing;
- a known astronomical/aviation event relevant to a case;
- a user-followed, clearly time-bounded publication/update process.

Do not create a Live Activity for speculative real-time sightings or to manufacture urgency.

---

# 14. Loading, empty, offline, error, locked

## Loading

- show known layout skeletons;
- preserve cached content;
- update sections independently;
- avoid full-screen spinner except a truly blocking transaction;
- skeletons must not shimmer aggressively under Reduce Motion.

## Empty

Explain why and give a recovery path.

## Offline

Show last successful refresh time, available cached content, and what needs connection.

## Error

State:

- what failed;
- whether saved data remains safe;
- what retry does;
- alternative path.

Never convert a fetch failure into “0 cases.”

## Locked

Show the feature’s purpose and boundary. Keep public facts, corrections, and source transparency accessible.

---

<a id="04-component-inventory-and-state-matrix"></a>

# SkyTrace Component Inventory and State Matrix

## 1. Component policy

Components are organized by semantic responsibility, not by arbitrary visual similarity. Avoid a single universal “Card” with dozens of flags.

Each component must provide:

- loaded preview;
- long-text preview;
- empty or unavailable preview where relevant;
- Light/Dark previews;
- accessibility-size preview;
- VoiceOver label/value/hint contract;
- Reduce Motion/Transparency behavior if animated or material-based.

## 2. Foundation components

### `AtmosphereCanvas`

Purpose: calm contextual field for World Sky Pulse and launch continuity.

Inputs:

- appearance;
- local time / UTC context;
- day-night boundary abstraction;
- signal distribution;
- motion permission;
- energy/thermal fallback.

Rules:

- no particle engine;
- deterministic rendering for snapshots;
- static fallback;
- no essential information exclusively inside the canvas.

### `EditorialSurface`

Purpose: stable background and readable content width.

Inputs:

- width class;
- reading mode;
- optional section padding.

### `GlassControlGroup`

Purpose: small grouped controls over content.

Rules:

- use standard APIs first;
- high-contrast opaque fallback;
- never contains long prose.

### `SkySectionHeader`

Purpose: consistent title, optional subtitle, trailing action.

### `EditorialRule`

Purpose: subtle hierarchy divider.

## 3. Case identity components

### `CaseStatusGlyph`

Inputs:

- status;
- size;
- selected;
- update indicator;
- contrast mode.

Output includes geometry and accessible status text.

### `CaseStatusLabel`

Glyph + natural-language label. Use in detail/header contexts.

### `CaseIdentityBlock`

- status;
- title;
- location;
- event time;
- updated time.

Used by preview and detail header with layout variants.

### `CaseCompactRow`

Used in Today, search, region sheet, related cases.

### `PriorityCaseFeature`

One lead presentation. Not reusable as a generic marketing card.

### `CaseDeltaRow`

Shows meaningful change and before/after where applicable.

## 4. World and map components

### `WorldSkyPulse`

Composes:

- AtmosphereCanvas;
- summary text;
- signal overlay;
- compact legend;
- map action;
- last-updated label.

States:

- loaded;
- refreshing with cached content;
- first load;
- offline cached;
- unavailable.

### `CaseMapMarker`

Stable status geometry. Supports selection, cluster membership, and location uncertainty.

### `CaseClusterMarker`

Shows count and optional composition. VoiceOver describes region/count/status mix.

### `LocationUncertaintyOverlay`

Area representation with text/list equivalent.

### `MapFilterBar`

Quick filter controls in system material.

### `MapTimelineScrubber`

Presets and manual scrub. VoiceOver adjustable action required.

### `MapCaseSheet`

Detent-aware content:

- collapsed summary;
- medium list;
- expanded preview.

## 5. Editorial components

### `DailyBriefingLead`

Short lead with metadata and disclosure.

### `AssessmentDimensionRow`

- label;
- qualitative value;
- basis summary;
- disclosure.

Never accepts a global truth score.

### `FactStatementRow`

Source-linked concise fact.

### `AgreementSection`

Editorial list; no green-success framing.

### `ContradictionSection`

Editorial list; no red-accusation framing.

### `ExplanationConsideredBlock`

- explanation title;
- support;
- conflict;
- missing information;
- current status.

### `EvidenceRow`

- evidence type;
- title;
- source;
- provenance labels;
- date;
- relevant claim;
- access state.

### `TimelineEventRow`

- event type glyph;
- date/time;
- title;
- explanation;
- linked evidence;
- assessment change before/after where relevant.

### `SourceRow`

- title/publisher;
- primary/secondary;
- independent/derivative;
- official/private;
- date;
- archive/access state.

### `InlineCitationButton`

Opens source preview while preserving reading position.

### `SourcePreviewSheet`

Compact source context and open/archive actions.

## 6. Search components

### `SearchSuggestionGroup`

Groups suggestions by semantic type.

### `SkyFilterChip`

Removable, concise, accessible; not a tiny button below touch minimum.

### `SearchResultReason`

Explains why the result matched.

### `SavedSearchRow`

Shows query and active filters in readable form.

### `AtlasRelationNode` (optional/feature flagged)

Visual relation component with list equivalent and explicit legend.

## 7. Commerce and settings components

### `PlusFeaturePreview`

Honest preview tied to attempted action.

### `SubscriptionBenefitRow`

Maximum three on a paywall. Benefits are concrete.

### `MethodologyDisclosureRow`

Used in settings/about to expose information policy.

### `PreferenceExplanationFooter`

Explains effects without relying on a separate help page.

## 8. State matrix

Legend:

- R = required
- N/A = not applicable
- O = optional

| Feature/component | Loaded | Refreshing cached | First loading | Empty | Offline cached | Offline no cache | Error | Plus locked | Partial data |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Today | R | R | R | R | R | R | R | O | R |
| WorldSkyPulse | R | R | R | O | R | R | R | N/A | R |
| DailyBriefing | R | R | R | O | R | R | R | O | R |
| Map | R | R | R | R | R | R | R | O | R |
| Search | R | N/A | R | R | R | R | R | O | R |
| Case Preview | R | O | R | N/A | R | R | R | O | R |
| Case Detail | R | R | R | N/A | R | R | R | R | R |
| Evidence | R | O | R | R | R | R | R | O | R |
| Sources | R | O | R | R | R | R | R | N/A | R |
| Long-form | R | O | R | N/A | R | R | R | R | R |
| Paywall | R | O | R | N/A | O | R | R | N/A | R |
| Settings | R | N/A | N/A | N/A | R | R | R | N/A | R |
| Widget | R | R | R | R | R | R | R | O | R |

## 9. Partial data rules

Partial data must be explicit and local.

Examples:

- unknown event end time → show “終了時刻不明,” not omit the row silently;
- approximate location → show precision/range;
- inaccessible source → retain citation metadata and explain access status;
- no media → do not show an empty image frame;
- assessment dimension unavailable → show “判定材料不足” and why.

## 10. Preview fixture matrix

Create fixtures covering at least:

1. simple explained case;
2. complex under-review case with multiple contradictions;
3. information-insufficient case;
4. corrected case;
5. case with no media;
6. case with uncertain location;
7. long Japanese title;
8. long English/localized title;
9. source-heavy case;
10. Plus-locked synthesis;
11. cached offline state;
12. network error with safe cached data;
13. Today with many updates;
14. Today with no qualifying new cases;
15. map cluster-heavy dataset;
16. sparse global dataset.

## 11. Accessibility contracts examples

### Map marker

Label: `調査継続、群馬県南東部、7月13日21時42分のCase`  
Value: `独立報告3件、最終更新7月14日7時20分`  
Hint: `ダブルタップで概要を表示`

### Assessment dimension

Label: `報告の独立性`  
Value: `中。3件中2件は相互の接触を確認できません`  
Hint: `ダブルタップで根拠を表示`

### Timeline scrubber

Label: `表示期間`  
Value: `過去7日間`  
Adjustable actions move among supported presets or meaningful increments.

---

<a id="05-motion-haptics-sound-spec"></a>

# SkyTrace Motion, Haptics, and Sound Specification

## 1. Motion philosophy

Motion exists to explain structure and change. It does not exist to make the app look futuristic.

Permitted purposes:

1. preserve object identity across navigation;
2. explain spatial relationship;
3. acknowledge user action;
4. reveal a meaningful data update;
5. communicate time movement;
6. reduce the cognitive discontinuity between map, preview, and detail.

Prohibited purposes:

- ambient spectacle;
- urgency theater;
- fake scanning;
- constant pulsing;
- hiding latency behind long animation;
- making every card appear with staggered motion.

## 2. Motion tokens

```text
instantFeedback = 0.10–0.14 s
micro           = 0.14–0.20 s
standard        = 0.22–0.32 s
spatial         = 0.32–0.48 s
atmosphere      = 0.60–1.20 s, non-blocking
```

Use system spring and platform transitions where possible. Avoid custom bezier curves unless a documented visual need exists.

Recommended SwiftUI intent mapping:

- small selection changes: `.snappy` or equivalent short spring;
- content insertion/reordering: `.smooth` with restrained displacement;
- navigation identity transitions: system navigation transition or matched geometry only when robust;
- atmosphere settling: slow opacity/gradient interpolation, no large translation.

## 3. Core transitions

### Launch → Today

- The system launch background matches `canvas`.
- Atmosphere resolves without delaying content.
- Cached text and sections are immediately interactive.
- Signals may fade/scale from 0.96 to 1.0 once per load.

### Today World Sky Pulse → Map

Desired effect: the abstract global field becomes a precise map context.

- Preserve the selected signal identity if one was tapped.
- Navigation controls appear using system behavior.
- Do not rotate a globe or fly through space.

Reduced Motion:

- crossfade with immediate map focus;
- no scale or parallax.

### Map marker → Case Preview

- selected marker changes outline/scale subtly;
- bottom sheet presents with system detent behavior;
- marker identity/status glyph repeats in the sheet.

### Case Preview → Case Detail

- title and status maintain visual continuity where reliable;
- map recedes; editorial header becomes primary;
- avoid an elaborate custom transition if it breaks interactive back gestures.

### Timeline update

When a new timeline event is inserted:

- the connecting rule may extend once;
- the event fades into its final position;
- no recurring pulse.

### Save/follow

- symbol state change;
- brief tactile confirmation;
- optional small label change;
- no confetti.

## 4. Scroll behavior

- World Sky Pulse may compress into a compact navigation context as Today scrolls.
- Do not use heavy parallax.
- Long-form headers should not occupy excessive space after scrolling.
- Sticky controls are limited to actions needed during the current task.
- Preserve scroll position on tab switching and when dismissing source sheets.

## 5. Data transition rules

- Animate only local changes; do not reload entire lists.
- If sort order changes due to a meaningful update, preserve spatial context and announce the change accessibly.
- Skeleton to content uses opacity, not dramatic movement.
- Case count changes may use numeric content transition if supported and not distracting.
- Map markers appear/disappear based on time/filter with short fade/scale; large dataset changes may skip animation for clarity/performance.

## 6. Reduce Motion behavior

When Reduce Motion is enabled:

- remove parallax;
- replace matched-scale transitions with crossfades;
- stop atmospheric drift/breathing;
- disable shimmer;
- shorten large spatial transitions;
- keep state changes visible through text and geometry;
- never make information depend on animation sequence.

A user setting inside the app may offer “標準 / 控えめ” only if it adds value beyond the system setting. The system preference always wins.

## 7. Haptic vocabulary

Use the smallest meaningful set.

### Selection

Use for:

- selecting a map marker;
- changing a time preset;
- toggling a compact filter;
- moving between meaningful scrubber stops.

### Success/confirmation

Use for:

- saving/following a case;
- saving a search;
- completing an offline download.

### Warning/error

Use for:

- failed operation requiring attention;
- destructive confirmation;
- unavailable action while offline.

### No haptic

- ordinary scrolling;
- opening every row;
- every tab switch if system behavior already provides sufficient feedback;
- background refresh;
- new report arrival without user action.

Implementation should prefer native sensory feedback APIs when available.

## 8. Sound policy

Default UI interactions are silent.

Sound is allowed only for:

- user-initiated playback of evidence;
- an optional onboarding demonstration;
- accessibility sonification if deliberately designed and controllable;
- system notification sounds selected by the user/system.

No launch sound, radar beep, ambient spaceship hum, or recurring signal tone.

## 9. Motion performance gates

- Motion must remain smooth on the chosen baseline device.
- No continuous animation on offscreen views.
- Pause/disable atmosphere effects under Low Power Mode or thermal pressure if needed.
- Prefer vector/simple drawing over large video backgrounds.
- Profile map + sheet interaction and long-form scrolling with Instruments.
- A decorative effect is removed before lowering text or interaction quality.

---

<a id="06-accessibility-adaptive-layout"></a>

# SkyTrace Accessibility and Adaptive Layout Specification

## 1. Accessibility principle

Every essential visual statement must have an equivalent semantic statement.

The target is not “passes a checklist.” The target is:

> A person using VoiceOver, larger text, higher contrast, reduced motion, or non-color differentiation can understand the same case state, evidence structure, and meaningful changes.

## 2. Dynamic Type

### Requirements

- Support all standard and accessibility sizes through AX5.
- Use semantic text styles.
- No fixed-height text containers.
- Titles wrap; metadata reflows.
- Horizontal metadata stacks become vertical when needed.
- Filter chips can wrap or move into a list/sheet.
- Map information remains available in the bottom-sheet list.
- Long-form reading width and margins adapt rather than shrinking text.

### Layout transformations

At accessibility sizes:

- Case Compact Row becomes a vertically stacked block.
- Status glyph and label appear together above the title.
- Counts and timestamps move to separate rows.
- Segmented controls with clipped labels become menus or list choices.
- Timeline dates move above event titles.
- Assessment dimension value moves below the label.

### Test content

Test long Japanese, English, German, and mixed numeric/date strings. Do not validate only with short fixture titles.

## 3. VoiceOver

### Reading order

Order follows meaning, not visual z-index:

1. screen/section title;
2. status;
3. case identity;
4. meaningful change;
5. summary;
6. actions;
7. supporting metadata.

### Grouping

- Group compact case rows into one understandable element unless individual sub-actions require separate focus.
- Do not expose every decorative signal or divider.
- World Sky Pulse provides a concise summary plus an action to explore the list.
- Map clusters describe region, count, and composition.

### Custom components

Provide:

- meaningful label;
- value;
- hint only when necessary;
- traits;
- adjustable actions for timeline scrubber;
- custom actions for save/share where reducing focus stops helps.

### Charts and visualizations

- Provide an accessibility representation and ordered data summary.
- Atlas/network views must have an equivalent list.
- Do not force a user to navigate hundreds of decorative points.

## 4. Differentiate Without Color

Every state uses:

- geometry;
- explicit text;
- optionally pattern/line treatment;
- color as reinforcement only.

Examples:

- new = point + closed ring + `新規`;
- under review = open ring + `調査継続`;
- explained = diamond + `説明済み`.

Agreement is not only green; contradiction is not only red.

## 5. Contrast

### Targets

- Normal text: meet or exceed WCAG AA equivalent contrast.
- Large text and non-text controls: maintain clear contrast.
- Critical metadata is never rendered with insufficient tertiary contrast.
- Text over atmosphere receives a stable backing/scrim when needed.

### Increase Contrast

- strengthen separators;
- raise surface differentiation;
- use opaque control backgrounds where glass becomes ambiguous;
- increase marker outlines;
- avoid low-opacity text.

## 6. Reduce Transparency

- Glass controls switch to opaque or near-opaque semantic surfaces.
- The hierarchy remains clear without backdrop blur.
- Editorial surfaces are already stable and should require little change.
- Never place critical text directly on variable map imagery without a stable background.

## 7. Reduce Motion

Follow the motion specification:

- no parallax;
- no atmospheric breathing;
- no shimmer;
- large zoom transitions become crossfades;
- data changes remain understandable through text and static geometry.

## 8. Touch and motor accessibility

- Minimum target 44 × 44 pt.
- Do not require precise dragging for core tasks.
- Timeline has buttons/presets in addition to drag.
- Map has a list alternative.
- Swipe actions have visible menu/button alternatives.
- Context menus do not hide essential actions.
- Sheet grabbers and controls use system accessible behavior.

## 9. Switch Control and Full Keyboard Access

- Logical focus order.
- No focus traps in custom maps/sheets.
- All custom controls expose button/adjustable traits correctly.
- iPad keyboard navigation covers tabs, lists, search, filters, and detail actions.
- Visible focus indication in regular-width/key-input contexts.

## 10. Media accessibility

- Evidence images have factual alternative text; avoid speculative interpretation in alt text.
- Decorative atmosphere has no accessibility focus.
- Video supports captions/transcripts when speech exists.
- Audio evidence includes transcript/description when feasible.
- Controls expose current playback state and time.

## 11. Localization and language

- UI strings are localized resources, never embedded literals in views.
- Japanese is the initial primary language; structure supports English.
- Avoid layout assumptions based on Japanese string length.
- Date/time display follows locale, while UTC/event-source time can be shown explicitly when relevant.
- Do not combine localized text fragments programmatically in a way that breaks grammar.

## 12. Right-to-left readiness

Even if not launched initially:

- use leading/trailing rather than left/right;
- directional arrows mirror when appropriate;
- maps remain geographically correct;
- timelines and numeric chronology follow localized conventions where possible.

## 13. iPhone adaptive behavior

Test at minimum:

- smallest supported compact width;
- standard 6.1-inch class;
- large 6.7/6.9-inch class;
- portrait and relevant landscape states;
- Display Zoom if supported.

The Today hero must not consume most of a small screen. Cap and adapt its height.

## 14. iPad adaptive behavior

### Today

- center readable content;
- World Sky Pulse may become a wide landscape field;
- use columns only where hierarchy remains clear.

### Map

- map and case list can coexist;
- selected case detail can use a third column or inspector-like presentation when appropriate;
- avoid giant floating phone sheets.

### Search

- sidebar/filter column + results + detail is acceptable;
- preserve List as primary accessible mode.

### Case Detail

- maintain max reading width;
- supporting evidence may occupy a secondary column;
- do not stretch lines across the full screen.

## 15. Accessibility test matrix

Each release candidate must test:

- VoiceOver on Today, Map list, Search, Case Detail, Paywall, Settings;
- Dynamic Type default, XXXL, AX3, AX5;
- Light and Dark;
- Increase Contrast;
- Differentiate Without Color;
- Reduce Transparency;
- Reduce Motion;
- grayscale screenshot review;
- keyboard/iPad focus where supported;
- notification content readability;
- widget tinted/monochrome states.

## 16. Accessibility acceptance criteria

- Zero clipped essential text at AX5.
- Zero color-only states.
- Every map result reachable through a list.
- Every custom visualization has a semantic summary.
- VoiceOver can identify status, place, event time, update time, and change reason.
- Decorative atmosphere does not create unnecessary focus stops.
- Paywall remains dismissible and understandable.
- Source and correction information is not hidden from assistive technology.

---

<a id="07-app-icon-store-surface"></a>

# SkyTrace App Icon and App Store Surface

## 1. Brand statement

> 世界の空を観測し、静かな紙面で読み、証拠の軌跡を辿る。

The icon and store page must promise the shipping experience, not a more cinematic product than the app actually is.

## 2. App icon concept

### Core geometry

- deep atmospheric field;
- one horizon/planetary arc;
- one unresolved signal point;
- one subtle observation orbit or interrupted ring.

### Meaning

- arc = Earth/sky/horizon;
- point = observed signal/case;
- open orbit = inquiry still in progress;
- layered light = atmosphere, not neon.

### Prohibitions

- text or initials;
- a literal flying saucer;
- alien head;
- military radar reticle;
- detailed star field;
- tiny evidence/photo imagery;
- excessive purple neon;
- fake 3D chrome.

## 3. Icon layering

Build in Apple Icon Composer or the current official icon workflow.

Suggested layers:

1. Background atmospheric field
2. Horizon arc
3. Observation orbit/open ring
4. Signal point
5. Optional subtle optical highlight

Validate:

- light appearance;
- dark appearance;
- tinted/monochrome presentation;
- small Home Screen size;
- Settings/Spotlight size;
- marketing flattening.

The icon must remain recognizable when effects are reduced and when color is removed.

## 4. Icon exploration variants

### Variant A — Horizon Signal (recommended)

A low arc with one elevated signal and an incomplete orbital ring. Quiet, iconic, avoids category cliché.

### Variant B — Open Observation Eye

Two arcs create an abstract eye/horizon without becoming a surveillance symbol.

### Variant C — Trace Point

A point crossing a thin path above a horizon; more data/atlas oriented.

Test all variants at small size before choosing. Default recommendation: Variant A.

## 5. App Store screenshot story

Apple currently allows up to 10 screenshots per supported localization. Use 8 strong frames rather than filling space with weak ones.

### Screenshot 1 — World Sky Pulse

Headline: `世界の空を、ひと目で。`

Show:

- Today hero;
- concise world summary;
- a few signals;
- real shipping UI.

Purpose: category and emotional promise.

### Screenshot 2 — Meaningful changes

Headline: `何が起き、何が変わったか。`

Show:

- Daily Briefing;
- Since Your Last Visit;
- a before → after assessment/location change.

Purpose: returning-user value.

### Screenshot 3 — Map

Headline: `世界中のCaseを、地図から辿る。`

Show:

- full map;
- semantic markers;
- medium bottom sheet;
- time/filter controls.

Purpose: spatial exploration.

### Screenshot 4 — Case record

Headline: `噂ではなく、Caseとして読む。`

Show:

- calm Case Detail header;
- What Happened;
- Current Assessment.

Purpose: trust and differentiation.

### Screenshot 5 — Agreement / Contradiction

Headline: `一致と矛盾を、分けて見る。`

Show both sections in a clean editorial layout.

Purpose: epistemic clarity.

### Screenshot 6 — Timeline

Headline: `評価が変わった理由まで残す。`

Show:

- event;
- evidence release;
- assessment change;
- correction.

Purpose: traceability.

### Screenshot 7 — Synthesis

Headline: `複数の資料を、一つの理解へ。`

Show long-form header with source/case counts and disclosure.

Purpose: Plus value.

### Screenshot 8 — Brand close

Headline: `未知を煽らず、未知のまま見つめる。`

Show a balanced composition of horizon, one signal, and editorial content.

Purpose: memorable philosophy.

## 6. Screenshot design rules

- Use actual captured UI, not invented controls.
- Keep marketing typography outside the device frame separate from in-app typography.
- Do not hide the system status or alter UI to imply unavailable features.
- Do not show unverified real-world sensational claims in launch assets.
- Localize marketing copy; do not merely translate word-for-word.
- Keep the first three screenshots understandable without reading the full description.
- Export using current App Store Connect specifications at submission time.

## 7. Product page optimization plan

Apple Product Page Optimization can test icons, screenshots, and previews. Prepare up to three treatments:

### Control

Observe-first story described above.

### Treatment A — Trust-first

First image focuses on Case Detail and evidence clarity.

### Treatment B — Map-first

First image focuses on global map/atlas exploration.

Primary metrics:

- conversion rate;
- first-time downloads;
- downstream onboarding completion and first case open, to avoid optimizing only for clicks.

Do not select a more sensational treatment if it attracts users with the wrong expectation.

## 8. App preview video

Apple app previews can be up to 30 seconds and use on-device footage. Recommended length: 20–25 seconds.

### Storyboard

**0–3 s** — World Sky Pulse settles. Copy: `世界の空を、ひと目で。`

**3–7 s** — Scroll to Daily Briefing and meaningful updates.

**7–12 s** — Transition to Map and select a Case.

**12–18 s** — Open Case Detail; show facts, agreement, contradiction.

**18–23 s** — Trace timeline to a source.

**23–25 s** — Brand statement and icon.

Rules:

- no external cinematic footage pretending to be the app;
- no rapid unreadable cuts;
- no fake typing;
- captions/localization included;
- sound is optional and the video must work muted.

## 9. App Store copy framework

### Subtitle candidates

- `世界の空を、根拠から読む`
- `空のCaseと資料を追う観測記録`
- `世界の目撃情報を静かに辿る`

Recommended initial direction: `世界の空を、根拠から読む`

### Promotional message direction

Focus on meaningful updates, evidence, corrections, and global context. Avoid promises to reveal truth or prove extraordinary origins.

### Description opening

The first paragraph should explain:

- what the app gathers;
- how cases are organized;
- how facts, interpretations, and uncertainty are separated;
- what the user can do in under a minute.

## 10. Widgets

Visual language:

- atmosphere field only where it remains legible;
- editorial text hierarchy;
- status geometry;
- deep link to exact destination.

Create previews for:

- full color Light/Dark;
- tinted;
- accented/monochrome;
- placeholder/redacted states;
- no data/offline.

## 11. Notifications

Notification identity should be recognizable through concise language, not emojis or alarm tone.

Use:

- specific Case/region;
- specific change;
- why it matters.

Avoid:

- generic “new content”;
- clickbait;
- unexplained urgency;
- unsupported conclusions.

## 12. Live Activity surface

Only for user-initiated, time-bounded activity. Display:

- tracked event title;
- next known milestone/time;
- last verified update;
- direct return action.

Never portray speculative case activity as a verified live event.

## 13. Marketing asset quality gate

- Icon works at 29 pt and in monochrome.
- Screenshot headlines are readable at App Store search-result scale.
- First image communicates purpose without relying on the app name.
- All shown features exist in the submitted build.
- Light and Dark both appear across the full screenshot set where useful.
- Accessibility is visible at least once, through clarity rather than a badge.
- No asset relies on copyrighted evidence without appropriate rights.

---

<a id="08-ui-quality-gates"></a>

# SkyTrace UI Quality Gates

## 1. Gate philosophy

“Implemented” is not “finished.” Every feature passes visual, interaction, content, accessibility, performance, and trust gates.

A failed critical gate blocks release even if the screen is functional.

## 2. Gate A — Product clarity

Pass criteria:

- A first-time tester can state the product purpose after 10 seconds.
- Today clearly answers what changed globally.
- Primary actions are visible without instruction.
- Observe, Read, and Trace feel like one product.
- The interface does not resemble a generic AI chat/news template.

Reject when:

- the home screen is only a feed;
- the hero is decorative but uninformative;
- users confuse case status with origin/truth;
- users cannot find sources or changes.

## 3. Gate B — Visual system

Pass criteria:

- semantic tokens only in feature code;
- Light and Dark are intentionally composed;
- typography hierarchy survives long content;
- editorial sections do not become card stacks;
- Glass is limited to controls/navigation;
- status geometry is consistent everywhere;
- color usage stays restrained;
- no accidental horizontal scrolling.

Reject when:

- literal colors/paddings proliferate;
- nested rounded cards appear;
- purple/blue gradients become the main identity;
- body copy sits on dynamic imagery;
- Light mode is a simple inversion.

## 4. Gate C — Interaction

Pass criteria:

- standard back gestures and navigation work;
- tab state is preserved;
- sheets use understandable detents;
- map selection and list selection stay synchronized;
- every hidden gesture has a visible alternative;
- loading and refresh preserve context;
- no accidental destructive action;
- paywall is dismissible.

Reject when:

- custom transitions break interactive dismissal;
- map is the only discovery path;
- full screen reload occurs for local updates;
- a user loses reading/scroll position after inspecting a source.

## 5. Gate D — Content and trust

Pass criteria:

- facts, reports, analysis, inference, AI synthesis, and corrections are distinguishable;
- a changed assessment includes a reason;
- “unexplained” is not presented as evidence of an extraordinary origin;
- source independence and derivation are visible;
- errors never appear as zero data;
- AI disclosure and revision metadata are present;
- corrections remain in history.

Reject when:

- a single truth score is shown;
- inaccessible source data is silently omitted;
- AI text speaks with unsupported authority;
- promotional copy is more certain than the evidence.

## 6. Gate E — Accessibility

Critical pass criteria:

- zero clipped essential text at AX5;
- zero color-only status;
- every map result has list access;
- VoiceOver reads case status, event time, update time, and change reason;
- custom visualization has a semantic summary;
- Reduce Motion and Reduce Transparency produce usable alternatives;
- touch targets are at least 44 × 44 pt;
- focus order is logical;
- paywall and account/privacy controls are accessible.

Automated accessibility audits are necessary but not sufficient; conduct manual VoiceOver testing.

## 7. Gate F — State completeness

Every major screen must be reviewed in:

- loaded;
- refreshing with cache;
- first load;
- no results/empty;
- partial data;
- offline with cache;
- offline without cache;
- recoverable error;
- unrecoverable error;
- Plus locked where relevant.

Reject if any state falls back to an unstyled spinner, blank white/black screen, raw error code, or misleading zero count.

## 8. Gate G — Performance

Targets are measured on a defined baseline device and current OS.

Pass criteria:

- first useful cached content appears immediately after launch transition;
- network does not block the entire first screen;
- scrolling remains smooth in Today and long-form;
- map pan/zoom and sheet interaction remain responsive;
- continuous decorative animation does not consume significant resources;
- images are decoded/resized appropriately;
- offscreen animation and work are suspended;
- no obvious main-thread network or heavy parsing;
- no memory growth during repeated map/detail navigation.

Use Instruments for:

- Time Profiler;
- Core Animation/hitches;
- Allocations/leaks;
- network;
- energy.

Any visual effect that compromises reading, interaction, battery, or thermal behavior is removed.

## 9. Gate H — Device and appearance matrix

Required screenshots or snapshot review:

- smallest supported iPhone;
- standard iPhone;
- largest iPhone;
- iPad compact and regular layouts;
- Light;
- Dark;
- Increased Contrast;
- Reduce Transparency;
- default text;
- AX3/AX5;
- grayscale;
- portrait, plus selected landscape layouts.

## 10. Gate I — App Store and policy readiness

Pass criteria:

- build uses the currently required Apple SDK at submission;
- privacy policy is accessible in metadata and app;
- data collection is minimized and accurately declared;
- permission purpose strings are specific;
- core browsing works without login unless account features truly require it;
- in-app account deletion exists if account creation exists;
- subscription price/trial details come from StoreKit;
- restore/manage subscription paths exist;
- screenshots and previews show real UI;
- age rating questionnaire is accurate;
- copyrighted media rights are confirmed.

## 11. Visual regression workflow

For each approved screen:

1. Store reference snapshots for key states.
2. Generate previews with deterministic fixture data.
3. Compare after token/component changes.
4. Review differences intentionally; do not blindly update baselines.
5. Maintain a `UI_CHANGELOG.md` for meaningful visual decisions.

Recommended snapshot set:

- Today loaded/light/dark/AX3;
- Map cluster and selected case;
- Search root/results/empty;
- Case Detail core sections;
- long-form;
- paywall;
- settings;
- offline/error;
- widgets.

## 12. Human review rubric

Score 1–5:

- clarity;
- calmness;
- distinctiveness;
- reading comfort;
- geographic comprehension;
- evidence traceability;
- trust;
- accessibility;
- platform fit;
- App Store appeal.

No category may score below 4 for release candidate. Trust and accessibility are blocking categories.

## 13. “Do not simplify” list

Claude Code or any implementer must not remove these for convenience:

- separate What Changed section;
- fact/agreement/contradiction separation;
- assessment dimensions;
- source provenance labels;
- map/list parity;
- all non-ideal states;
- Light mode;
- Dynamic Type adaptation;
- Reduce Motion/Transparency alternatives;
- source and correction access in free experience;
- semantic status geometry.

## 14. Final release checklist

- [ ] All major screen states exist.
- [ ] Visual tokens are centralized.
- [ ] No unapproved generic card patterns.
- [ ] No raw hard-coded subscription prices.
- [ ] No truth score.
- [ ] No source hidden behind Plus if necessary to support a free claim.
- [ ] VoiceOver manual pass complete.
- [ ] AX5 pass complete.
- [ ] Light/Dark/contrast pass complete.
- [ ] Map/list parity complete.
- [ ] Offline and error distinction complete.
- [ ] Instruments pass complete.
- [ ] TestFlight external feedback addressed.
- [ ] App Store assets match shipping build.
- [ ] Privacy and account deletion requirements checked.

---

<a id="09-claude-code-implementation-plan"></a>

# SkyTrace Claude Code Implementation Plan

## 1. Implementation objective

Build a release-quality native iOS UI shell from the outside in, using representative fixture data and complete interaction/state behavior before binding production services.

The first milestone is not a wireframe. It is a visually coherent, navigable, accessibility-aware application that can be reviewed in Simulator and on device.

## 2. Technical baseline

Preferred baseline:

- Xcode 26 or later;
- iOS 26 SDK or later;
- Swift 6 language mode where compatible;
- SwiftUI native app lifecycle;
- MapKit;
- Observation framework;
- SwiftData for saved/read/cache metadata if appropriate;
- StoreKit 2 for subscription surfaces;
- WidgetKit for widgets;
- ActivityKit only for approved time-bounded use cases;
- XCTest and UI tests;
- no third-party UI framework in the first implementation.

### Deployment target

For the quality-first UI branch, use iOS 26 unless the existing project has a deliberate lower target. If broad backward compatibility is a release requirement, centralize availability handling and preserve the iOS 26 design as the reference experience rather than downgrading the entire system.

## 3. Architectural principles

- Feature-oriented folders.
- UI depends on protocols and view models, not concrete networking.
- Fixture data and production data conform to the same interfaces.
- State is explicit; do not infer loading/error from empty arrays.
- Design tokens are centralized.
- Navigation routes are typed.
- Views remain small and compositional, but avoid premature generic abstractions.
- Every major component has previews.
- Accessibility is implemented with the component, not after the screen.

## 4. Recommended repository structure

```text
SkyTrace/
  App/
    SkyTraceApp.swift
    AppEnvironment.swift
    AppRoute.swift
    RootTab.swift
    RootView.swift
  DesignSystem/
    Color/
    Typography/
    Spacing/
    Shape/
    Material/
    Motion/
    Status/
    Components/
  Core/
    Models/
      SkyCase.swift
      CaseStatus.swift
      Evidence.swift
      SourceRecord.swift
      AssessmentDimension.swift
      TimelineEvent.swift
    Protocols/
      CaseRepository.swift
      BriefingRepository.swift
      SearchRepository.swift
      SubscriptionProviding.swift
    Persistence/
    Networking/
    Utilities/
  Features/
    Onboarding/
    Today/
    Map/
    Search/
    CaseDetail/
    LongForm/
    Paywall/
    Settings/
  PreviewSupport/
    Fixtures/
    FixtureRepositories/
    PreviewEnvironment.swift
  Resources/
    Assets.xcassets
    Localizable.xcstrings
  Widgets/
  Tests/
    Unit/
    SnapshotOrVisual/
    UI/
  docs/
    uiux/
      [this package]
```

If the existing project uses a different coherent architecture, adapt rather than rewrite solely to match this tree.

## 5. Data and state contracts

### Explicit load state

```swift
enum LoadState<Value> {
    case idle
    case loading(previous: Value?)
    case loaded(Value, freshness: Freshness)
    case empty(EmptyReason)
    case failed(AppError, previous: Value?)
}
```

Equivalent patterns are acceptable. Empty, offline, error, and partial data must not collapse into the same state.

### Fixture-first repositories

Create deterministic repositories for:

- Today briefing;
- map cases and clusters;
- search suggestions/results;
- case detail;
- long-form synthesis;
- subscription products/state.

Support scenario switching in debug builds or previews:

- loaded;
- loading;
- cached refresh;
- empty;
- offline;
- error;
- partial;
- Plus locked.

## 6. Phase 0 — Audit and safety

1. Inspect current repository, target settings, dependencies, and existing screens.
2. Run the current build and tests before changes.
3. Record existing functional behavior that must be preserved.
4. Create a dedicated branch such as `feature/skytrace-uiux-v2`.
5. Copy this blueprint package into `docs/uiux/`.
6. Create `UI_IMPLEMENTATION_LOG.md` with decisions, deviations, and commands.
7. Do not delete existing implementation until replacement behavior builds and tests.

Deliverable: clean baseline and implementation map.

## 7. Phase 1 — Design foundation and fixtures

Implement:

- semantic colors in Asset Catalog;
- typography helpers;
- spacing, radii, motion tokens;
- status geometry and labels;
- AtmosphereCanvas static and motion-aware variants;
- EditorialSurface;
- core fixture models and repositories;
- PreviewEnvironment;
- localization strings.

Create previews for Light/Dark, default/AX3, Reduce Motion, Increase Contrast where feasible.

Deliverable: a design-system gallery/debug screen available only in debug builds.

## 8. Phase 2 — App shell and navigation

Implement:

- root TabView: Today, Map, Search, Settings;
- typed NavigationStack routes per tab;
- state restoration for selected tab and navigation where appropriate;
- onboarding state;
- deep-link route placeholders;
- appearance/environment propagation.

Use standard tab and navigation components so current platform material and behavior are inherited.

Deliverable: fully navigable empty shell with previews and UI tests for tab routing.

## 9. Phase 3 — Today

Implement in order:

1. WorldSkyPulse;
2. DailyBriefingLead;
3. PriorityCaseFeature;
4. SinceYourLastVisit;
5. curated grouping;
6. Case Stream;
7. loading/offline/error/empty/partial states;
8. scroll/refresh behavior;
9. VoiceOver summary.

Use fixture scenarios to verify sparse and dense data.

Deliverable: Today feels complete and screenshot-ready before real data binding.

## 10. Phase 4 — Map

Implement:

- native MapKit map;
- semantic markers and clusters;
- uncertain-location overlay;
- top controls;
- system bottom sheet with detents;
- synchronized list selection;
- time presets/scrubber;
- filters;
- loading/no-results/offline/error states;
- manual-region path if location permission is denied;
- VoiceOver/list parity.

Performance rule: cluster and annotation logic must not cause repeated heavy work on the main thread.

Deliverable: map and list are equally functional.

## 11. Phase 5 — Search

Implement:

- search root discovery sections;
- typed suggestions grouped by type;
- results list;
- filter chips and advanced filter sheet;
- saved-search fixture behavior;
- zero-results recovery;
- recent search persistence;
- optional Atlas mode behind a feature flag if fully legible and performant.

Do not delay the accessible List mode for Atlas experimentation.

Deliverable: direct retrieval and discovery both work.

## 12. Phase 6 — Case Preview and Detail

Implement the Case Detail hierarchy exactly:

1. Header;
2. What Changed;
3. What Happened;
4. Current Assessment dimensions;
5. Confirmed Facts;
6. Agreement;
7. Contradictions;
8. Evidence;
9. Explanations Considered;
10. Timeline;
11. Sources;
12. Related Cases.

Add:

- inline citation → source preview sheet;
- reading/last-view metadata;
- save/follow state;
- share link placeholder;
- map link;
- locked subsection behavior;
- offline/partial evidence handling.

Do not replace sections with a generic expandable card list.

Deliverable: the strongest, most trustworthy screen in the app.

## 13. Phase 7 — Long-form, Paywall, Settings

### Long-form

- editorial reading width;
- disclosure metadata;
- inline citations;
- revision history;
- reading-position persistence;
- text-size robustness.

### Paywall

- contextual attempted-action copy;
- StoreKit-backed price/products;
- restore/manage paths;
- visible close;
- offline/failure states.

### Settings

- display;
- notifications;
- information and AI;
- data/privacy;
- Plus;
- account only if applicable;
- about/methodology.

Deliverable: complete commerce and trust surfaces.

## 14. Phase 8 — Widgets and approved system surfaces

Implement representative Small, Medium, and Lock Screen widgets using fixture/timeline data.

- deep links;
- placeholder/redacted states;
- tinted/monochrome checks;
- no miniature feed.

Live Activities remain off unless an approved, time-bounded user flow exists.

## 15. Phase 9 — Accessibility and adaptive layout hardening

Run the complete matrix from `06_ACCESSIBILITY_ADAPTIVE_LAYOUT.md`.

Tasks:

- AX5 repair;
- VoiceOver ordering and custom labels;
- map/list parity audit;
- Reduce Motion/Transparency;
- Increase Contrast;
- grayscale/status review;
- iPad split-view adaptation;
- keyboard focus where supported;
- localization stress tests.

Deliverable: no critical accessibility gate failures.

## 16. Phase 10 — Performance and visual regression

- Capture deterministic screenshots for key fixtures.
- Use Xcode previews and Simulator screenshots.
- Add snapshot tests if the project supports a reliable approach; do not add a large dependency solely for snapshots without justification.
- Profile Today scrolling, Case Detail, map interaction, launch, memory, and energy.
- Remove or simplify decorative effects before compromising responsiveness.

Suggested screenshot command workflow after booting a simulator:

```bash
xcrun simctl io booted screenshot Artifacts/today-dark.png
```

Automate multiple appearance/content-size scenarios where practical.

## 17. Phase 11 — Production service binding

Only after UI approval:

- implement concrete repositories;
- map API/data models into stable UI models;
- retain fixture repositories for previews/tests;
- add cache/freshness metadata;
- bind corrections and source provenance;
- preserve partial/offline states;
- avoid leaking backend shape into views.

A backend limitation must not silently collapse the designed information hierarchy. Record any unavoidable deviation.

## 18. Phase 12 — App Store release preparation

- current SDK/build settings;
- privacy policy and App Privacy answers;
- purpose strings;
- StoreKit product configuration;
- account deletion if accounts exist;
- age rating;
- icon via official current workflow;
- screenshots and preview video from shipping build;
- TestFlight external testing;
- App Review notes explaining source/AI methodology where helpful.

## 19. Testing plan

### Unit tests

- status labels/geometry mapping;
- assessment display mapping;
- sorting by meaningful change;
- delta generation;
- search grouping;
- source independence labels;
- cache freshness;
- paywall entitlement behavior.

### UI tests

- onboarding → Today;
- tab navigation;
- Today → Map → Preview → Detail;
- search → result → source;
- follow/save;
- offline/error recovery;
- paywall dismiss/restore path;
- settings/methodology;
- Dynamic Type smoke tests where feasible.

### Manual tests

- VoiceOver;
- map gestures and list parity;
- device performance;
- real long content;
- App Store screenshots.

## 20. Commit strategy

Create focused commits after each stable phase, for example:

- `feat(design-system): add semantic tokens and status glyphs`
- `feat(today): implement world sky pulse and briefing states`
- `feat(map): add semantic markers and adaptive case sheet`
- `feat(case-detail): add assessment evidence and timeline`
- `fix(a11y): support AX5 and map list parity`

Do not combine an entire rewrite into one opaque commit.

## 21. Autonomy and escalation rules

Proceed autonomously through phases. Do not stop for aesthetic confirmation after every screen.

When ambiguity appears:

1. follow the blueprint;
2. prefer native platform behavior;
3. choose calm clarity over spectacle;
4. record the decision in `UI_IMPLEMENTATION_LOG.md`;
5. continue unless the decision affects legal/privacy/payment behavior or would destroy existing user data.

For true blockers, produce the safest working implementation and clearly mark the remaining decision.

## 22. Final deliverables from Claude Code

- buildable Xcode project;
- completed UI shell and fixture data;
- tests passing;
- preview gallery;
- Simulator screenshots for major screens/states;
- `UI_IMPLEMENTATION_LOG.md`;
- `UI_REVIEW_REPORT.md` against quality gates;
- list of deliberate deviations and why;
- next-step production integration checklist.

---

<a id="10-claude-code-kickoff-prompt"></a>

# Claude Code Kickoff Prompt — SkyTrace UI/UX V2

Paste the following prompt into Claude Code from the repository root after placing this package in `docs/uiux/`.

---

You are the lead iOS product designer-engineer for **SkyTrace**, an App Store-bound native iOS application for observing global sky-related cases, reading them as structured records, and tracing evidence, disagreement, timeline changes, and sources.

Your task is to implement the complete **outside-in UI/UX V2** at the highest practical quality. Build a coherent, navigable, accessibility-aware application shell with realistic fixture data first; connect or preserve production services only after the visual and interaction contract is stable.

## Read first

Read every file in `docs/uiux/` in numerical order, especially:

1. `00_README_UIUX_PACKAGE.md`
2. `01_UI_UX_MASTER_PLAN.md`
3. `02_DESIGN_SYSTEM_SPEC.md`
4. `03_SCREEN_BLUEPRINTS.md`
5. `04_COMPONENT_INVENTORY_AND_STATE_MATRIX.md`
6. `05_MOTION_HAPTICS_SOUND_SPEC.md`
7. `06_ACCESSIBILITY_ADAPTIVE_LAYOUT.md`
8. `07_APP_ICON_STORE_SURFACE.md`
9. `08_UI_QUALITY_GATES.md`
10. `09_CLAUDE_CODE_IMPLEMENTATION_PLAN.md`

Treat those documents as the product/design contract. Do not reduce them to loose inspiration.

## Core experience

The product sequence is:

**Observe → Read → Trace**

The three visual materials are:

- **World = Atmosphere**
- **Controls = Glass**
- **Understanding = Editorial Surface**

The product must feel calm, precise, beautiful, native, and trustworthy. It must invite curiosity without sensationalism.

## Non-negotiable rules

- Native SwiftUI first. Do not build a web-style interface inside iOS.
- Use current standard iOS navigation, tabs, sheets, search, menus, share, and StoreKit surfaces wherever they fit.
- Use Liquid Glass primarily through standard controls/navigation. Do not put long-form content, evidence, sources, or assessment text inside Glass cards.
- Do not turn every section into a rounded card.
- Do not use a generic purple-blue AI gradient identity.
- Do not create a rotating globe, radar sweep, constant particles, recurring pulsing markers, or spaceship dashboard.
- Do not display one truth/confidence percentage.
- Do not imply that “unexplained” means extraterrestrial.
- Color must never be the only status carrier.
- Core browsing must not require login.
- Do not request notifications or location on first launch without contextual intent.
- Do not show a paywall before delivering free value.
- Do not omit loading, empty, partial, offline, error, and locked states.
- Do not remove source, correction, and methodology transparency for convenience.
- Do not sacrifice Dynamic Type, VoiceOver, Reduce Motion, Reduce Transparency, or map/list parity.

## Working method

1. Audit the current repository and run the existing build/tests.
2. Preserve useful functionality and avoid destructive rewrites.
3. Create a dedicated feature branch.
4. Copy/retain this blueprint in the repository.
5. Create `UI_IMPLEMENTATION_LOG.md` and record important decisions and deviations.
6. Implement the phases in `09_CLAUDE_CODE_IMPLEMENTATION_PLAN.md`.
7. Use deterministic fixture repositories and preview scenarios before production binding.
8. Build a debug-only design-system/preview gallery.
9. Add tests and capture Simulator screenshots as work progresses.
10. Run a self-review against every item in `08_UI_QUALITY_GATES.md`.
11. Continue autonomously through all feasible phases; do not stop after producing a plan or wireframe.

## Technical preference

Use the current Xcode/iOS 26 SDK environment, SwiftUI, MapKit, Observation, SwiftData where appropriate, StoreKit 2, WidgetKit, and ActivityKit only for explicitly approved time-bounded flows. Avoid adding third-party UI frameworks. Keep repositories protocol-based so fixture and production services share the same UI contract.

## First implementation priority

Build in this order:

1. semantic design tokens and status glyphs;
2. fixture models/repositories and previews;
3. root tabs/navigation/onboarding;
4. Today with World Sky Pulse and all states;
5. Map with system sheet, markers, clusters, timeline, filters, and list parity;
6. Search with grouped suggestions, filters, list results, and optional feature-flagged Atlas;
7. Case Preview and complete Case Detail hierarchy;
8. long-form synthesis;
9. contextual paywall and Settings/methodology/privacy;
10. widgets;
11. accessibility, iPad adaptation, localization stress tests;
12. performance, screenshots, regression review;
13. production service binding where available.

## Today must contain

- World Sky Pulse;
- Daily Briefing;
- one Priority Case with a reason;
- Since Your Last Visit;
- curated grouping if useful;
- Case Stream;
- loaded, refreshing-cached, first-loading, sparse/empty, partial, offline, and error states.

## Case Detail must contain

In this order:

1. Header
2. What Changed
3. What Happened
4. Current Assessment dimensions
5. Confirmed Facts
6. Agreement
7. Contradictions
8. Evidence
9. Explanations Considered
10. Timeline
11. Sources
12. Related Cases

Keep this as an editorial case record, not a stack of generic disclosure cards.

## Quality checks during work

After each major feature:

- build the project;
- run relevant tests;
- inspect Light and Dark;
- inspect default and accessibility text sizes;
- inspect loading/offline/error;
- verify VoiceOver semantics for custom components;
- capture a Simulator screenshot;
- update `UI_IMPLEMENTATION_LOG.md`.

Use standard platform behavior over fragile custom transitions. If an effect threatens performance, accessibility, or navigation gestures, remove the effect rather than lowering core quality.

## Decision rule

When the docs do not specify a detail, choose in this order:

1. trustworthy information comprehension;
2. native iOS behavior;
3. accessibility;
4. calm visual hierarchy;
5. distinctive atmosphere;
6. decorative novelty.

Do not ask for confirmation on ordinary design decisions. Make the best grounded choice, document it, and continue. Ask only for true blockers involving irreversible data loss, legal/privacy/payment configuration, or missing credentials that make further execution impossible.

## Required final report

When the feasible implementation is complete, produce:

- `UI_REVIEW_REPORT.md` with pass/fail status for every quality gate;
- a list of implemented screens and states;
- test/build commands and results;
- screenshots/artifact locations;
- accessibility work completed;
- performance findings;
- deliberate deviations with reasons;
- remaining production-data or App Store configuration tasks.

Do not finish by merely describing what should be built. Build as much of the actual application as the repository and available environment allow.

---

---

<a id="11-official-references"></a>

# Official Apple References and Current Constraints

Checked: 2026-07-14

This file records the primary Apple sources behind the blueprint. Re-check all submission requirements immediately before release because platform rules and asset specifications can change.

## Human Interface Guidelines

- Human Interface Guidelines  
  https://developer.apple.com/design/human-interface-guidelines

- Materials / Liquid Glass  
  https://developer.apple.com/design/human-interface-guidelines/materials  
  Key principle: Liquid Glass forms a distinct functional layer for controls and navigation above content.

- Tab bars  
  https://developer.apple.com/design/human-interface-guidelines/tab-bars

- Accessibility  
  https://developer.apple.com/design/human-interface-guidelines/accessibility

- Motion  
  https://developer.apple.com/design/human-interface-guidelines/motion

- Playing haptics  
  https://developer.apple.com/design/human-interface-guidelines/playing-haptics

- Color  
  https://developer.apple.com/design/human-interface-guidelines/color

- Dark Mode  
  https://developer.apple.com/design/human-interface-guidelines/dark-mode

- Layout  
  https://developer.apple.com/design/human-interface-guidelines/layout

- Maps  
  https://developer.apple.com/design/human-interface-guidelines/maps

- Searching  
  https://developer.apple.com/design/human-interface-guidelines/searching

- Sheets  
  https://developer.apple.com/design/human-interface-guidelines/sheets

- Widgets  
  https://developer.apple.com/design/human-interface-guidelines/widgets

- SF Symbols  
  https://developer.apple.com/design/human-interface-guidelines/sf-symbols

## Liquid Glass and design resources

- Meet Liquid Glass  
  https://developer.apple.com/videos/play/wwdc2025/219/

- Applying Liquid Glass to custom SwiftUI views  
  https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views

- Apple Design Resources / Icon Composer  
  https://developer.apple.com/design/resources/  
  Icon Composer supports layered icon workflows and appearance modes.

## Apple Design Awards 2026

- 2026 winners and finalists  
  https://developer.apple.com/design/awards/

Relevant official observations:

- Moonlitt: praised for broad platform support, onboarding, intuitive interaction, and Liquid Glass integration.
- Tide Guide: praised for clear full-screen data visualization, custom animation, widgets, and time-of-day palette.
- Primary: praised for avoiding sensationalism/clickbait and keeping a minimal UI out of the news’s way.
- Guitar Wiz: praised for VoiceOver, Dynamic Type, Increased Contrast, and Differentiate Without Color.
- Structured: praised for a visually sharp, easy-to-scan, simple layout.

These apps are references for principles, not templates to copy.

## App Store submission and product page

- App Store Connect overview  
  https://developer.apple.com/app-store-connect/  
  Current page states that developers can upload up to 10 screenshots and three app previews for each supported localization.

- Product Page Optimization  
  https://developer.apple.com/app-store/product-page-optimization/

- Creating Your Product Page  
  https://developer.apple.com/app-store/product-page/

- App previews  
  https://developer.apple.com/app-store/app-previews/  
  Current guidance: up to three previews per language; each preview up to 30 seconds and based on on-device footage.

- Screenshot specifications  
  https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/  
  Use the current specification at export/submission time rather than freezing dimensions in product code or design docs.

## Current SDK minimum

Apple Developer News, “Upcoming SDK minimum requirements”:

https://developer.apple.com/news/

As of April 28, 2026, iOS and iPadOS apps uploaded to App Store Connect must be built with the iOS 26 and iPadOS 26 SDK or later. Re-check this requirement at submission time.

## App Review, privacy, and account behavior

- App Review Guidelines  
  https://developer.apple.com/app-store/review/guidelines/

Relevant current requirements include:

- an accessible privacy policy in App Store Connect metadata and inside the app;
- clear data collection, use, retention/deletion, and third-party protection descriptions;
- consent and a way to withdraw it where collection requires consent;
- data minimization and requesting only permissions relevant to core functionality;
- allowing use without login when significant account-based features are absent;
- in-app initiation of account deletion if the app supports account creation.

- Offering account deletion in your app  
  https://developer.apple.com/support/offering-account-deletion-in-your-app/

- App Privacy Details  
  https://developer.apple.com/app-store/app-privacy-details/

## Subscription

- Auto-renewable subscriptions  
  https://developer.apple.com/app-store/subscriptions/

Use StoreKit/current Apple subscription surfaces and do not hard-code localized prices or trial terms.

---

<a id="12-導入ガイド-日本語"></a>

# SkyTrace UI/UX設計一式 — 日本語導入ガイド

## この一式でできること

今回の第4回は、これまでの収集・比較を、Claude Codeが実装へ移せるファイル群に変換したものです。

単なる雰囲気資料ではなく、次を固定しています。

- アプリ全体の思想
- Today／Map／Search／Case詳細などの構造
- Light／Darkカラー
- 文字、余白、角丸、Glassの使用範囲
- Case状態の形と意味
- モーション、触覚、音
- VoiceOver、Dynamic Type、Reduce Motion等
- Loading／Empty／Offline／Error／Plus制限
- AppアイコンとApp Storeスクリーンショット
- 完成と判定する品質基準
- Claude Codeの実装順と完成報告形式

## 最終コンセプト

### SkyTrace — Living Observatory

> 世界の空を観測し、静かな紙面で読み、証拠の軌跡を辿る場所。

体験は3段階です。

1. **Observe** — 世界の空の現在像をつかむ
2. **Read** — 一つのCaseを落ち着いて読む
3. **Trace** — 時間・場所・資料・評価変化を辿る

見た目の素材も3つに分けています。

- **世界＝Atmosphere（大気）**
- **操作＝Glass（ガラス）**
- **理解＝Editorial Surface（紙面）**

## 特に重要な禁止事項

実装中に品質が普通のアプリへ戻らないよう、次を禁止しています。

- 全画面を角丸カードだらけにする
- 全面をLiquid Glassにする
- 紫と青のAIグラデーションへ寄せる
- 巨大な回転地球やレーダーを常設する
- 光点をずっと点滅させる
- 「未解明＝宇宙人」と見える演出
- 真実度を1個のパーセントで出す
- 出典や訂正を奥へ隠す
- 初回起動で通知・位置情報・課金を押しつける
- 正常画面だけ作り、通信失敗時を放置する

## Claude Codeへ渡す方法

1. ZIPを展開します。
2. 対象リポジトリの `docs/uiux/` にファイルを入れます。
3. リポジトリのルートでClaude Codeを開きます。
4. `10_CLAUDE_CODE_KICKOFF_PROMPT.md` の本文を貼ります。
5. 既存アプリがある場合、Claude Codeには最初に現状ビルドと構造確認を行わせます。

キックオフプロンプトは、設計だけして止まらず、可能な範囲で実際のSwiftUI実装・テスト・Simulator画像・レビュー報告まで進むようにしています。

## 推奨する進め方

最初は本番APIをつながず、Fixture（見本データ）で外側を完成させます。

1. 色・文字・状態記号
2. 4タブとナビゲーション
3. Today
4. Map
5. Search
6. Case詳細
7. 長文記事・Paywall・設定
8. Widget
9. アクセシビリティとiPad
10. 本番データ接続

この順番なら、API都合でUIの思想が崩れるのを防げます。

## 完成時に確認するもの

Claude Codeから最低限、次を出してもらう設計です。

- ビルド可能なXcodeプロジェクト
- 各画面と各状態
- Fixture／Preview
- テスト結果
- Simulatorスクリーンショット
- アクセシビリティ対応内容
- 品質基準の合否レポート
- 設計から変更した箇所と理由
- 本番APIやApp Store申請へ残る作業

## ファイルを読む順番

詳細を確認したい場合は、次の順番です。

- `01_UI_UX_MASTER_PLAN.md`：全体思想
- `02_DESIGN_SYSTEM_SPEC.md`：色・文字・素材
- `03_SCREEN_BLUEPRINTS.md`：全画面
- `04_COMPONENT_INVENTORY_AND_STATE_MATRIX.md`：部品と全状態
- `05_MOTION_HAPTICS_SOUND_SPEC.md`：動き・触覚・音
- `06_ACCESSIBILITY_ADAPTIVE_LAYOUT.md`：アクセシビリティ
- `07_APP_ICON_STORE_SURFACE.md`：アイコン・ストア
- `08_UI_QUALITY_GATES.md`：完成判定
- `09_CLAUDE_CODE_IMPLEMENTATION_PLAN.md`：実装順
- `10_CLAUDE_CODE_KICKOFF_PROMPT.md`：貼り付け用指示

## 最後に

この設計の中心は、「宇宙っぽく派手にすること」ではありません。

**空の美しさ、紙面の読みやすさ、証拠を辿れる誠実さを、同じアプリの中で両立すること**です。

そのため、世界を見る入口は詩的に、Caseを読む場所は明晰に、根拠を辿る場所は構造的に作ります。

---

<a id="13-uiuxマスター概要-日本語"></a>

# SkyTrace UI/UXマスター概要 — 日本語版

## 1. 今回決定した最終方針

SkyTraceの外側は、単なる「宇宙風ニュースアプリ」にはしません。

最終コンセプトは、

> **SkyTrace — Living Observatory**  
> 世界の空を観測し、静かな紙面で読み、証拠の軌跡を辿る場所。

です。

画面全体は、次の3つの思想を役割ごとに組み合わせます。

- **Living Observatory 45％**：空・時間・大気・静かな光
- **Celestial Newspaper 35％**：読みやすい紙面・信頼・記録
- **Global Signal Atlas 20％**：地図・時間軸・Case同士の関係

全画面に同じ割合で混ぜるのではなく、

- Today上部や起動体験は「観測所」
- Case詳細や長文は「紙面」
- MapやSearch、Timelineは「Atlas」

を主役にします。

## 2. 体験の3段階

### Observe — 観測する

最初の数秒で、今日の世界の空に何が起き、何が変化したかを把握します。

使う場所：

- 起動
- Today上部
- World Sky Pulse
- Mapの世界表示
- Widget

### Read — 読む

一つのCaseを、事実・証言・推定・不足情報・矛盾に分けて理解します。

使う場所：

- Daily Briefing
- Case詳細
- AI統合記事
- 出典
- 訂正履歴

### Trace — 辿る

どの情報がいつ追加され、なぜ評価が変わり、何が根拠になったかを辿ります。

使う場所：

- Map
- Search
- Timeline
- Evidence
- Sources
- Related Cases

## 3. 見た目を作る3つの素材

### 世界＝Atmosphere

World Sky PulseやMap背景など、世界・時刻・大気を感じる場所に使います。

- 星の写真を背景に敷かない
- 粒子を常時飛ばさない
- 巨大な地球を回さない
- 昼夜やCase分布を静かに抽象化する

### 操作＝Glass

Liquid Glassは、操作部分に限定します。

- Tab Bar
- Navigation
- MapのFilter
- Search
- 一時的な操作パネル

記事本文、出典、評価の説明には使いません。

### 理解＝Editorial Surface

Caseを読む場所は、静かな紙面にします。

- 安定した背景
- 読みやすい文字幅
- 十分な余白
- 見出しと罫線による階層
- カードの乱用を避ける

合言葉は、

> **操作はガラス、理解は紙面、世界は大気。**

です。

## 4. ナビゲーション

4タブを正式採用します。

1. **今日**：世界概況、重要な変化、Case一覧
2. **地図**：場所・時間・関連性
3. **探す**：Case、場所、年代、現象、出典
4. **設定**：表示、通知、AI・情報方針、データ、Plus

タブを切り替えても各画面の位置やNavigation状態を保持します。

## 5. Todayの完成構造

Todayは単なるニュースフィードではありません。

### 1. World Sky Pulse

画面上部約25〜30％。

表示：

- 日付
- 今日の世界概況1文
- 新規・更新Caseの静かな信号
- 最終更新時刻
- 地図へ移る操作

### 2. Daily Briefing

3〜5行の短い編集要約。

- 参照Case数
- 参照資料数
- 更新時刻
- AI／編集状態

### 3. Priority Case

今日もっとも意味のある変化があったCaseを1件だけ大きく表示します。

「話題だから」ではなく、

- 公的資料追加
- 評価変更
- 独立報告増加
- 位置精度改善
- 訂正

などの理由を見せます。

### 4. Since Your Last Visit

再訪ユーザーには、前回から変わった部分だけを表示します。

### 5. Case Stream

通常のCase一覧。

同じカードを延々と並べず、Lead・Compact Row・地域グループなどを使い分けます。

## 6. Mapの完成構造

- MapKitの全画面地図
- 上部に期間・Filter・現在地
- 下部に3段階のSheet
- 状態ごとの形を持つMarker
- 時間軸
- 地図と同じ結果を読めるList

### Bottom Sheet

1. 閉じた状態：期間と件数
2. 中間：地域・Case一覧
3. 展開：Case概要

### 重要原則

- 地図だけでしか探せない情報を作らない
- 位置が曖昧なCaseは範囲と説明を表示する
- Clusterは数字だけでなく新規・更新構成を示す
- 色だけで状態を分けない

## 7. Searchの完成構造

検索前にも、探索の入口を表示します。

- 最近見たCase
- 保存した検索
- 更新されたCase
- 地域
- 年代
- 現象テーマ

入力中は候補を、

- Case
- 場所
- 日付
- 現象
- 出典
- Collection

に分類します。

結果は記事単位ではなくCase単位を基本にします。同じ出来事の記事が5本あっても、5件の別結果にはしません。

## 8. Case詳細の完成構造

Case詳細は、アプリで最も重要な画面です。

順番を固定します。

1. Header
2. What Changed／前回からの変化
3. What Happened／何が起きたか
4. Current Assessment／現在評価
5. Confirmed Facts／確認済み事実
6. Agreement／一致点
7. Contradictions／矛盾点
8. Evidence／資料
9. Explanations Considered／検討した説明
10. Timeline／理解の変化
11. Sources／出典
12. Related Cases／関連Case

### 真実度は1個の数字にしない

以下を別々に表示します。

- 報告の独立性
- 時刻の整合
- 位置精度
- 映像資料の来歴
- 公的確認
- 既知現象との一致
- 未解決の矛盾
- 不足情報

### What Changed

以前読んだユーザーには、

- 資料が2件追加
- 位置精度20km→3km
- 情報不足→既知現象の可能性あり

などを最初に見せ、Timelineや根拠へつなげます。

## 9. 色と質感

### Dark

- 真っ黒ではなく、青と緑をわずかに含む夜色
- 紙面は少し明るい墨青
- 文字は純白を避けた柔らかな白
- アクセントは大気光の青緑
- 意味のある変化には月光のような淡い金

### Light

- 真っ白ではなく青白い大気
- 紙面はわずかに温かい白
- 文字は墨色
- 青緑と空色
- 変化や時間に淡い金

### 使用量

- 背景・無彩色：80％
- 青緑：12％
- 淡金：5％
- 状態色：3％

## 10. 形の意味

- 中央点＋円：新規
- 開いた円：調査継続
- 欠けた円：情報不足
- 半円：既知現象の可能性あり
- 菱形：説明済み
- ずれた2本の弧：意見・資料の対立
- 修正記号付き菱形：訂正
- 輪郭四角：Archive

同じ形をMap、一覧、Case詳細、Timeline、Widgetで使います。

## 11. 文字・余白

- 基本はAppleのSystem Font
- UIはSF系
- 編集見出しはSystem Serifを慎重に使用
- 本文はDynamic Type対応
- AX5まで崩れない
- 4pt Grid
- 画面余白16〜20pt
- セクション間32〜48pt
- 本文をカードへ閉じ込めない

## 12. モーション

モーションは未来感の飾りではなく、場所と変化を理解させるために使います。

### 使う場面

- Todayの信号がMap上の位置へつながる
- Map MarkerがCase Previewへつながる
- PreviewのTitleとStatusが詳細Headerへつながる
- Timelineに新情報が追加された時だけ線が伸びる

### 使わないもの

- 常時点滅
- レーダー走査
- 大量のStagger Animation
- 長い起動演出
- Confetti

Reduce Motion時はCrossfade中心にします。

## 13. 触覚と音

### 触覚

- Marker選択、Filter切替：軽い選択感
- Case保存、検索保存：柔らかな確定感
- 削除、失敗：警告

### 音

通常操作は無音です。

起動音、宇宙音、レーダービープは使いません。

## 14. アクセシビリティ

必須対応：

- VoiceOver
- Dynamic Type AX5
- Increase Contrast
- Differentiate Without Color
- Reduce Transparency
- Reduce Motion
- 44×44pt以上のTouch Target
- MapのList代替
- Video Caption／Transcript
- iPad Keyboard Focus

### 完成基準

- AX5で重要文字が1つも切れない
- 色だけの状態が1つもない
- Map上の全CaseをListから開ける
- VoiceOverでStatus、場所、発生時刻、更新時刻、変更理由を理解できる

## 15. Loading／Empty／Offline／Error

### Loading

- Cached内容を残して更新
- Skeletonは既知Layoutのみ
- 全画面Spinnerを原則使わない

### Empty

何もない理由と、

- 期間を広げる
- Filterを解除
- Archiveを見る

を表示します。

### Offline

- 最終取得時刻
- 読める保存内容
- 接続が必要な機能

を明確にします。

### Error

「0件」と誤表示せず、何が取得できなかったかを伝えます。

## 16. Paywall

最初の起動では表示しません。

有料機能を使おうとした時に、

1. 今やろうとしたこと
2. Plusでできること
3. 実際のPreview
4. StoreKitの料金
5. 復元
6. 規約・Privacy
7. 閉じる

を表示します。

「宇宙の真実を解放」などのCopyは禁止です。

## 17. Appアイコン

推奨案：**Horizon Signal**

- 深い大気
- 地平線の弧
- 1点の信号
- 途中で開いた観測軌道

UFOそのものは描きません。

AppleのIcon Composerを使い、Light／Dark／Tinted／小さい表示を確認します。

## 18. App Storeスクリーンショット

1. 世界の空を、ひと目で。
2. 何が起き、何が変わったか。
3. 世界中のCaseを、地図から辿る。
4. 噂ではなく、Caseとして読む。
5. 一致と矛盾を、分けて見る。
6. 評価が変わった理由まで残す。
7. 複数の資料を、一つの理解へ。
8. 未知を煽らず、未知のまま見つめる。

## 19. Claude Codeの実装順

### Phase 0

既存Repository確認、現状Build、Branch作成、設計ファイル配置。

### Phase 1

Color、Typography、Spacing、Status形、Fixture、Preview。

### Phase 2

4Tab、Navigation、Onboarding。

### Phase 3

Today完成。

### Phase 4

MapとList代替。

### Phase 5

Search。

### Phase 6

Case PreviewとCase詳細。

### Phase 7

長文、Paywall、Settings。

### Phase 8

Widget。

### Phase 9

VoiceOver、AX5、iPad、Contrast。

### Phase 10

Performance、Simulator画像、Visual Regression。

### Phase 11

本番API接続。

### Phase 12

App Store申請準備。

## 20. 技術方針

- SwiftUI Native
- Xcode 26／iOS 26 SDK以降
- MapKit
- Observation
- SwiftData（保存・既読・Cache等に適切なら）
- StoreKit 2
- WidgetKit
- ActivityKitは時間が明確なFlowだけ
- 外部UI Frameworkは初期段階では使わない
- ViewはProduction APIを直接見ず、Protocol越しにFixtureと本番を切替

## 21. 品質ゲート

完成判定は、画面が存在することではありません。

- 10秒でアプリの目的が分かる
- 再訪時に変更点がすぐ分かる
- LightとDarkが両方美しい
- VoiceOverでも同じ情報構造を理解できる
- 通信失敗時も品格が崩れない
- MapとCase詳細がつながって感じられる
- 出典と訂正に迷わず届く
- AIが権威のように見えない
- iOS標準の操作感を壊さない
- App Store画像が実際の製品と一致する

## 22. 絶対に簡略化しない部分

- What Changed
- Confirmed Facts／Agreement／Contradictionsの分離
- 複数軸のAssessment
- Sourceの来歴
- Timelineの変更理由
- MapとListの両立
- Light Mode
- AX5
- Reduce Motion／Transparency
- Loading／Offline／Error
- 無料範囲の訂正・根拠

## 23. 最終的に目指す印象

SkyTraceは、派手な宇宙広告ではなく、

> 夜明け前の観測所で、世界の空に浮かんだ小さな信号を、静かな紙面と確かな資料で読み解いていくアプリ。

です。

美しさは、情報を隠す魔法ではありません。

**何が分かり、何が分からず、なぜ評価が変わったかを、最も美しく誠実に見せること。**

それをこのUI/UXの最高品質と定義します。

