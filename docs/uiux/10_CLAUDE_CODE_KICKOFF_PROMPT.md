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

