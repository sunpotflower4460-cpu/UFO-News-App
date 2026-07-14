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

