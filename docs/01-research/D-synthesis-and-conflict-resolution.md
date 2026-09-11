# Research Synthesis & Conflict Resolution

**Status:** Authoritative. Where this document disagrees with Research A, B or C, this document wins.
**Date:** 2026-09-11
**Inputs:** [A — Clinical & Evidence](A-clinical-and-evidence.md) · [B — Product, UX & Market](B-product-ux-and-market.md) · [C — Technology, Data & Regulatory](C-technology-data-and-regulatory.md)

Three researchers worked independently on deliberately different axes. This document does the unification: what they agreed on (strong signal — independent convergence), what they disagreed on (the real design decisions), and what none of them owned (the gaps).

---

## 1. Independent convergence — treat these as settled

When three researchers who never spoke reach the same conclusion from clinical, product and engineering directions, that conclusion is load-bearing. Seven did.

| # | Converged conclusion | A | B | C |
|---|---|---|---|---|
| **C1** | **No machine verdict ever reaches the child.** Accuracy information goes to the adult surface only. | A-11, A-ethics-5 | B-5, B-8 | C-23, C-3 |
| **C2** | **ASR cannot arbitrate accuracy for this population.** It is an assist with an off switch, never a gate. | A-11 | B-§5 | C-1, C-§1.1 |
| **C3** | **AAC ships alongside speech practice, free and never gated behind performance.** | A-16 | B-2 | — (implied) |
| **C4** | **The product is an adjunct to an SLP, not a replacement.** Clinician sets targets, app delivers volume, clinician reviews. | A-20, A-21 | B-22 | C-19, C-20 |
| **C5** | **The cue hierarchy — not the stimulus list — is the core IP,** and cue level must be recorded on every trial. | A-1, A-2 | B-§5 | C-10 |
| **C6** | **Error-reduced learning is a safety requirement, not a pedagogy preference.** Speech aversion is the worst reachable outcome. | A-3 | B-7 | C-23 |
| **C7** | **Child voice data demands above-baseline handling** — consent, minimisation, on-device-first. | A-22 | B-24 | C-13, C-14, C-15 |

**Design consequence:** C1–C7 are non-negotiable constraints, written into the architecture and enforced in code review. They are not subject to later trade-off against engagement or velocity.

---

## 2. Genuine conflicts and their resolutions

These are the decisions the research forced. Each resolution is a commitment, with the losing option recorded so we don't relitigate it.

### CR-1 — Who judges an attempt in v1?

- **B** proposed: on-device ASR pre-scores silently → parent confirms with one tap → SLP audits a sample.
- **C** countered: ship **Tier 1 deterministic signals only** in v1 (vocalization, latency, duration, syllable count, pitch contour). Machine *accuracy* scoring is v1.5 at the earliest, and only via per-child DTW against the child's own labelled exemplars.
- **A** constrained: ASR never arbitrates accuracy, in any version.

**Resolution — C's sequencing, inside A's rule, delivering B's UX.**
v1 ships **no machine accuracy score at all.** The parent's three-tap score (*got it / close / not yet*) is the sole accuracy signal, and Tier 1 signals handle everything that doesn't require judgment — crucially **attempt counting, which is the primary outcome measure for a non-verbal child and needs no ML whatsoever.** B's "ASR pre-scores" arrives in v1.5 as a **DTW suggestion visible only on the adult surface**, after the exemplar bank exists. The parent tap is truth in every version.

> **Rationale:** B's hybrid is the right end state but assumes a working scorer on day one. C demonstrated there is no public corpus of minimally-verbal children with CAS — the scorer cannot exist until we have built the labelled data, which requires shipping without it. Attempting B's model in v1 would mean shipping a scorer trained on the wrong population.

### CR-2 — Platform: native iOS vs. the school channel's Chromebook requirement

- **C** recommended native Swift/SwiftUI, decisively: `AVAudioSession .measurement` with AEC/AGC **off** is required to keep acoustic measures valid, and cross-platform audio plugins silently re-enable voice-processing I/O. Plus Core ML/ANE, and Switch Control / Guided Access.
- **B** recorded that a **Chromebook/web fallback is a school procurement requirement, not a nice-to-have.**

**Resolution — split by surface, and sequence the channel.**
- **Child practice client: native Swift/SwiftUI, iOS/iPadOS only, v1.** The audio-fidelity argument is dispositive and this population is overwhelmingly on iPad.
- **Clinician portal: web (Next.js), v1.** This satisfies Chromebook access for the clinician and the district administrator.
- **The school channel is deliberately a Phase 3 motion.** We do not enter district procurement until the portable Rust/C++ scoring core exists, at which point an Android client (and, if procurement genuinely demands it, a reduced-capability web child client that does *not* claim acoustic validity) becomes economic.

