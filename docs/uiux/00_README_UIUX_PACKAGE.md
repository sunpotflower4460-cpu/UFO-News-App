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

