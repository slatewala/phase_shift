# Phase Shift: Dodge What You Can See by Becoming What You Cannot

**Two lanes. Two versions of you. One is solid, one is a ghost. Obstacles barrel toward both, but only the solid one can be hit. Tap to swap which is real. Survive as long as your brain can keep up with two realities at once.**

Phase Shift takes the lane-dodge genre and inverts it. Instead of moving left or right to avoid obstacles, you shift between two parallel dimensions -- light and dark -- deciding which version of yourself is vulnerable at any given moment. It is less about reflexes and more about dual-track awareness, and it will rewire how you process visual information.

---

## The Two Lanes

The screen is split vertically down the middle. The left half is the light lane: a clean, pale background (`#F5F5F5`) with dark gray obstacles. The right half is the dark lane: a deep navy void (`#1A1A2E`) with neon-colored obstacles that glow against the black.

Your character exists in both lanes simultaneously. In one lane, you are a filled, glowing circle -- solid, vulnerable, real. In the other, you are a faint outline -- a ghost, intangible, immune. Tap anywhere on the screen to swap which lane holds the solid version of you.

A pulsing divider line between the lanes shifts between gray and cyan, a constant visual reminder that the boundary between real and unreal is always one tap away.

---

## Obstacle Behavior

Obstacles spawn at the top of the screen and scroll downward toward your character, which is fixed at the 75% mark (three-quarters down the screen). Each obstacle is a rectangle with a random width between 40% and 80% of its lane and a random height between 30 and 80 pixels.

Every obstacle belongs to one lane. If an obstacle is in the light lane and you are solid in the light lane, it can hit you. If you shift to make the dark lane solid, that same light-lane obstacle passes through your ghost harmlessly.

Starting at stage 16, the game introduces dual-lane spawns: obstacles appear in both lanes simultaneously, with a 50% chance per spawn cycle. This is the game's key escalation. With obstacles in both lanes, there is no "safe" lane -- you must find the gap between overlapping threats and time your shift to slip through the window where neither lane's obstacle is at your position.

---

## Difficulty Progression

Phase Shift uses a stage system where each stage lasts exactly 5 seconds. The game tracks three escalating parameters:

### Speed

| Stage | Scroll Speed (px/s) | Feel |
|-------|-------------------|------|
| 1     | 300               | Leisurely |
| 10    | 390               | Brisk |
| 20    | 490               | Fast |
| 30    | 590               | Frantic |
| 50+   | 790 (near cap)    | Extreme |

Speed is capped at 800 px/s. The formula is `300 + (stage - 1) * 10`, climbing 10 px/s per stage.

### Spawn Interval

| Stage | Spawn Interval (s) | Obstacles per Second |
|-------|--------------------|---------------------|
| 1     | 0.90               | ~1.1 |
| 10    | 0.63               | ~1.6 |
| 20    | 0.33               | ~3.0 |
| 21+   | 0.30 (floor)       | ~3.3 |

The spawn interval decreases by 0.03 seconds per stage, flooring at 0.3 seconds. Combined with dual-lane spawns starting at stage 16, the screen fills rapidly in the late game.

### Dual-Lane Spawns (Stage 16+)

Before stage 16, every spawn puts an obstacle in one lane only. After stage 16, each spawn has a 50% chance of placing obstacles in both lanes. This fundamentally changes the game from "which lane is safe?" to "when is the gap between obstacles in both lanes?"

---

## Collision Detection

The collision system checks only obstacles in the lane where you are currently solid. For each obstacle, it performs a two-axis overlap test:

- **Vertical:** Does the obstacle's vertical span overlap with the player circle's vertical span? (Player position plus/minus the 18-pixel radius.)
- **Horizontal:** Does the obstacle's horizontal span overlap with the player circle's center point plus/minus the radius?

The player's horizontal position is always the center of the solid lane, so horizontal collision depends entirely on obstacle width. Narrow obstacles (40% of lane width) can sometimes miss you even in the solid lane if they are offset, but wide obstacles (80%) are almost guaranteed hits.

---