> This converts an architecture conflict into a **roadmap decision**. We are not shipping a compromised audio stack to win a deal we are not yet ready to service.

### CR-3 — The data flywheel vs. the school channel (structural, not schedulable)

**C** identified a genuine commercial contradiction: under FERPA's **school-official exception**, district-sourced data generally **may not train our models** without separate district and parent consent. B's growth plan routes through schools; C's moat requires training data.

**Resolution — two tenant modes, enforced in the tenant model in code, and consumer-first sequencing.**
- **Consumer tenant:** COPPA, parent-consented, model training permitted under a separate opt-in toggle.
- **Institutional tenant:** FERPA/IDEA, district DPA, **training disabled by default and not toggleable by the district user.**
- Build the corpus in the consumer channel first. Enter schools once the models are already trained.

This is a permanent structural feature of the business, not a phase. It is recorded in [the risk register](../05-compliance/risk-register.md) as RR-09.

### CR-4 — Audio retention: discard vs. keep

Three different defaults were proposed:

| Researcher | Default | Reason |
|---|---|---|
| A | **Discard after scoring**; opt-in retention ≤30 days | Minimises COPPA/GDPR Art. 9 exposure |
| B | **Record every attempt**; the 2-week before/after clip is *the* retention engine | Emotional artifact is the strongest retention mechanism in the product |
| C | **90 days**, encrypted on-device | Practical middle; supports SLP review and the exemplar bank |

