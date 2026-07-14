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

