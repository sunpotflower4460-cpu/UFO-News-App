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

