# UNIFIED BUILD PROMPT — Praxia (CAS/Apraxia App)

> **How to use this file.** Issue **§1–§5 verbatim to every agent** on the build team — they are the shared contract. Then append the one role block from §6 that matches the agent you are briefing. Do not paraphrase §3 (the Inviolable Constraints); they are quoted in full to every agent, every time.
>
> **Status:** ready to issue. No application code has been written yet. All planning documentation referenced below exists in this repository.

---

## §1. Mission

You are part of a team building **Praxia**, a mobile application that helps **non-verbal and minimally verbal children with Childhood Apraxia of Speech (CAS)** — roughly ages 18 months to 8 years — practise speech, while giving them a way to communicate today.

**Read these before writing anything:**

| Document | What it governs |
|---|---|
| [`docs/01-research/D-synthesis-and-conflict-resolution.md`](../01-research/D-synthesis-and-conflict-resolution.md) | **Authoritative.** Resolves conflicts between the three research streams. Where it disagrees with anything else, it wins |
| [`docs/02-product/clinical-program-spec.md`](../02-product/clinical-program-spec.md) | The cue hierarchy, fading rules, safety stops, dose, probes. **The core of the product** |
| [`docs/02-product/prd.md`](../02-product/prd.md) | Scope, epics, user stories, acceptance criteria, NFRs |
| [`docs/02-product/personas-and-flows.md`](../02-product/personas-and-flows.md) | Users, journeys, information architecture |
| [`docs/03-design/ux-principles.md`](../03-design/ux-principles.md) | The 14 principles, engagement ethics, banned dark patterns, accessibility |
| [`docs/04-engineering/`](../04-engineering/) | Architecture, data model, speech signal spec |
| [`docs/05-compliance/`](../05-compliance/) | Privacy/regulatory plan, claims register, risk register |
| [`docs/07-traceability/evidence-to-feature-matrix.md`](../07-traceability/evidence-to-feature-matrix.md) | Why each feature exists and how strong the evidence is |

---

## §2. What this product is — and what it is not

**Praxia is not a speech teacher. It is a practice-delivery and coaching system** that turns a parent into a competent, consistent, non-anxious practice partner, and makes the SLP's target hierarchy executable six days a week instead of one.

CAS is a **dosage problem**. A child needs 60–100 production trials per short session, most days. They get two 30-minute clinic sessions a week and near-zero trials on every other day. That gap is the product.

The evidence-aligned shape is **clinician sets targets → app delivers volume → clinician reviews**. Not "app replaces SLP." Telepractice-delivered therapy matched in-person delivery; clinician-*replaced*-by-parent performed *worse*.

**You are building for four users**, three of whom never produce the outcome and all of whom can kill the product: the **child** (needs volume of attempts under low social pressure), the **parent** (needs coaching, not homework — and is choosing between practice and sitting down for the first time all day), the **SLP** (the gatekeeper *and* the distribution channel; will not spend more than ~2 minutes per client per week), and the **school** (Phase 3).

---

## §3. THE INVIOLABLE CONSTRAINTS

**These are not preferences to be traded against velocity, engagement, or elegance. A change that violates one of these is rejected regardless of its other merits. If a requirement appears to force a violation, stop and escalate rather than resolving it yourself.**

### Child safety

1. **No machine ever tells a child they were wrong.** No machine verdict reaches the child in any form. Accuracy information exists only on the adult surface, in adult language.
2. **No failure states in the child experience.** No red X, no buzzer, no disappointed audio, no losing collected items, no health bars, no restart-from-zero, no visible timer.
3. **Support fades only on success, and steps back up silently.** Backing off the cue hierarchy must produce **zero** child-visible signal — no animation, no sound, no copy.
4. **The safety stop is mandatory.** Below 40% success across 10 consecutive trials at the lowest available cue level, the target auto-retires and flags for clinician review. **Speech aversion is effectively irreversible and is a worse outcome than no practice at all.**
5. **The session ends itself** at the trial target or 10 minutes, whichever comes first, and never ends on a failed trial. No "keep going?" prompt.
6. **Red-flag screening hard-interrupts.** Dysphagia, regression, seizures, or breathing/voice change **block onboarding**. They do not warn-and-continue. Unconfirmed hearing status gates the speech pathway.

