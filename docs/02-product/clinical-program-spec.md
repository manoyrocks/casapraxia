# Clinical Program Specification

**This is the core specification of the product.** It defines the cue hierarchy state machine, target selection, fading rules, safety stops, dose, and the probe schedule. Every rule here is traceable to evidence in [Research A](../01-research/A-clinical-and-evidence.md); the [traceability matrix](../07-traceability/evidence-to-feature-matrix.md) records the mapping.

> **Scope note.** The approach implemented is **DTTC** (Dynamic Temporal and Tactile Cueing, Strand 2020) — the best-supported approach for severe/minimally-verbal young children — augmented with **K-SLP approximation-shaping philosophy** and **rhythmic/prosodic cueing** (AMMT-derived) for elicitation. We do **not** implement ReST (requires three-syllable production our target child does not have), PROMPT (inherently hands-on; an app cannot deliver it), or ultrasound biofeedback (wrong population).

---

## 1. The Cue Hierarchy — a first-class state machine

Cue level is **not a content tag**. It is persistent per-target state, recorded on every single trial, and it is the primary progress signal in the product.

### 1.1 States

| Level | Name | What happens | Support |
|---|---|---|---|
| **L0** | **Vocal play / elicit-only** | No specific target. Contingent imitation of the child's own vocalisations; sound effects; turn-taking. | Maximal — no demand |
| **L1** | **Simultaneous, slowed** | Child and model produce together, model at reduced rate, mouth close-up, optional rhythm/beat | Maximal |
| **L2** | **Simultaneous, normal rate** | Together, normal rate | High |
| **L3** | **Immediate imitation** | Model produces, child repeats immediately | Moderate |
| **L4** | **Delayed imitation** | Model produces, 1–3 s pause, then child produces | Low |
| **L5** | **Spontaneous** | Picture/question prompt elicits production; no model | None |

**Rate normalisation precedes full cue fading at the lower levels** — L1→L2 (slow→normal) resolves before advancing to L3. This is per Strand's DTTC structure.

### 1.2 Orthogonal cue dimensions

Layered onto the temporal hierarchy, each independently fadeable and independently logged:

- **Visual:** mouth close-up video → static mouth image → none
- **Gestural:** parent-performed hand cue (app shows the parent a 2-second loop) → none
- **Rhythmic:** tapped/sung syllable pacing → none
- **Frame (cloze):** target embedded in a highly predictable high-affect frame ("ready, steady… ___", a song, a ritual) → frame progressively stripped

**The frame dimension is how we exploit automatic-to-volitional transfer** — clinically the single most striking feature of CAS (a child may produce "uh-oh" fluently but cannot produce the same syllables on demand). It is logged as its own cue dimension, not folded into the temporal level.

### 1.3 Fading rules (dynamic, trial-by-trial — never session-by-session)

```
ADVANCE:  3 consecutive accurate productions at level n  →  level n+1
BACK OFF: 2 consecutive inaccurate at level n            →  level n−1, immediately and silently
```

**Backing off must never be visible to the child as a demotion.** No animation, no sound, no acknowledgement. The child experiences it as "we're doing it together again."

### 1.4 Safety stop — the aversion circuit breaker

```
IF success rate < 40% across 10 consecutive trials at the LOWEST available cue level
THEN auto-retire the target, flag for clinician review, and switch to a mastered target or play
```

This is a **safety rule, not a pedagogy preference.** A child with severe CAS experiences communicative failure daily. An app that demands productions and marks them wrong can create **speech aversion** — the child stops trying — and once established this is effectively irreversible. It is the worst outcome reachable by this product, worse than no practice at all.

### 1.5 Practice schedule and feedback parameters

Both are **clinician-adjustable with defaults**, never hard-coded — the child CAS evidence for the fine-grained motor-learning principles is genuinely equivocal (Maas & Farinella 2012; Maas, Butalla & Farinella 2012 both found individual variability rather than clean wins).

| Parameter | Default | Rule |
|---|---|---|
| **Practice structure** | Blocked during acquisition | <60% at current level → blocked. >80% for 2 sessions → interleave randomly with other stable targets. |
| **Feedback type** | KP early, KR late | Acquisition: specific, immediate, performance-oriented. ≥80%: outcome-only. |
| **Feedback frequency** | 100% → ~60% | Reduce as targets stabilise, to prevent dependency on external feedback. |
| **Feedback timing** | Immediate → delayed/summary | Delayed and summary feedback favour retention. |

---

## 2. Target selection — inventory-driven, never top-down

The app maintains a **live syllable-shape inventory** and **phonetic inventory** per child.

