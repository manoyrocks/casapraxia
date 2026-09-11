# Executive Summary

**Praxia — a speech-practice and communication app for non-verbal children with Childhood Apraxia of Speech.**
Planning complete. No code written. Build prompt ready to issue.

---

## 1. The opportunity in one paragraph

CAS requires 60–100 speech-production trials per short session, most days, for months to years. Clinic caseloads deliver two 30-minute sessions a week; the other six days produce **near-zero trials**. Handing parents more exercises does not fix it — when tested, splitting therapy delivery between clinician and parent made outcomes *worse* and parents disengaged, failing on three specific mechanics: **judging accuracy, sustaining feedback timing, and maintaining motivation.** Those are software-shaped problems. **Praxia closes the dosage gap by making the SLP's hierarchy executable at home, with AAC alongside rather than instead of speech.**

## 2. The unoccupied position

Three researchers, working independently, identified the same gap from three directions:

- **Clinically:** nothing combines a dynamic cue hierarchy, inventory-driven targeting, reliable trial counting, integrated AAC, and maintenance probes.
- **Commercially:** every product sits in exactly one of three boxes — AAC, clinician drill content, or consumer engagement. **Nothing occupies the intersection, and almost nothing serves the pre-verbal child at all.**
- **Technically:** there is **no public corpus of minimally-verbal children with CAS anywhere.** The consented, human-labelled corpus is the moat.

The closest structural precedent is Constant Therapy — adaptive practice + clinician dashboard + published evidence. It proves the model. It is adult-only.

## 3. Seven conclusions all three researchers reached independently

These are treated as inviolable precisely because they converged from clinical, product and engineering directions without contact:

1. **No machine verdict ever reaches the child.**
2. **ASR cannot arbitrate accuracy for this population.**
3. **AAC ships free and ungated, never behind speech performance.**
4. **The product is an adjunct to an SLP** — clinician sets, app delivers, clinician reviews.
5. **The cue hierarchy, not the stimulus list, is the core IP** — and cue level is recorded on every trial.
6. **Error-reduced learning is a safety requirement**, not a pedagogy preference. Speech aversion is effectively irreversible.
7. **Child voice data demands above-baseline handling** — layered consent, on-device-first.

## 4. The eight conflicts that were resolved

| # | Conflict | Resolution |
|---|---|---|
| CR-1 | Who judges an attempt in v1? | **No machine accuracy score in v1.** Parent's three-tap is truth. DTW suggestion at v1.5, adult-surface only |
| CR-2 | Native iOS vs schools' Chromebook requirement | Native iOS child client + web clinician portal. **School channel deliberately deferred to Phase 3** |
| CR-3 | Data flywheel vs school channel (FERPA blocks training on district data) | **Two tenant modes enforced in code**; consumer-first sequencing. A permanent structural feature, not a phase |
| CR-4 | Discard audio vs keep it | Separate *location* from *duration*: **90 days, on-device, encrypted, never uploaded by default** |
| CR-5 | Dose: ~100/15min vs 60–100/5–10min | **~7 trials/min → 10-minute block, 60–80 trials, 5 days/week** |
| CR-6 | Build AAC vs defer to incumbents | **Both** — native core board, plus mirror mode deferring to Proloquo2Go/LAMP/TouchChat |
| CR-7 | App Store category | **Education category, adult account holder** — not Kids Category; retain the SDK restrictions voluntarily |
| CR-8 | Screen time for an 18-month-old | **Joint media engagement**, published stance, off-screen generalisation cards, honest reporting |

## 5. The central technical finding

**Do not architect this app around speech recognition.** Whisper on children with speech sound disorders runs WER ~0.84, **degrades further with severity** (least accurate for the children who need it most), and hallucinates plausible words from weak acoustics. A confident wrong verdict in a motor-learning paradigm **trains the wrong motor plan** — that is clinical harm, not bad UX.

What *is* buildable:

| Tier | Content | Ship |
|---|---|---|
| **1** | Vocalization, latency, duration, syllable count, pitch contour — deterministic, on-device, <50 ms | **v1** |
| **2** | **Per-child DTW k-NN against the child's own SLP-labelled exemplars.** Works at n≈10. Sidesteps the speaker-independent problem entirely | v1.5 |
| **3** | Forced alignment + GOP — must **abstain** rather than guess | Research flag |

> **For a non-verbal child, attempt count is the primary outcome measure — and Tier 1 alone justifies the product.** No ML required to ship something genuinely valuable.

## 6. Regulatory posture

- **Amended COPPA has been binding since 22 April 2026** — voiceprints and audio are personal information, and **training AI on children's data requires separate opt-in consent** that cannot be bundled.
- **FDA:** ship as general wellness / practice support. The line is drawn by **claims, not technology** — "detects," "screens for," "treats," or automated severity scoring crosses into device territory. A [claims register](05-compliance/claims-register.md) gates every user-facing string.
- **BIPA/CUBI:** assume per-child voice embeddings are biometric templates. Written consent, published destruction schedule, keep on-device.
- **EU:** MDR is far less forgiving than FDA (Rule 11 → Class IIa minimum; "general wellness" is not an EU concept) — argues for EU-later.

## 7. Plan

| Phase | Duration | Outcome |
|---|---|---|
| **0 — Foundations** | 6 weeks | Advisory board ratifies the hierarchy; content plan costed; counsel engaged; design partners signed. **No code** |
| **1 — MVP** | 4–6 months | Audio proven first, then trial engine, child experience, AAC, coaching, clinician portal, compliance. TestFlight |
| **2 — Evidence** | months 7–12 | DTW scoring, labelling at volume, first bias audit, **validation study launched**, SOC 2 Type I |
| **3 — Channels** | months 13–24 | Android, institutional tenancy, adjacent populations — **no rebuild required, by design** |

**Success for v1:** 10 families practising ≥2×/week for 4 straight weeks · 3 clinicians using the portal weekly · median 60+ trials/session · **zero child-visible failure states** · **zero machine accuracy scores.**

## 8. The risk we cannot engineer away

**The central premise is unproven.** We assert that software closes the fidelity and adherence gap that defeated parent-delivered therapy in the published literature. **No app has demonstrated this.**

This is not mitigable by engineering — only by evidence. So we say so inside the product, we refuse efficacy language until a study reports, and we design the multiple-baseline single-case study that would answer it.

A CAS parent has usually been sold false hope several times already. **Being honest about uncertainty is both the ethical position and the differentiated one.**

---

**Next action:** issue [`docs/08-prompts/UNIFIED-BUILD-PROMPT.md`](08-prompts/UNIFIED-BUILD-PROMPT.md) — §1–§5 to every agent, plus the matching role brief from §6.