## The Phase Animation

When you tap to shift lanes, the transition is not instant. A crossfade animation runs from 0.0 to 1.0, smoothly transitioning the solid alpha from ghost-level (0.3) to full (1.0) in the new lane, while the old lane fades from full to ghost. This creates a visual "phasing" effect where both characters briefly exist in a semi-solid state.

The animation is fast enough that it does not impede gameplay, but slow enough that you can see the shift happening. It reinforces the fantasy of dimensional phasing rather than binary teleportation.

---

## Visual Design

The contrast between the two lanes is deliberate and functional. The light lane's gray obstacles are stark and utilitarian -- clean rectangles with rounded corners. The dark lane's obstacles are neon-colored, randomly tinted from a palette of cyan, magenta, lime, red, and yellow, each with a soft glow blur effect. They look like they belong in a different world, which is exactly the point: these are two separate realities sharing a screen.

The player circles follow the same duality. In the light lane, the solid player is blue (`#2979FF`). In the dark lane, the solid player is cyan (`#00FFFF`). Ghost versions are rendered as hollow outlines at 30% opacity, making them visible but clearly intangible.

---

## Strategy Tips

1. **Watch the dark lane even when light is solid.** Your ghost cannot be hit, but the obstacles in the ghost lane are still scrolling. If you shift into a lane without checking what is already there, you phase directly into an obstacle.

2. **Pre-shift for dual spawns.** When you see obstacles appearing in both lanes simultaneously (stage 16+), immediately start tracking the gap timing. Shift to the lane where the obstacle will pass you first, then shift back to the other lane after it passes.

3. **Use peripheral vision.** The split-screen layout is designed so that both lanes are always visible. Train yourself to monitor both halves simultaneously rather than snapping your attention back and forth.

4. **The 75% player position is your friend.** You are positioned three-quarters down the screen, which gives you a long preview of incoming obstacles. Use that distance. Plan your shifts when obstacles are still in the top half.

5. **Do not panic-tap.** Double-tapping shifts you to a lane and immediately back, accomplishing nothing but disorientation. Every tap should be a deliberate decision to move to the other lane for a reason.

6. **Stage 16 is the real start.** Everything before dual-lane spawns is warmup. The game begins when you can no longer stay in one lane indefinitely.

---

## The Sound of Survival

Phase Shift uses three audio callbacks: `onStageUp` fires every 5 seconds as a quiet stage progression marker, `onLevelUp` fires every 10 stages as a more prominent milestone, and `onCollision` fires on death. The sparse audio design keeps the focus on the visual duality -- the game communicates primarily through what you see, not what you hear.

---

## Why It Stands Out

Most dodge games ask you to move away from danger. Phase Shift asks you to change what danger means. The obstacles never change, your position never changes, and the lanes never move. The only variable is which reality you choose to inhabit, and that single binary decision -- light or dark, solid or ghost -- generates all of the game's complexity.

It is a game about attention allocation. Can you track two streams of information simultaneously and make a binary decision at the right moment? That is the entire challenge, and it never stops being interesting because the density of information keeps increasing.

---

## Built With

| Component | Technology |
|-----------|-----------|
| Framework | Flutter |
| Rendering | CustomPainter (`PhasePainter`) with dual-lane backgrounds |
| Game Loop | `ChangeNotifier` with per-frame `update(dt)` |
| State | `PhaseGame` model with lane enum, obstacle list, stage counter |
| Obstacles | `Obstacle` class with lane assignment, fractional width, absolute height |
| Player | Fixed position at 75% screen height, 18px radius |
| Animation | Crossfade `phaseT` parameter for lane-shift visuals |
| Collision | Axis-aligned rectangle vs. circle overlap test |
| Input | Single tap anywhere toggles `solidLane` between `Lane.light` and `Lane.dark` |
| Audio | Stage-up, level-up, and collision callbacks |

---

Phase Shift is what happens when you take the simplest possible interaction -- a single tap -- and set it against the most cognitively demanding possible scenario: tracking two simultaneous realities. Tap. Shift. Survive.