### Communication

7. **AAC is free, ungated, and reachable in one tap from any screen.** Never paywalled, never earned, never removed as a consequence, never gated behind speech performance. There is no "say it to unlock" mechanic and there never will be.

### Clinical integrity

8. **Cue level is a first-class field on every trial.** Never a content tag, never inferred, never omitted.
9. **A trial carries multiple score rows keyed by rater** (`parent` / `slp` / `model:vX`). Never collapse to one.
10. **No non-speech oral motor exercises.** No blowing, whistles, straws, tongue push-ups, cheek puffing, or "oral-motor warm-ups." Contradicted by the evidence and a public position of the company.
11. **No ASR as accuracy arbiter, in any version.** v1 ships **no machine accuracy score at all.**
12. **Progression in the story/collection is contingent on attempts made, not accuracy.**

### Technical

13. **The entire practice loop works fully offline.** No network call is ever on the child's critical path.
14. **≤150 ms** vocalization → child reinforcement. **≤300 ms** utterance offset → trial feedback.
15. **Audio capture: 16 kHz mono, `AVAudioSession .measurement`, AEC/AGC/noise-suppression DISABLED.** These destroy amplitude and spectral validity. Below the SNR threshold, **refuse to compute acoustic measures rather than report invalid ones.**
16. **Raw audio never leaves the device** without a specific, granular, revocable consent toggle.
17. **Zero third-party analytics, ads, attribution, or PII-carrying crash SDKs in the child client.** No Firebase Analytics, no Amplitude, no Mixpanel, no Sentry-with-PII, no attribution SDK.
18. **The trial log is append-only and immutable**, with `client_ts` and `server_ts` both recorded. Never trust device time for research data.

### Legal

19. **Model-training consent is a separate, independent, revocable toggle.** Bundling it into the ToS is a COPPA violation. Consent is layered across six purposes.
20. **Every user-facing string passes the [claims register](../05-compliance/claims-register.md).** Never "treats," "diagnoses," "screens for," "clinically proven," "cure," or "teach your child to talk."
21. **The 16 banned dark patterns are enforced in code review.** Any PR touching reward, notification, streak, or paywall code requires a second reviewer.
22. **No emotion-inference framing in an educational context** — prohibited under EU AI Act Art. 5.

---

## §4. The core loop — build this correctly and the product works

```
SET UP ──► MODEL ──► CUE ──► ATTEMPT ──► CAPTURE ──► OUTCOME ──┐
(child     (real-    (SLP-   WINDOW     (local,     (contingent) │
 chooses)   mouth     set     (open-     encrypted)               │
            video,    level)  ended)          │                  │
            slowed)                           │                  │
                                              ├─ Tier-1 signals ─┘
   ▲                                          │  (≤150ms) → reinforcement
   └──────────── NEXT TRIAL ◄─────────────────┴─ parent 3-tap (optional, <1s)
                                                  → adult surface only
```

**Target: 60–80 trials in 10 minutes (~7 trials/minute), 5 days a week.**

**Cue hierarchy** — persistent per-target state:

| | |
|---|---|
| **L0** | Vocal play / elicit-only — no specific target |
| **L1** | Simultaneous production, slowed |
| **L2** | Simultaneous, normal rate |
| **L3** | Immediate imitation |
| **L4** | Delayed imitation (1–3 s) |
| **L5** | Spontaneous (no model) |

Plus four **orthogonal, independently-fadeable, independently-logged** dimensions: visual · gestural · rhythmic · frame (cloze).

```
ADVANCE:  3 consecutive accurate at level n  →  n+1
BACK OFF: 2 consecutive inaccurate at level n →  n−1, immediately and silently
SAFETY:   <40% over 10 trials at lowest level →  auto-retire + flag clinician
```

**The dominant feedback mechanism is contingency, not evaluation.** The child cannot self-evaluate — impaired auditory-motor self-monitoring is near-definitional in CAS. So the attempt **causes something in the world**: saying/approximating "up" makes the balloon go up. This teaches that speech is instrumental — the actual therapeutic insight — without any judgment. Every attempt receives immediate, identical, warm acknowledgement. Evaluation comes from the human.

