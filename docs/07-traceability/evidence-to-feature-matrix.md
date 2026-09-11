# Evidence → Feature Traceability Matrix

**Meta-requirement:** every clinical claim in the product, marketing and onboarding must be traceable to a citation here or a better one. Where evidence is thin, **the product says so.**

Legend — **Evidence strength:** 🟢 Strong (RCT / systematic review) · 🟡 Moderate (SCED, small-n, consensus) · 🔴 Thin (expert opinion, no controlled trial) · ⚫ Counter-evidence

---

## Clinical design decisions

| Feature | Source | Str | Requirement |
|---|---|---|---|
| **Cue hierarchy L0–L5 as a state machine** | Strand 2020, DTTC (*AJSLP*) | 🟡 | [Clinical spec §1](../02-product/clinical-program-spec.md) |
| **3-up / 2-down dynamic fading, trial-by-trial** | Strand 2020 — the "dynamic" in DTTC | 🟡 | Clinical spec §1.3 |
| **Rate normalisation before full cue fading** | Strand 2020 | 🟡 | Clinical spec §1.1 |
| **~100 trials/session heuristic → our 60–80/10min** | Edeal & Gildersleeve-Neumann 2011 (*AJSLP* 20(2)) | 🟡 **n=2** | Clinical spec §3 — caveat stated in-doc |
| **≥2 sessions/week floor** | Namasivayam et al. 2015 (*IJLCD*), n=37 | 🟢 | Clinical spec §3 |
| **Intensive block model (4–5×/wk × 3–6wk)** | Published protocol convention; DTTC dose RCT NCT05675306 in progress | 🟡 | Clinical spec §3 |
| **Blocked→random practice, clinician-overridable** | Maas & Farinella 2012 — **found individual variability, not clean superiority in children** | 🟡 ambiguous | Clinical spec §1.5 — **deliberately not hard-coded** |
| **KP early → KR late; reduce feedback frequency** | Maas et al. 2008 tutorial; Maas, Butalla & Farinella 2012 — **mixed results in children** | 🟡 ambiguous | Clinical spec §1.5 — configurable |
| **Error-reduced learning as a safety rule** | DTTC design philosophy; aversion clinical consensus | 🔴 for the specific 40%/10 threshold | Clinical spec §1.4 — threshold is a judgment call, flagged |
| **Inventory-driven target selection** | Motor-learning target-selection principles; DEMSS logic | 🟡 | Clinical spec §2 |
| **Whole words over isolated phonemes** | Motor-learning view of the syllable-gesture as planning unit; NDP3 retention findings (Murray 2015) | 🟡 | Clinical spec §2 |
| **Approximations accepted as words** | K-SLP (Kaufman) philosophy | 🟡 Phase I only | Clinical spec §2 |
| **Phase 0 non-verbal pathway** | Clinical/tutorial literature; expert consensus | 🔴 **No RCT exists** | Clinical spec §2.1 — **evidence level stated in-app (gap G-2)** |
| **Automatic-to-volitional transfer via frame/cloze cueing** | Classic CAS clinical observation | 🔴 | Clinical spec §1.2 |
| **Rhythmic/prosodic cueing for elicitation** | Chenausky et al. 2016/2022 — AMMT, n=23 minimally verbal ASD | 🟡 emerging | Clinical spec, cue dimensions |
| **Zero non-speech oral motor exercises** | **McCauley, Strand, Lof, Schooling & Frymark 2009 — insufficient evidence** | ⚫ | Clinical spec §2.2 — a public marketing position |
| **No PROMPT delivery** | PROMPT is inherently hands-on (Namasivayam et al. 2020 RCT) | 🟢 for PROMPT itself; app cannot deliver it | Clinical spec, scope note |
| **No ReST** | Murray, McCabe & Ballard 2015 — **strongest RCT evidence, wrong population** (needs 3-syllable production) | 🟢 but N/A | Clinical spec, scope note |

## Measurement

| Feature | Source | Str | Requirement |
|---|---|---|---|
| **PSA over PCC as headline metric** | Chenausky et al. 2016/2022 used PSA; PCC floors at zero in this population | 🟡 | Clinical spec §4.1 |
| **Cue-level distribution as primary progress signal** | DEMSS dynamic-assessment logic (Strand & McCauley) | 🟡 | Clinical spec §4.1 |
| **Syllable-shape inventory** | Standard phonological analysis; most sensitive at bottom of range | 🟡 | Clinical spec §4.1 |
| **Generalisation probes on untreated items** | Maas et al. 2008 — transfer is the index of learning | 🟢 principle | Clinical spec §4.2 |
| **Maintenance probes at 1wk/1mo/3mo** | Maas et al. 2008 — **retention, not acquisition, is learning** | 🟢 principle | Clinical spec §4.2 — **no existing app does this** |
| **ICS every 8–12 weeks** | McLeod, Harrison & McCormack 2012 — validated, free, parent-report | 🟢 | Clinical spec §4.2 |
| **Modality ratio (AAC-only → AAC+vocal → vocal-only)** | Operationalises Millar, Light & Schlosser 2006 | 🟢 basis | Clinical spec §4.1 |

## AAC

