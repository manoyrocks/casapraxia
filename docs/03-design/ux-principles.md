# UX Principles, Engagement Ethics & Accessibility Spec

**Baseline standards:** WCAG 2.2 Level AA · W3C COGA ("Making Content Usable for People with Cognitive and Learning Disabilities") · Apple HIG Accessibility · Google Material accessibility · EN 301 549 · UK Age Appropriate Design Code.

---

## 1. The fourteen principles

1. **Zero reading required, ever.** Every child-facing control is a photograph, familiar icon, or spoken instruction. Text appears *only* as a redundant adult layer. **Photographs beat illustrations** for object recognition in this population; use real photos for nouns and video for actions.
2. **Predictable routines over novelty.** Identical session skeleton every time: greeting → choose → N trials → celebration → end ritual. **Novelty lives inside slots, not in the structure.**
3. **Reduced sensory load by default.** Ship low-stimulation defaults, *not* high-stimulation-with-an-off-switch. Calm desaturated palette (avoid saturated red/yellow at scale); no background music by default; no idle animation; **one thing moves at a time**; no unexpected audio; no autoplay.
4. **Always-reachable sensory panel.** Sound, music (independent of voice), animation, brightness/contrast, dark mode, haptics, model playback speed, reward intensity. Honour OS `prefers-reduced-motion`, Reduce Motion, Reduce Transparency automatically.
5. **No time pressure.** No countdowns, no visible timers, no "hurry" audio, no score decay. WCAG 2.2.1 is the floor; our rule is stricter — **nothing on the child screen ever changes because time passed.** Motor-planning disorders require long, variable response latency.
6. **No punishing failure states.** No red X, no buzzer, no disappointed "try again!", no losing collected items, no health bars, no restart-from-zero. **The child has a lifetime of failure feedback around speech already.**
7. **Errorless-learning structure.** First presentation is maximally supported; support fades only on success. The design goal is that the child is **right almost all the time.** This is simultaneously a motor-learning principle and the single most important emotional-safety feature.
8. **Choice and agency at every turn.** Activity, companion, target order, which reward to open. Choice is the cheapest and strongest engagement lever for demand-avoidant children, and **it converts a demand into an offer.**
9. **Large targets, accidental-touch tolerance.** ≥64pt child targets (far above WCAG 2.5.8's 24px floor), ≥16dp spacing, nothing in thumb-rest or edge zones, debounced repeat taps, touches ignored during transitions, deliberate long-press for anything destructive, and a **non-literacy-dependent parent gate.**
10. **Transition warnings.** Visual + auditory "two more" using **concrete countable tokens that disappear** — never an abstract timer bar.
11. **Session-end rituals.** Identical every time: short earned celebration → collection shelf → consistent goodbye → the app closes itself out of the child context. **Never end on a failed trial. Never end because a timer expired.**
12. **One screen, one job.** No nested menus in the child zone. Depth ≤2. No modals over the child's task. Identical placement of home / repeat-the-model / pause (WCAG 3.2.3, 3.2.4).
13. **Multimodal redundancy.** Every instruction carries ≥2 channels (spoken + visual, or visual + haptic). Never rely on colour alone (1.4.1) or sound alone — many of these children have fluctuating otitis media and some will use the app muted.
14. **The child's data is the child's.** No advertising, no third-party analytics SDKs in the child experience, no behavioural profiling. Treat the legal floor as the design floor, not the ceiling.

### Autism-specific additions
Literal and concrete language; **no metaphor or idiom** in any spoken prompt; no exaggerated high-intensity emotional faces; a visual schedule of the session; **repetition of a preferred item without penalty** (repetition is regulation, not a bug); no unexpected character speech; a **quiet mode** stripping the app to the bare task.

---

## 2. Engagement without exploitation

The engineering target — **60–80 speech attempts in 10 minutes, 5 days/week, sustained for months** — is a brutal requirement in a population with low frustration tolerance, and exactly the situation where consumer app playbooks turn predatory.

**The discipline: motivate the practice, never the app.**

### Reward design
Extrinsic rewards are necessary early, because the speech act is not yet reinforcing — **it is currently aversive.** But the reward must be engineered to decay.

- **The reward is a vehicle for the next trial, not a destination.** Animations ≤2.5s, always returning directly to the next trial.
- Reward magnitude **decreases as competence increases** while target difficulty rises.
- The app actively **shifts the reinforcement source**: app → human ("Look at Mom!") → the communicative effect itself.
- **Natural/functional reinforcement is the highest form and the spine of the design:** the utterance causes the outcome. This is also the mechanism by which speech generalises *out* of the app.

### Errorless learning as the real engagement lever
**Success rate is the best engagement metric available.** At ~80–90% success, engagement takes care of itself; below ~60%, no reward system will save the session.

> **The adaptive engine's primary objective function is maintaining success rate inside the 80–90% band — not maximising difficulty.**

### Ethical variable reinforcement
Variable-ratio schedules are the most powerful behavioural tool available and the engine of slot machines. Permitted here **only** under all six constraints:
(a) variability is over *which* reward, never *whether* effort was valued — every trial is acknowledged, only the bonus varies;
(b) **no near-miss simulation, ever**;
(c) no loss, no expiry, no resets;
(d) no monetary or purchasable path to rewards;
(e) density decreases by design as mastery rises;
(f) the schedule is **transparent to the parent and adjustable** ("your child gets a surprise about every 4th turn — change or turn this off").

### Companion character
**One** consistent, low-arousal companion (not a menagerie). Its jobs: model the target with a visible mouth; provide social scaffolding without social pressure (**it is also learning**, so the child is a peer rather than a subject); provide continuity.
**Rules:** no disappointment reactions; no guilt lines; **never appears in a notification**; never asks the child to come back. Customisable appearance = cheap agency.

### Progression
**Contingent on attempts made, not accuracy.** Effort always advances the world. This removes any incentive for a parent to score generously and removes the child's experience of failure from the visible world-state.

Collections are ideal here — low arousal, interruption-tolerant, repetition-friendly, self-paced. Nothing is ever lost, timed, or duplicate-farmed; completion is achievable in months.

### Streaks — the sharpest ethical line
**Streaks are parent-facing only, and even then defanged.** A child-visible streak converts a missed day into a loss the child can be blamed for. Even parent-facing, unbroken-streak framing manufactures guilt in a population already saturated with it.

> Replace with a **practice rhythm**: a 4-week heatmap with **no broken state**, and a **bucket goal** ("4 days this week" — achievable after a miss) rather than "day 23." Missed days produce neutral, compassionate re-entry. Never a loss animation. Never a red zero.

---

## 3. Banned dark patterns — enforceable in code review and store submission

1. Loss-framed streaks, streak-freeze purchases, or any "you'll lose X" message
2. Child-facing push notifications, or any notification in the companion's voice or that guilt-trips ("Mateo hasn't practiced!")
3. Near-miss animations, spinning wheels, loot boxes, or any purchasable randomised reward
4. Any currency purchasable with money that affects the child's experience or progression
5. Ads of any kind, cross-promotion, in-child-experience upsells, third-party ad/analytics SDKs
6. Countdown timers, limited-time offers, artificial scarcity anywhere the child can see
7. Energy/lives/stamina systems gating practice behind waiting or payment
8. Interstitials, autoplay-next loops, infinite feeds in the child zone
9. **Social comparison** — leaderboards, percentile-vs-peers, friend streaks. Milestone comparison to typical development is *particularly* harmful here
10. Confirmshaming ("No thanks, I don't want my child to talk")
11. Dark-pattern cancellation — hidden cancel, email-only cancel, retention gauntlets. **Cancellation must be as easy as signup**
12. Trial-to-paid conversion without clear advance notice and an easy pre-charge exit
13. Pay-to-progress in the story arc, or **gating AAC behind payment or speech performance**. The communication layer is never a paywall and never a reward
14. Anthropomorphised guilt ("Pip is sad you left")
15. Misleading efficacy claims, testimonial-led marketing, or any language implying cure, guarantee, or SLP replacement
16. Collecting or monetising child voice recordings beyond the stated clinical purpose; **any model-training use without explicit, separate, revocable opt-in**

---

## 4. Accessibility specification

### WCAG 2.2 AA — the clauses that bite here

| Criterion | Our implementation |
|---|---|
| **2.5.8 Target Size (Min)** | 24×24 CSS px floor; **we ship ≥64pt** in the child zone |
| **2.5.7 Dragging Movements** | **Every drag has a single-pointer alternative.** For a child with motor-planning difficulty, drag-and-drop is close to a hostile interaction |
| **2.2.1 Timing Adjustable** | Exceeded — **no timing dependency exists** in the child zone |
| **2.3.1 Flashing** | No flashing content (seizure risk; comorbid epilepsy is elevated in this population) |
| **1.4.1 Use of Colour** | Never colour alone |
| **3.2.3 / 3.2.4 Consistency** | Identical control placement across all child screens |
| **3.2.6 Consistent Help** | Adult help reachable identically everywhere |
| **2.4.11 Focus Not Obscured** | Portal and web views |

### Population-specific requirements beyond the standards
- **Switch Control** and single-switch scanning support
- **Guided Access** compatibility — critical; it keeps a child inside the app
- **Fully configurable response windows; no fixed timeouts anywhere**
- **AAC device coexistence** — never fight the child's existing AAC app or hardware
- VoiceOver and Dwell support
- High-contrast, low-clutter visuals; strict stimulus style guide (uncluttered backgrounds — visual clutter is a real barrier here)

### Procurement artifacts
- **VPAT / ITI Accessibility Requirements Report** produced **before the first district RFP** — "we'll do it later" loses deals
- ADA Title II final rule pushes WCAG 2.1 AA onto public schools (large: April 2026); building to 2.2 AA clears it
- EN 301 549 + European Accessibility Act (obligations began 28 June 2025)

---

## 5. Visual direction

- **Palette:** desaturated, calm, high-contrast where it carries meaning. No saturated red/yellow at scale. Full light and dark themes.
- **Motion:** one element moves at a time; all motion respects reduce-motion; no parallax, no idle loops.
- **Typography:** adult surfaces only. Generous sizing, dyslexia-friendly defaults, system font scaling honoured.
- **Imagery:** real photographs for nouns, video for actions, uncluttered neutral backgrounds, consistent framing for mouth models.
- **Audio:** human voice models, not synthesis, for target words. Consistent, low-arousal UI sounds. Everything independently mutable.