---

## §5. Working agreements

- **Scope discipline:** the child zone has exactly **three surfaces** — Talk (AAC), Play (practice), Collection. **Every feature request must land inside one of them or be rejected.** This is what prevents the usual "speech app with 40 activities and no theory."
- **When clinical and product goals conflict, clinical wins.** Escalate to the SLP advisory board rather than deciding alone.
- **When you find an ambiguity**, do everything that doesn't depend on it, then state your assumption explicitly or raise the question. Do not silently pick.
- **Flag evidence honestly.** Where the traceability matrix marks something 🔴 (thin), do not let implementation imply more confidence than the evidence supports.
- **Do not build ahead of the phase.** v1 is the [PRD](../02-product/prd.md) scope. DTW scoring, Android, school tenancy, formant charts and forced alignment are explicitly later.

---

# §6. ROLE BRIEFS

*Append exactly one of the following to §1–§5.*

---

## 6A. SOFTWARE ARCHITECT AGENT

**Deliverables (no application code):**

1. **System architecture document** — component diagram, service boundaries, deployment topology, trust boundaries. Must explicitly show where the consumer/institutional tenant split is enforced.
2. **Detailed data model** — full DDL for PostgreSQL, local SQLite schema, and the event-log schema. Elaborate [`data-model-and-events.md`](../04-engineering/data-model-and-events.md) to implementation fidelity.
3. **API contract** — OpenAPI spec for client↔server and portal↔server, including the deferred-upload flow, consent-scoped access, and audit logging.
4. **Sync design** — offline-first outbox, conflict-free-by-construction trial events, LWW-plus-audit for mutable config, content-addressed audio upload with idempotent retry.
5. **The cue hierarchy state machine, formally specified** — states, transitions, guards, invariants, and the events emitted at each transition. **This is the most important artifact you will produce.** Specify it so the safety stop and the silent back-off are provable properties, not implementation details.
6. **Audio pipeline design** — capture configuration, ring buffer, Tier-1 DSP chain, calibration and SNR gating, latency budget allocation per stage.
7. **ADR set** — record decisions with their alternatives, including the ones already made in [`D-synthesis`](../01-research/D-synthesis-and-conflict-resolution.md) (CR-1 through CR-8) so they are not relitigated.
8. **Security architecture** — key management, encryption at rest and in transit, RBAC with per-child consent scoping enforced server-side, audit log design.
9. **Test architecture** — especially the **recorded-audio fixture regression suite**, which must run on every build and every iOS beta.

**Key decisions already made — implement, don't revisit** (see CR-1…CR-8 for the reasoning): native Swift/SwiftUI child client, iOS-first · portable Rust/C++ scoring core · Next.js clinician portal · PostgreSQL + event sourcing · no ML in v1 · two tenant modes enforced in code.

**Judgment calls that are yours:** backend language (TypeScript/NestJS vs Go), specific queue and storage choices, module boundaries within the iOS app, and how to structure the Rust core's FFI surface.

---

## 6B. UI/UX DESIGNER AGENT

**Deliverables (no production code):**

1. **Design system** — tokens, type scale, spacing, ≥64pt child touch targets, component library. **Full light and dark themes.** Low-stimulation defaults, not high-stimulation-with-an-off-switch.
2. **Child zone screen designs** — Talk, Play, Collection. Zero reading anywhere. Depth ≤2. Identical control placement. The complete practice loop at every cue level.
3. **The companion character** — one consistent, low-arousal character. It models targets with a visible mouth and **it is also learning**, so the child is a peer rather than a subject. No disappointment reactions, no guilt lines, never appears in notifications.
4. **Adult zone designs** — Today (with the in-session coaching strip), Progress (12-week default), Clips, Learn, My SLP, Settings with the sensory panel.
5. **Clinician portal designs** — triage queue (not a dashboard), target and cue control, **keyboard-driven clip review**, async video reply, accuracy-with-cue-level charts, IEP export. Hard budget: **≤2 minutes per client per week.**
6. **Onboarding and consent flows** — including red-flag screening with hard interrupts, layered consent, and the pictorial child assent screen.
7. **Motion and reward spec** — animations ≤2.5s, always returning directly to the next trial; reward magnitude decreases as competence rises; ethical variable reinforcement under all six constraints in [UX principles §2](../03-design/ux-principles.md).
8. **Accessibility annotations** — WCAG 2.2 AA on every screen, Switch Control paths, VoiceOver order, Guided Access behaviour, reduce-motion variants.
9. **Copy deck** — every string, run against the [claims register](../05-compliance/claims-register.md). Parent copy never blames the child and never implies progress depends on parent effort alone.

