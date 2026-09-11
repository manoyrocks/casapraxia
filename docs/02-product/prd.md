# Product Requirements Document — Praxia v1 (MVP)

**Target:** 4–6 months to TestFlight beta with design partners.
**Team assumption:** 1 senior iOS engineer, 1 backend engineer, 1 product designer, 1 content producer (part-time), 1 SLP clinical advisor (contract), 1 PM.

---

## 1. MVP scope

### In scope

| Epic | Summary |
|---|---|
| **E1. Onboarding & consent** | Guardian account, child profile, red-flag screening, layered consent, hearing-status gate, optional SLP link |
| **E2. Practice engine** | The core loop: cue hierarchy state machine, trial delivery, fading, safety stop, session capping |
| **E3. Child experience** | Three surfaces — Talk (AAC), Play (practice), Collection — low-stimulation, zero reading |
| **E4. Capture & scoring** | Audio capture done correctly, Tier-1 signals, parent three-tap scoring |
| **E5. AAC core board** | ~40-cell fixed-position core board, free, ungated, one tap from anywhere |
| **E6. Parent coaching** | In-session coaching strip, ≤90s micro-lessons, weekly behaviour goals, before/after clip |
| **E7. Clinician portal (web)** | Caseload triage, target & cue control, clip review, async video reply, progress charts, IEP export |
| **E8. Data & sync** | Event-sourced trial log, offline-first, encrypted local store, deferred upload |
| **E9. Compliance** | VPC, retention jobs, deletion, audit log, DPIA, accessibility conformance, claims register |

### Explicitly out of scope for v1

- Any machine **accuracy** score, including DTW (v1.5 — see [CR-1](../01-research/D-synthesis-and-conflict-resolution.md))
- Android client (Phase 3)
- School/district tenancy, SSO, roster sync (Phase 3)
- Formant/vowel-space charts, VOT, forced alignment + GOP (research-flagged, Phase 2+)
- Full AAC system competing with Proloquo2Go (mirror mode only)
- In-app purchase of anything affecting the child experience (banned permanently)

---

## 2. Epics and user stories

### E1 — Onboarding & consent

**E1.1** As a guardian, I complete account creation and add a child profile using **minimal identifiers** (first name, DOB month/year only) so my child's data footprint is small.

**E1.2** As a guardian, I complete a **red-flag screening** covering the eight items in the [clinical program spec](clinical-program-spec.md) §5.
- *AC:* A positive screen on dysphagia, regression, seizures, or breathing/voice change **blocks onboarding** and presents referral guidance. It does not warn-and-continue.
- *AC:* Unconfirmed hearing status **gates the speech pathway**; AAC and Play remain fully available.
- *AC:* Re-screened every 90 days.

**E1.3** As a guardian, I give **layered, independently revocable consent** across five toggles: core service / on-device recording / cloud storage / clinician sharing / model training / research publication.
- *AC:* Model-training consent is **never bundled** with any other toggle (COPPA, binding since 22 Apr 2026).
- *AC:* VPC via card authorisation or signed-form upload. **Email-plus is insufficient** because we share with clinicians and intend to train.
- *AC:* Each consent records timestamp, policy version, and verification method.

**E1.4** As a child, I am shown a simple pictorial **assent** screen before any recording ("we're going to record your voice so you can hear yourself").

**E1.5** As a guardian, I can link my child to an SLP by code, or search for one if I have none.
- *AC:* Families without an SLP are actively routed toward evaluation, not retained as unmanaged users.

### E2 — Practice engine

**E2.1** As the system, I maintain **per-target cue-level state** (L0–L5 plus orthogonal visual/gestural/rhythmic/frame dimensions) and persist it across sessions.

**E2.2** As the system, I **advance after 3 consecutive accurate** productions and **back off after 2 consecutive inaccurate**, immediately.
- *AC:* Backing off produces **no child-visible signal whatsoever** — no animation, no sound, no copy.

**E2.3** As the system, I **auto-retire a target** falling below 40% success across 10 consecutive trials at the lowest available cue level, and flag it for clinician review.

**E2.4** As the system, I select targets **only at, or one step beyond, the child's current syllable-shape inventory.**

**E2.5** As the system, I **end the session** at the trial target or 10 minutes, whichever comes first.
- *AC:* No "continue?" prompt that invites over-drilling.
- *AC:* The session **never ends on a failed trial** — always on success and the end ritual.

**E2.6** As the system, I detect **aversion signals** (rising latency, rising no-response, mid-session exits, declining volume) and respond by reducing demand, switching to play/AAC, or ending — telling the parent that stopping early was correct.

**E2.7** As a clinician, I set the bounds within which the adaptive engine may operate, and **the engine may never exceed them.**

### E3 — Child experience

**E3.1** As a child, I see exactly **three surfaces** — Talk, Play, Collection — with no nested menus and depth ≤2.

**E3.2** As a child, I encounter **zero reading**. All child-facing content is photograph, video, icon, or speech.