```
Syllable shapes, in order:  V → CV → VC → CVCV(reduplicated) → CVCV(varied) → CVC → CVCVC
```

**Rule: new targets must use shapes at, or exactly one step beyond, the current inventory.** Never offer a CVC target to a child with a V-only inventory. Targeting phonemes the child cannot approximate produces failure loops, which is the direct path to CR-6/aversion.

Targets are drawn from the child's achievable shapes, chosen to be *slightly* beyond current capability, and are **functional motivating whole words wherever possible** — not isolated phonemes. (NDP3's bottom-up start from isolated sounds sits uneasily with the motor-learning view that the planning unit is the movement gesture across a syllable; this may explain its retention findings.)

**Approximations are accepted as words.** "Ba" for *ball*, "ap" for *apple* — reinforced as legitimate functional communication and shaped over time. Never withhold reinforcement waiting for the adult form. (K-SLP philosophy.)

### 2.1 Phase 0 — the non-verbal starting point

The app must not require the child to say a word in order to enter it. Phase 0 content, in clinical order:

1. **Joint attention and turn-taking** with non-speech (banging, peekaboo, ball roll)
2. **Contingent imitation** — the adult/app imitates the child's *own* spontaneous vocalisations first, building a vocal turn-taking loop without demand
3. **Sound effects and exclamations** — *uh-oh, mmm, brrm, wheee, ahh* — high-affect, meaningful, already in the child's motor repertoire
4. **Vowels** — /ɑ/ (open), /i/ (spread), /u/ (rounded), /oʊ/, /aɪ/ — contrastive jaw height and lip rounding are visible and cueable
5. **CV with maximally visible onsets** — /m, b, p, h, w/ → "ma, ba, mo, bee"
6. **VC** — "up, on, eat" (sometimes easier than CV for children who can phonate but cannot initiate a consonant)
7. **Reduplicated CVCV** — "mama, baba" — one plan repeated; the natural bridge to bisyllables
8. **Vary vowel holding consonant, then vary consonant**

> **Evidence honesty (G-2):** this sequence is drawn from clinical/tutorial literature and expert consensus. **There is no RCT of how to get a non-verbal child to first vocalise.** Phase 0 is authored by the SLP advisory board and its evidence level is stated in-app.

### 2.2 Banned content

**Zero non-speech oral motor exercises.** No blowing, whistles, straws, tongue push-ups, cheek puffing, or "oral-motor warm-ups" (McCauley et al. 2009: insufficient evidence; speech movements are task-specific and there is no evidence of transfer). Visual **placement cues** delivered immediately before a speech target are permitted — that is a cue, not an exercise.

This is a public marketing position, not just an internal rule.

---

## 3. Dose

| Parameter | Value | Source |
|---|---|---|
| **Design trial rate** | ~7 trials/minute | Reconciled A (~6.7/min) vs B (up to 12/min) — see [CR-5](../01-research/D-synthesis-and-conflict-resolution.md) |
| **Default block** | **10 minutes, 60–80 trials, 5–8 targets** | Edeal & Gildersleeve-Neumann 2011 |
| **Default schedule** | 5 days/week, shown to parent as a **"4 days this week" bucket goal** | B's loss-free framing |
| **Evidence floor** | **≥2 sessions/week** — below this the app tells the *clinician* the dose is inadequate | Namasivayam et al. 2015 |
| **Intensive block** | 4–5×/week for 3–6 weeks, then maintenance | Published protocol convention |
| **Hard cap** | Session **ends itself** at trial target or 10 minutes, whichever first | Aversion prevention |

The session ends itself. The user does not have to. The app resists "one more."

**Caveat recorded honestly:** the "100+ trials" heuristic originates in an n=2 alternating-treatments design. It is universally adopted because it is directionally obviously right, **not because it is well-powered.**

### 3.1 Aversion detection

Monitored continuously within session: rising response latency, rising no-response rate, mid-session exits, declining attempt volume. On detection the app **proactively** drops difficulty, switches to play/AAC, or ends the session — and tells the parent that **stopping early was the right call.**

Mandatory **low-demand "play days"** are built into the schedule, where no elicitation occurs.

---

## 4. Measurement — what counts as progress

### 4.1 Primary metrics

| Metric | Why |
|---|---|
| **Trials attempted** | The dose delivered. The app knows this with certainty and needs no ML. For a non-verbal child, **attempt count alone justifies the product.** |
| **Cue-level distribution** | % of trials at each level over time. **Movement toward less support is the primary progress signal** and is meaningful from the very bottom of the range. |
| **Percent Syllables Approximated (PSA)** | Bottom-of-range sensitivity that PCC lacks. |
| **Syllable-shape inventory** | The single most sensitive early metric. {V} → {V, CV} is enormous clinical progress that PCC would barely register. |
| **Modality ratio** | AAC-only / AAC+vocal / vocal-only. Operationalises Millar, Light & Schlosser (2006) and is the truest measure of the speech-AAC bridge. |