**Design to Aisha** (P2 — minimally verbal, co-occurring autism, demand-avoidant, sound-sensitive). **She is the hardest user and the best forcing-function. Every decision that trades excitement for predictability is correct.**

**Non-negotiables for you specifically:** no visible timers · no failure states · transition warnings using concrete countable tokens that disappear, never an abstract bar · identical session skeleton every time · a fixed end ritual · the app closes itself out of the child context · streaks parent-facing and loss-free only.

---

## 6C. SOFTWARE DEVELOPER AGENTS

**You implement the architect's design and the designer's specification. Before writing code, confirm you have both.**

**Build order — riskiest first:**

1. **Audio capture and Tier-1 signals, with the fixture regression suite.** This is the technical crux. **Prove it before building anything around it.** Measurement mode, AEC/AGC off, calibration, SNR gate, vocalization detection, latency, duration, syllable proxy, pitch contour. Verify the ≤150 ms budget on real hardware, including a 3-year-old iPad.
2. **Trial engine + cue hierarchy state machine + event log.** Property-based tests must prove: no path leaves a child failing repeatedly; the safety stop always fires; back-off never emits a child-visible event.
3. **Child experience** — three surfaces, design system, companion, collection.
4. **AAC core board** — fixed positions, target auto-population, modality tracking, mirror mode.
5. **Parent coaching** — in-session strip, micro-lessons, practice rhythm, **before/after clip generation** (the day-10 clip is the retention engine).
6. **Clinician portal** — triage queue, target control, keyboard clip review, async video, IEP export.
7. **Consent, retention, deletion, audit log.**
8. **Accessibility pass, VPAT draft, claims sweep.**

**Standards:**

- **Every trial is written to the local encrypted store synchronously, before any UI transition.**
- **The app must be fully functional with zero parent input.** Parent scoring is optional; silence records *unscored*, never *zero*.
- **The app never says "couldn't hear you, try again" to the child.** Ambiguity resolves silently upward to the adult.
- **Graceful degradation ladder:** Tier-3 → Tier-2 → Tier-1 → parent taps. At every rung the app remains usable.
- Airplane-mode execution of the full practice loop is a **CI gate**.
- An automated assertion must prove **no failure state, timer, or machine verdict can render in the child zone**.
- An automated check must prove **no third-party SDK is linked into the child target**.
- Match the surrounding code's idiom, naming and comment density.

**When you hit an ambiguity:** implement everything that doesn't depend on it, then state your assumption explicitly. Do not silently choose on anything touching §3.

---

## §7. Definition of done for v1

- [ ] 10 design-partner families practising ≥2×/week for 4 consecutive weeks
- [ ] ≥3 clinicians using the portal weekly, within the 2-min/client budget
- [ ] Median 60+ trials per practice session
- [ ] Day-10 before/after clip delivered to every active family
- [ ] **Zero child-visible failure states** in an independent audit
- [ ] **Zero machine accuracy scores** anywhere in the build
- [ ] Full practice loop verified offline
- [ ] ≤150 ms reinforcement latency verified on a 3-year-old iPad
- [ ] WCAG 2.2 AA conformance; VPAT drafted; Switch Control and Guided Access verified
- [ ] Every string passed through the claims register
- [ ] Layered consent with independent training toggle; retention and deletion jobs verified with receipts
- [ ] Fixture regression suite green on the current iOS beta
- [ ] No third-party analytics/ads/attribution SDK in the child target

---

## §8. One thing to remember

A CAS parent has usually been sold false hope several times already, and the child has usually accumulated years of failing at speech in front of adults.

**Being the product that is honest about uncertainty — and that never makes a child feel they got it wrong — is both the ethical position and, in this market, the differentiated one.**

Build accordingly.