**E3.3** As a child, I experience **no failure state** — no red X, no buzzer, no loss, no timers, no restart, no health bar.

**E3.4** As a child, I **choose** — the activity, the companion, the order of targets, which reward to open.

**E3.5** As a child, I get a **transition warning** ("two more") using concrete countable tokens that disappear, never an abstract timer bar.

**E3.6** As a child, every session follows an **identical skeleton**: greeting → choose → trials → celebration → collection → consistent goodbye.

**E3.7** As a guardian, I reach a **sensory panel** at all times: sound, music (independent of voice), animation, haptics, dark mode, model playback speed, reward intensity.
- *AC:* Ships with **low-stimulation defaults**, not high-stimulation-with-an-off-switch.
- *AC:* Honours OS `prefers-reduced-motion` and Reduce Motion / Reduce Transparency automatically.

**E3.8** As the system, my **dominant feedback mechanism is contingency, not evaluation** — the attempt causes something in the world ("up" makes the balloon go up). Every attempt receives immediate, identical, warm acknowledgement; evaluation comes from the human.

**E3.9** As the system, I advance the story/collection **contingent on attempts made, not accuracy** — so effort always advances the world and no adult is incentivised to score generously.

### E4 — Capture & scoring

**E4.1** As the system, I capture **16 kHz mono PCM with AEC/AGC/noise-suppression disabled** (`AVAudioSession .measurement`), with per-session calibration and an SNR gate.
- *AC:* Below the SNR threshold I **refuse to compute** acoustic measures rather than report invalid ones.

**E4.2** As the system, I compute **Tier-1 signals only**: vocalization detected, attempt count, response latency, phonation duration, syllable-count estimate, pitch contour.
- *AC:* **No machine accuracy score exists in v1.**

**E4.3** As a parent, I score an attempt with **three large taps** — got it / close / not yet — in under 1 second, one-thumb.
- *AC:* Scoring is **optional**; silence records *unscored*, never *zero*.
- *AC:* The app is fully functional with **zero parent input**.

**E4.4** As the system, I reinforce the child within **≤150 ms** of detecting vocalization, and deliver trial feedback within **≤300 ms** of utterance offset.

**E4.5** As the system, the **entire practice loop works fully offline.** No network call is ever on the child's critical path.

**E4.6** As the system, I never say "couldn't hear you, try again" to the child. Ambiguity resolves **silently upward to the adult.**

### E5 — AAC core board

**E5.1** As a child, I reach the AAC board in **one tap from any screen**, always, with no paywall and no gate.

**E5.2** As the system, button positions are **invariant** and never reorganise.

**E5.3** As the system, current speech targets **auto-populate** the board, sharing word, image, and voice model.

**E5.4** As the system, I accept **"vocal approximation + button press" as success**, never button press instead of speech or vice versa.

**E5.5** As the system, I track the **modality ratio** (AAC-only / AAC+vocal / vocal-only) per target and overall.

**E5.6** As a family with an existing AAC system, I use **mirror mode** — Praxia mirrors target symbols and defers to Proloquo2Go/LAMP/TouchChat.

### E6 — Parent coaching

**E6.1** As a parent, I see an **in-session coaching strip** with in-the-moment prompts: "Wait — give him 8 seconds." / "That was an approximation. Accept it and move on." / "He's losing steam — three more and finish."

**E6.2** As a parent, I get **≤90-second contextual micro-lessons**, one idea each, never a curriculum I must complete. Priority order: CAS is a motor problem not a "won't talk" problem → modelling without demanding → wait time → accepting approximations → **AAC does not delay speech** → cueing and fading → short frequent sessions → embedding in routines → recognising dysregulation → stopping without a fight.

**E6.3** As a parent, my weekly goals are expressed as **behaviours I control** ("practice on 4 days"), never as child outcomes.

**E6.4** As a parent, I receive an auto-generated **before/after audio clip every two weeks** — the child's best current attempt against the same target 6 weeks earlier.
- *AC:* First one lands by **day 10**, from the day-1 baseline recording. This is the primary retention mechanism.

**E6.5** As a parent, my **practice rhythm** is shown as a 4-week heatmap with a bucket goal, **never a consecutive-day streak, never a broken state.**
- *AC:* Re-entry after a lapse is neutral and short: "Welcome back. Let's do three minutes."

**E6.6** As a parent, progress defaults to a **12-week window**, because CAS progress is visible over months, not days.

**E6.7** As a parent, when a target is stuck 3+ weeks I am told plainly, given the reason, and offered a **one-tap message to my SLP**.

### E7 — Clinician portal (web)

**Hard constraint: ≤2 minutes per client per week.** Anything costing more will not be used.

**E7.1** As an SLP, I see a **triage queue**, not a dashboard — one row per client, three signals (practice volume vs goal, targets needing attention, last contact), sorted by "needs you."

