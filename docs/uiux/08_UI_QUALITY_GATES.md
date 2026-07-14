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

