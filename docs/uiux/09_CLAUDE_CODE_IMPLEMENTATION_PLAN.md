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