**PCC is explicitly rejected as a headline metric** — it floors at zero in this population.

### 4.2 Probes — where real learning shows

| Probe | Schedule | Rule |
|---|---|---|
| **Generalisation** | Every 5 sessions | **Untreated** items sharing structure with treated items. Uncued, unreinforced, unpractised. |
| **Maintenance** | 1 week, 1 month, 3 months after a target is retired | **Retention, not acquisition, is the index of learning** (Maas et al. 2008). |
| **Intelligibility in Context Scale (ICS)** | Every 8–12 weeks | Free, validated, parent-reported, 7 items × 5-point. |

**No existing app runs maintenance probes.** It is a genuine differentiator and it is cheap to implement.

### 4.3 What must never be reported as progress

Minutes in app, streaks, stars earned, games completed, or **within-session accuracy on the currently-cued target.** These are engagement metrics masquerading as clinical outcomes, and the entire consumer app category is built on exactly that conflation.

### 4.4 The stuck-target pathway (gap G-4)

When a target shows no movement for **3+ weeks**, the app says so plainly and converts the signal into an action:

> "This target hasn't moved in 3 weeks. That's common, and it usually means the target needs changing — not more practice. Here's a message to send Karen."

Turning a bad signal into a concrete next action is the difference between honesty and despair. Escalation path: stuck target → clinician review → if multiple targets stuck across 8+ weeks, prompt full SLP re-evaluation.

---

## 5. Red-flag screening — hard interrupts

Screened at onboarding and re-screened every 3 months. A positive screen **blocks further onboarding** and routes to explicit referral guidance. These interrupt; they do not merely inform.

1. **Dysphagia / feeding difficulty** — coughing or choking on food or liquid, wet/gurgly voice after drinking, recurrent chest infections, prolonged mealtimes. *Aspiration risk. Immediate referral. **The app never engages with feeding.***
2. **Regression** — loss of previously acquired words, gestures, or social engagement. *Urgent medical referral* (Landau-Kleffner, epileptic encephalopathy, metabolic/neurodegenerative differentials).
3. **Unconfirmed or suspected hearing loss.** **Audiological assessment is a prerequisite to any speech diagnosis, full stop.** Hearing screening status is a mandatory gate before any speech pathway starts.
4. **Seizures or suspected seizure activity.**
5. **Other neurological signs** — tremor, ataxia, asymmetry, abnormal tone, drooling beyond developmental expectation.
6. **Dysmorphology, structural anomaly** (submucous cleft, bifid uvula), or family genetic history.
7. **Stridor, voice change, or breathing difficulty during speech attempts.**
8. **Safeguarding signals** — sustained aversion, self-injury during practice, caregiver distress.

---

## 6. AAC integration

- Every speech practice target is **also an AAC button** — same word, same picture, same voice model.
- Selecting the button **models the spoken word** (aided language stimulation) — auditory input, not a substitute for the child's attempt.
- The child's vocal approximation is **accepted and reinforced alongside** the button press, never instead of it. *"Buh" + button press = success.*
- **Button positions are invariant.** Icon position must never move, so motor automaticity can develop. (This is LAMP's one defensible principle regardless of the thinness of its evidence base; dynamic reorganising grids destroy it.)
- **AAC access is never gated, delayed, earned, or removed.** No "say it to unlock" mechanic, ever. That is communicative coercion.
- **Mirror mode:** where a family already uses Proloquo2Go / LAMP / TouchChat, we mirror the target symbols and defer. We are not entering the AAC market.

---

## 7. Who judges an attempt

**v1: the parent, with three taps — *got it / close / not yet*.** Optional; silence means *unscored*, never *zero*. Under 1 second per trial, one-thumb, positioned for the non-dominant hand.

**The app contributes only what it can compute reliably:** attempt detected, response latency, phonation duration, syllable-count estimate, pitch contour. No accuracy judgment.

**SLP async review** samples ~10 clips/week (first trial of each new target, highest-uncertainty clips, one random) and applies gold-standard labels.

**Never ASR as arbiter.** Whisper on children with speech sound disorders runs WER ~0.84, degrades *further* with severity — least accurate for the children who need it most — and hallucinates plausible words from weak acoustics. A confident wrong verdict in a motor-learning paradigm does not merely fail to help: **it trains the wrong motor plan.**

See [speech signal specification](../04-engineering/speech-signal-spec.md) for the tiered confidence stack and the v1.5 DTW path.
