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

