# Personas, Journeys & Information Architecture

---

## 1. Personas

### P1 — Mateo, 3y2m · "The classic CAS toddler"
Diagnosed at 2y10m after 14 months of "wait and see." ~8 consistent word approximations, vowel distortions, groping on attempts, highly inconsistent (says "ba" for *ball* once, then can't repeat it). **Receptive language age-appropriate** — he understands everything, and his frustration is proportional to that gap. Bites his own hand when not understood. Loves vehicles, hates sudden loud sounds. Tolerates an iPad for ~10 minutes *if he controls it*.
→ **Needs volume of attempts under low social pressure, and a way to communicate today.**

### P2 — Aisha, 5y7m · "Minimally verbal, co-occurring autism"
ASD at 3, CAS suspected/co-occurring. ~15 mostly-request words plus a 60-button AAC grid used inconsistently. Strong visual learner, echolalic in bursts, **demand-avoidant** — any direct request ("say cup") produces immediate withdrawal. Needs predictable sequence, hates transitions, over-responsive to sound (covers ears at cartoon jingles), under-responsive to proprioceptive input.
→ **The hardest user and the best design forcing-function. Every decision that trades excitement for predictability is correct.** Practice must be embedded in play, never framed as a demand. Her AAC is never taken away or gated.

### P3 — Danielle, 34 · "The exhausted mother"
Two kids, works 30 hrs/wk, Mateo's mother. $800/mo on private SLP after insurance denied "developmental" claims. Has downloaded 6 speech apps; used 2 more than twice. Reads Apraxia Kids forums at 11pm. Feels guilty daily.
> *"I don't need more exercises. I need to know if what I'm doing is right."*
→ **Coaching and honest reassurance are features, not marketing.** Churns if week 3 produces no visible signal.

### P4 — Ray, 41 · "The secondary caregiver"
Mateo's father; bedtime and weekend mornings. Would practise if told exactly what to do. Won't read more than a paragraph. Won't attend the SLP session.
→ **Multi-caregiver accounts with a zero-onboarding "just tell me what to do right now" mode**, plus consistency guardrails so he doesn't cue differently from Danielle.

### P5 — Karen, 48, CCC-SLP · "The skeptical clinician"
Private paediatric practice, 8 clients/day, PROMPT-trained, ~6 CAS children on caseload. Recommends exactly two apps and badmouths the rest. Believes most "speech apps" are vocabulary flashcards with a badge system. **Will evaluate Praxia in 10 minutes and decide forever.**
→ Adopts if she controls targets and cue level, the home data is trustworthy, and the marketing never says "therapy" or "cure." **She is both the veto and the distribution channel** — each clinician brings 3–15 families.

### P6 — Marcus, 52 · District special-ed director *(Phase 3)*
Buys on caseload efficiency, privacy compliance and IEP defensibility. July budget cycle, 6–12 month procurement, requires DPA/VPAT/SSO and a Chromebook-accessible surface.

---

## 2. The day-in-the-life that defines the product

**Mateo's typical non-therapy day:** wakes, points and leads-by-hand for breakfast, is misunderstood twice before 8am, preschool where peers have stopped trying to talk to him, evening where a tired parent tries SLP "homework" for four minutes before both give up.

**Total speech-motor practice trials: near zero.**

That number is the product's north-star input metric. Everything in Praxia exists to move it.

**Danielle's competing alternatives at 7pm:** practice vs bath vs *sitting down for the first time all day*. The app competes with the parent sitting down. **If setup exceeds ~90 seconds, or the session doesn't reliably produce a moment of shared joy, it loses that competition permanently.**

---

## 3. Information architecture

```
PRAXIA
│
├── CHILD ZONE  (no reading, depth ≤2, no modals)
│   ├── TALK        — AAC core board. One tap from anywhere. Never gated.
│   ├── PLAY        — the practice loop
│   └── COLLECTION  — the earned world
│
└── ADULT ZONE  (behind a parent gate)
    ├── Today          — what to practise now, coaching strip
    ├── Progress       — 12-week default; cue-level chart, inventory map, modality ratio
    ├── Clips          — before/after reels, keepsakes, per-clip delete
    ├── Learn          — ≤90s micro-lessons
    ├── My SLP         — messages, async video replies, link/unlink
    └── Settings       — sensory panel, consent toggles, data export & delete, audit log

CLINICIAN PORTAL (web, separate auth)
    ├── Caseload       — triage queue
    ├── Child          — targets, cue control, engine bounds, program
    ├── Review         — keyboard-driven clip review + labelling
    ├── Progress       — accuracy × cue level, inventory, probes
    └── Reports        — IEP export
```

**The structural discipline:** exactly three child-facing surfaces. **Every feature request must land inside one of them or be rejected.** This is what keeps the product from becoming the usual "speech app with 40 activities and no theory."

---

## 4. Core loop

```
   ┌──────────────────────────────────────────────────────────┐
   │                                                          │
   ▼                                                          │
SET UP ──► MODEL ──► CUE ──► ATTEMPT ──► CAPTURE ──► OUTCOME ──┘
(child     (real-    (SLP-   WINDOW     (local,     (contingent:
 chooses)   mouth     set     (open-     encrypted)   the word
            video,    level)  ended)                  makes the
            slowed)                                   thing happen)
                                    │
                                    ├──► Tier-1 signals (≤150ms) ──► child reinforcement
                                    └──► parent 3-tap score (optional, <1s) ──► adult surface
```

**MODEL** — full-screen close-up of a real human mouth producing the target, slowed, repeat-on-tap, optional split-screen with the referent object. **This is the highest-leverage asset in the product and the real moat.**

**ATTEMPT WINDOW** — open-ended. Unambiguous, consistent, non-pressuring "your turn" signal (companion turns to look; mic ring pulses slowly). **No timeout that punishes.** A soft re-prompt after long silence, then an offer to move on.

**OUTCOME** — contingency, not evaluation. For a child who cannot self-evaluate (impaired auditory-motor self-monitoring is near-definitional in CAS), the strongest unambiguous signal is that **the attempt causes something in the world.** This teaches *speech is instrumental* — the actual therapeutic insight — without any judgment.

---

## 5. Key journeys

### J1 — First session (the make-or-break)
1. Guardian installs, creates account, adds child with minimal identifiers
2. **Red-flag screening** — hard interrupt on positive
3. Layered consent + VPC; child assent screen
4. Baseline: 5–8 targets presented at L1, **recorded** — this is the day-1 baseline that powers the day-10 before/after clip
5. Optional SLP link by code
6. **First practice block inside 90 seconds of opening**

*Success criterion: the parent hears their child attempt a sound and feels something.*

### J2 — Daily practice (the loop that matters)
Open → Today shows the loaded, correct session → hand to child → 10 min / 60–80 trials → app ends session → end ritual → parent sees trial count and one coaching note.
*Parent decision cost must be zero. The session is already chosen.*

### J3 — Week 2 — the retention moment
Auto-generated before/after clip: the child's best current attempt against the same target from day 1. **The child's actual voice, not a chart.** This is the single most emotionally powerful artifact the product can create, and it is honest.

### J4 — Stuck target (the honesty test)
3 weeks no movement → plain statement → explanation that this is normal and usually means the target needs changing, not more practice → **one-tap message to the SLP.** Never silent, never flattering.

### J5 — Clinician weekly review (≤2 min/client)
Portal → triage queue sorted by "needs you" → review 10 flagged clips keyboard-driven → adjust two cue levels → record one 20s video reply → done.

### J6 — Aversion event (the safety path)
Rising latency and no-response detected → engine drops cue level → if unresolved, switches to Play/AAC → offers to end → parent told **stopping early was the right call.** Logged as a counter-metric.

---

## 6. Anti-requirements — what must never appear

- A child-visible streak, score, percentage, or failure state
- A timer the child can see
- An ASR verdict shown to anyone as fact
- A locked AAC button
- A "continue practising?" prompt after the session cap
- A milestone comparison to typical development (opt-in and clinically framed, at most)
- Any of the 16 banned dark patterns — see [UX principles](../03-design/ux-principles.md)