**Resolution — separate *location* from *duration*, which is what dissolves the conflict.**
- **Default: retained 90 days, encrypted on-device (`NSFileProtectionComplete`), never uploaded.** A's actual concern is cloud exposure and third-party training, not local existence — on-device retention gives B the before/after artifact at close to A's risk profile.
- **Cloud upload** requires a separate consent toggle, and exists only to serve SLP async review.
- **Keepsake clips** (the child's best production of a target, auto-curated for the before/after reel) are retained beyond 90 days under an explicit, separately-revocable parental opt-in, because their purpose is durable by nature.
- **Model training** is a fourth, independent toggle (COPPA-mandated as separate — C-14).

### CR-5 — Practice dose: reconciling the numbers

- **A:** ~100 trials per 15-minute block; ≥2 sessions/week floor; 4–5×/week for intensive blocks. (Edeal & Gildersleeve-Neumann 2011; Namasivayam et al. 2015)
- **B:** 60–100 attempts in 5–10 minutes; 5+ days/week; **hard cap the session at ~8–10 minutes** to prevent aversion.

A's rate is ~6.7 trials/min. B's upper bound implies up to 12/min, which is not achievable with a real model-cue-attempt-capture loop and a non-verbal child.

**Resolution — design rate of ~7 trials/minute.**
- **Default practice block: 10 minutes, target 60–80 trials.** Meets A's evidence-referenced rate, inside B's aversion cap.
- **Default schedule: 5 days/week, expressed to the parent as a "4 days this week" bucket goal** (B's loss-free framing), with A's ≥2×/week as the floor below which the app tells the clinician the dose is inadequate.
- **Intensive block** (4–5×/week for 3–6 weeks) is a clinician-set mode, mirroring published protocols.
- The session **ends itself** at the trial target or 10 minutes, whichever comes first, and resists "one more."

### CR-6 — AAC: build it, or defer to the incumbent?

- **A** required AAC integrated on equal footing, sharing the target list, positionally invariant.
- **B** warned: if the family already uses Proloquo2Go / LAMP / TouchChat, **do not compete** — mirror and defer.

**Resolution — ship both paths.**
- **Native core board** (~40 cells, fixed positions, core-vocabulary spine, auto-populated with current speech targets) — free, ungated, one tap from anywhere. This serves the family with no AAC system, which is most of our early-verbal population.
- **Mirror mode** — where a family has an existing AAC system, we mirror the target symbols and *defer*, making no attempt to replace it. We are not entering the AAC market; we are ensuring no child in our app is without a voice.

### CR-7 — App Store category

**C** surfaced a strategic choice B had treated as settled: B assumed Kids Category and designed to its constraints; C noted that a **Medical or Education** category app whose *account holder is an adult* avoids the Kids Category SDK ruleset entirely while still owing full COPPA compliance.

**Resolution — Education category, adult account holder. Not Kids Category.**
We retain the *substance* of B's restrictions voluntarily (zero third-party analytics/ads/attribution SDKs in the child client — C-18) because Google Play Families applies by **actual audience regardless of declared category**, so category-shopping buys nothing on Android. What the Education category buys us is freedom to operate a normal adult-facing parent/clinician surface without the parental-gate ruleset distorting it.

### CR-8 — Screen time for an 18-month-old

**B** flagged that AAP/WHO under-2 screen guidance directly contradicts the lower bound of our age range, and that SLPs and paediatricians *will* raise it. A and C did not address it.

**Resolution — position as joint media engagement and hold the line publicly.**
Parent-and-child together, adult-mediated, short, interactive, explicitly pushing off-screen generalisation ("do this at snack time"). We ship off-screen activity cards, cap and **honestly report** daily screen minutes, and never autoplay. We publish our stance rather than avoiding the question. A documented position is a clinician-trust asset; silence reads as evasion.

---

## 3. Where the researchers were silent — gaps we own

None of the three fully covered these. They are logged as open questions, not quietly assumed away.

| Gap | Why it matters | Owner / next step |
|---|---|---|
| **G-1. Efficacy evidence for app-delivered practice does not exist.** A was explicit: we are compensating for a *known* failure mode (Thomas et al. 2017 — parent-delivered ReST was **less** effective and parents disengaged) and the evidence that this compensation works has not been generated. | This is the central unproven premise of the entire product. | Design the validation study in Phase 2 ([testing strategy](../06-delivery/testing-and-validation-strategy.md)); never claim efficacy before it reports. |
| **G-2. The non-verbal starting point has no RCT.** A flagged that moving a child from zero volitional speech to first approximation is described in tutorial literature and expert consensus only. | Our Phase 0 content is the least evidence-backed part of the product and it is the part the marketing most wants to lead with. | SLP advisory board authors Phase 0; product copy states the evidence level in-app. |
| **G-3. Bilingual and dialectal children.** C flagged bias exposure; neither A nor B designed for it. Bilingual children are systematically misidentified by speech tools. | An equity failure and a live regulatory exposure. | Bias-audit slices from v1 (C-24); bilingual target-selection guidance from the advisory board. |
| **G-4. What happens when a child genuinely does not progress.** B specified honest reporting mechanics; nobody specified the clinical off-ramp. | The highest-risk user journey in the product — a family whose child is not responding. | Define an explicit "this is not working" pathway routing to SLP re-evaluation; see [PRD](../02-product/prd.md) §Stuck-target pathway. |
| **G-5. Cost of content production.** C named it as frequently the largest line item and *not* an engineering cost; no one sized it. | Video modelling assets are the real moat (B) and the real budget risk (C). | Sized in [roadmap](../06-delivery/roadmap-and-milestones.md); treated as a distinct workstream with its own owner. |

---

## 4. The unified thesis

Combining all three:

> **Praxia is a clinician-governed, parent-coached practice-delivery system that closes the dosage gap in Childhood Apraxia of Speech — delivering evidence-referenced trial volume between therapy sessions, with AAC alongside rather than instead of speech, and with every accuracy judgment made by a human.**

The three researchers each independently identified the same unoccupied market position from their own direction:

- **A (clinical):** nothing on the market combines a dynamic cue hierarchy, inventory-driven targeting, reliable trial counting, integrated AAC and maintenance probes.
- **B (product):** every product sits in exactly one of three boxes — AAC, clinician drill content, or consumer engagement — and nothing occupies the intersection; almost nothing serves the *pre-verbal* child at all.
- **C (technical):** the proprietary human-labelled corpus of minimally-verbal child CAS speech is the moat, because that corpus does not exist anywhere.

These are the same gap described three ways. That is the product.

---

## 5. What this synthesis rejects

Stated explicitly so it does not creep back in:

1. **Any "teach your non-verbal child to talk" claim.** (A-20, C-19)
2. **Non-speech oral motor exercises** — blowing, whistles, straws, tongue push-ups. Contradicted by McCauley et al. 2009, and the category's original sin. (A-18)
3. **ASR as a child-facing verdict**, in any version. (C1, C2)
4. **Gating communication** behind speech performance, payment, or progress. (C3)
5. **Child-visible streaks, loss framing, or any of the 16 banned dark patterns.** (B-§4)
6. **Shipping PROMPT.** It is inherently a hands-on physical technique; an app claiming to deliver it is misrepresenting. (A)
7. **Emotion recognition in an educational context** — prohibited outright under EU AI Act Art. 5. (C-25)
8. **Bundling model-training consent into the ToS** — a COPPA violation since 22 April 2026. (C-14)