| Feature | Source | Str | Requirement |
|---|---|---|---|
| **AAC free, ungated, never earned** | Millar, Light & Schlosser 2006: speech ↑ in ~89%, **decreased in none** | 🟢 | Clinical spec §6 |
| **"AAC does not delay speech" micro-lesson** | Same — **must carry the authors' own caution that gains were modest** | 🟢 | [PRD](../02-product/prd.md) E6.2 |
| **Positionally invariant buttons** | LAMP motor-planning principle | 🟡 thin, vendor-adjacent — **but the principle is sound independent of LAMP's evidence** | Clinical spec §6 |
| **Shared targets between AAC and speech practice** | Core-vocabulary overlap with high-frequency speech targets | 🟡 | Clinical spec §6 |

## Safety

| Feature | Source | Str | Requirement |
|---|---|---|---|
| **Red-flag hard interrupts (8 items)** | Standard paediatric SLP referral criteria | 🟢 | Clinical spec §5 |
| **Hearing status gates the speech pathway** | Audiological assessment is a prerequisite to any speech diagnosis | 🟢 | PRD E1.2 |
| **Aversion detection + proactive session end** | Clinical consensus on speech aversion | 🔴 for the specific detection thresholds | PRD E2.6 — thresholds tuned empirically |
| **Session self-terminates; resists "one more"** | Over-drilling → aversion | 🔴 | PRD E2.5 |

## Product / UX

| Feature | Source | Str | Requirement |
|---|---|---|---|
| **App as adjunct, clinician governs** | Thomas et al. 2016 (telehealth ReST ≈ in-person) **vs** Thomas et al. 2017 (clinician-parent split **worse**) | 🟢 | [Vision](../02-product/vision-and-positioning.md) |
| **Parent coaching to close the fidelity gap** | Thomas et al. 2017 failure modes: accuracy judgment, feedback timing, motivation | 🟢 for the problem · 🔴 for our solution | **Gap G-1 / RR-22 — the unproven premise** |
| **80–90% success band as engine objective** | Errorless learning + engagement reasoning | 🔴 | [UX principles §2](../03-design/ux-principles.md) |
| **Parent-facing loss-free rhythm, no child streaks** | Dark-pattern ethics; guilt in this population | 🔴 reasoned | UX principles §2 |
| **WCAG 2.2 AA + ≥64pt targets, no timing** | WCAG 2.2 (2023); W3C COGA; Apple HIG | 🟢 standard | UX principles §4 |

## Technical

| Feature | Source | Str | Requirement |
|---|---|---|---|
| **No ASR as accuracy arbiter** | Hair et al. 2019; Shriberg et al.; WER ~0.84 on children with SSD; severity confound | 🟢 | [Speech spec §1](../04-engineering/speech-signal-spec.md) |
| **Tier-1 deterministic signals only in v1** | Signal validity analysis | 🟢 | Speech spec §2 |
| **Per-child DTW over own labelled exemplars** | Avoids the speaker-independent problem; works at n≈10 | 🟡 technique is standard; application here is ours | Speech spec §2 |
| **16kHz, measurement mode, AEC/AGC off** | Voice-processing I/O destroys amplitude/formant validity | 🟢 | Speech spec §3 |
| **Native iOS** | Audio-stack control, Core ML/ANE, accessibility APIs, iPad-dominant population | 🟢 reasoned | [Architecture §2](../04-engineering/technical-architecture.md) |
| **Event-sourced immutable trial log** | Research reproducibility; retrospective re-scoring; audit | 🟢 practice | [Data model](../04-engineering/data-model-and-events.md) |

## Regulatory

| Feature | Source | Requirement |
|---|---|---|
| Layered consent; separate training opt-in | **Amended COPPA Rule, full compliance since 22 Apr 2026** | [Privacy plan §1](../05-compliance/privacy-security-regulatory-plan.md) |
| Strong VPC (not email-plus) | COPPA — email-plus is internal-use-only | Privacy plan §1 |
| Per-child embeddings treated as biometric | BIPA (private right of action), Texas CUBI | Privacy plan §2 |
| Two tenant modes enforced in code | FERPA school-official exception | Privacy plan §3 / RR-09 |
| General-wellness positioning; claims register | FDA CDS + General Wellness guidances (Jan 2026) | [Claims register](../05-compliance/claims-register.md) |
| No emotion-inference framing in education | **EU AI Act Art. 5 — prohibited** | Privacy plan §7 |
| No third-party analytics/ads SDKs in child client | Apple 1.3; Google Play Families 2026 (applies by actual audience) | Privacy plan §8 |
| VPAT before first district RFP | Section 508; ADA Title II final rule | Privacy plan §9 |

---

## Verification note

Research A was conducted with **egress blocking on asha.org, PubMed, PMC, Springer, RCSLT and apraxia-kids.org.** Findings were sourced from search summaries of primary literature plus domain knowledge, and items the researcher could not verify in-session are flagged `[UNVERIFIED IN THIS PASS]` in [that document](../01-research/A-clinical-and-evidence.md).

> **Before any figure from this matrix enters clinical-facing or marketing copy, it must be re-verified against the primary source.** This is a gating step in the [claims register](../05-compliance/claims-register.md) review process, not a nice-to-have.