**E7.2** As an SLP, I set the target list from a curated library or **custom targets with models recorded in my own voice**, and I set per-target cue level, complexity, practice-type mix, and the engine's auto-advance bounds.

**E7.3** As an SLP, I review clips **keyboard-driven** (space=play, 1/2/3=score) so 20 clips take 3 minutes, filtered by new target / high uncertainty / random sample.
- *AC:* I apply IPA transcription, cue level actually needed, and a correctness judgment.
- *AC:* ~10% of clips route to **two raters**; Cohen's κ is tracked.

**E7.4** As an SLP, I record a **20–60 second async video reply** attached to a target or clip, landing as a card in the parent's app.

**E7.5** As an SLP, I see **accuracy charted with cue level overlaid** — accuracy without cue level is meaningless, since a drop in accuracy at a *lower* cue level is progress.

**E7.6** As an SLP, I export an **IEP-ready report** in one click: baseline, measurable goal statement, data table, trend, dates, cue-level definitions, editable narrative draft.

**E7.7** As an SLP, I see an **over-practice flag** when home volume exceeds safe bounds.

### E8 — Data & sync

**E8.1** Every trial is written to the local encrypted store **synchronously, before any UI transition.**

**E8.2** The trial log is **append-only and immutable**, with client-generated UUIDv7, device ID, and both `client_ts` and `server_ts` (never trust device clocks for research data).

**E8.3** `CueLevel` is a **first-class field on every trial.**

**E8.4** A trial carries **multiple Score rows** keyed by rater (`parent` / `slp` / `model:vX`), **never collapsed to one.**

**E8.5** Audio uploads are deferred to wifi + charging + consent, content-addressed (SHA-256) for idempotent retry.

### E9 — Compliance

**E9.1** Raw audio **never leaves the device** without a specific consent toggle. Default retention 90 days, `NSFileProtectionComplete`.

**E9.2** **Zero third-party analytics, ads, attribution, or PII-carrying crash SDKs** in the child client. First-party, on-device-aggregated, non-identifying telemetry only.

**E9.3** Every user-facing and marketing string passes through the [claims register](../05-compliance/claims-register.md).

**E9.4** Full **audit log of every audio playback** — who listened to a child's voice and when — visible to the parent.

**E9.5** One-tap "delete my child's data," honoured within 30 days, cascading to backups and object storage, with a deletion receipt.

**E9.6** WCAG 2.2 AA + platform accessibility APIs; ≥64pt child touch targets; Switch Control; Guided Access compatibility; no fixed timeouts; non-drag alternative for every drag.

---

## 3. Non-functional requirements

| ID | Requirement |
|---|---|
| **NFR-1** | ≤150 ms vocalization → child reinforcement |
| **NFR-2** | ≤300 ms utterance offset → trial feedback |
| **NFR-3** | Practice loop **100% functional offline** |
| **NFR-4** | 30-minute session without thermal throttling or >15% battery on a 3-year-old iPad |
| **NFR-5** | Cold start to first trial ≤ 90 seconds *including* parent setup |
| **NFR-6** | Starter video/stimulus set **bundled in-app**; active program assets pinned and never evictable |
| **NFR-7** | Crash-free session rate ≥ 99.5% |
| **NFR-8** | Regression suite of recorded audio fixtures replayed through the DSP **on every iOS beta** |

---

## 4. Success metrics

**Leading (what we watch weekly):**
- Median **trials per active child per week** — the north-star input metric
- % of families reaching the ≥2 sessions/week evidence floor
- Day-10 before/after clip delivery rate
- Parent scoring rate (target: >60% of trials, but the app must work at 0%)
- SLP weekly active rate and clips reviewed

**Lagging (what we watch quarterly):**
- Cue-level distribution shift per child
- Syllable-shape inventory growth
- Modality ratio movement (AAC-only → AAC+vocal → vocal-only)
- ICS trend at 8–12 weeks
- Generalisation and maintenance probe scores

**Explicitly NOT success metrics:** session minutes, streak length, rewards earned, DAU-as-engagement. Reporting these as progress is the conflation the entire category is built on.

**Counter-metrics (guardrails we watch for harm):**
- Aversion-detection trigger rate
- Over-practice flag rate
- Targets auto-retired by the safety stop
- Parent-reported distress during practice

---

## 5. Open questions requiring a decision before build

| # | Question | Needed by |
|---|---|---|
| Q1 | Product name and trademark clearance ("Praxia" is provisional) | Before design system |
| Q2 | Does the SLP advisory board ratify the L0–L5 hierarchy and the 3-up/2-down fading rule? | Before E2 |
| Q3 | Content production: in-house studio vs contracted? ~150 model videos for v1 | Before Phase 1 close |
| Q4 | Which Safe Harbor — kidSAFE vs PRIVO? | Before consent build |
| Q5 | Do we seek IRB + university clinic partnership for a seed corpus? | Phase 2 planning |
| Q6 | Confirm Education category (not Kids Category) with App Review pre-submission | Before submission |
