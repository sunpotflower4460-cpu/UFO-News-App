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

