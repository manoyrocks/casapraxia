# Roadmap, Team & Validation Strategy

---

## 1. Phasing

### Phase 0 — Foundations (weeks 1–6, pre-build)

**No application code.** This phase exists because the decisions made here are expensive to reverse.

- Recruit **SLP advisory board** (3–5 practising CAS clinicians) and ratify the L0–L5 hierarchy and the 3-up/2-down fading rule *(PRD Q2)*
- Trademark clearance on the product name *(Q1)*
- Engage **privacy counsel**; select Safe Harbor (kidSAFE vs PRIVO) *(Q4)*
- Author the v1 target library and Phase 0 content spec with the advisory board
- **Content production plan** — ~150 mouth-model videos; in-house vs contracted decision *(Q3)*
- Design system + accessibility spec
- App Review pre-submission conversation confirming Education category *(Q6)*
- Recruit 8–12 **design-partner families** and 3–5 design-partner SLPs

**Exit criteria:** hierarchy ratified, content plan costed and owned, consent architecture reviewed by counsel, design partners signed.

### Phase 1 — MVP (months 2–6)

Build the [PRD](../02-product/prd.md) scope: E1–E9. Ship to TestFlight with design partners.

Sequenced so the riskiest thing is proven first:

| Sprint block | Focus |
|---|---|
| **1–2** | Audio capture done *correctly* (measurement mode, calibration, SNR gate) + Tier-1 signals + the fixture regression suite. **This is the technical crux — prove it before building around it** |
| **3–4** | Trial engine + cue hierarchy state machine + fading + safety stop + event log |
| **5–6** | Child experience: three surfaces, low-stimulation design system, companion, collection |
| **7–8** | AAC core board + modality tracking |
| **9–10** | Parent coaching layer + before/after clip generation + practice rhythm |
| **11–12** | Clinician portal v1 + keyboard clip review + IEP export |
| **13** | Consent/VPC flows, retention jobs, deletion, audit log, DPIA |
| **14** | Accessibility pass, VPAT draft, claims-register sweep, App Review submission |

**Exit criteria:** 10 families practising ≥2×/week for 4 consecutive weeks; SLP portal used weekly by ≥3 clinicians; zero child-visible failure states in audit; VPAT drafted.

### Phase 2 — Evidence & intelligence (months 7–12)

- **DTW per-child exemplar scoring** ships (Tier 2), adult-surface only
- SLP labelling operation at volume; inter-rater κ tracked
- **First bias audit** published
- Generalisation and maintenance probe reporting matured
- **Design and launch the validation study** (see §4)
- Formant/vowel-space charts behind a research flag
- SOC 2 Type I

### Phase 3 — Channel expansion (months 13–24)

- **Android client** on the portable Rust scoring core
- **Institutional tenancy** — SSO, roster sync, DPA, district admin, web-accessible surface for Chromebook environments
- SOC 2 Type II, HECVAT, SDPC NDPA, Student Privacy Pledge
- Per-target cross-child classifiers, once the corpus supports them
- Adjacent-population expansion (severe SSD, late talkers, minimally verbal ASD) — **no rebuild required, by design**

---

## 2. Team

| Role | Phase 1 | Notes |
|---|---|---|
| Senior iOS engineer | 1.0 | Audio/DSP depth is the scarce skill. Hire for this, not for SwiftUI |
| Backend engineer | 1.0 | Postgres, event sourcing, HIPAA-eligible infra |
| Product designer | 1.0 | Must have genuine accessibility and neurodivergent-user experience |
| Content producer | 0.5 | **Owns the video asset library.** Not an engineering cost |
| SLP clinical advisor | 0.3 (contract) | Authors targets and Phase 0; ratifies the hierarchy |
| PM | 1.0 | Also owns the claims register |
| Privacy counsel | Contract | Before launch, not after |

Phase 2 adds: ML engineer (0.5–1.0), SLP labellers (contract, recurring COGS), clinical research lead (contract).

---

## 3. Budget shape (Phase 1–2, 12 months)

| Line | Range |
|---|---|
| Engineering + design + PM | Team-dependent |
| **Content production (~150 videos + stimulus art)** | **Frequently the largest single line — size it explicitly** |
| SLP labelling ($60–120/hr; 200–400 clips/hr with good tooling) | Recurring COGS |
| Compliance (counsel, DPIA, Safe Harbor, SOC 2, pen test, VPAT) | **$150–350k over 18 months** |
| Infrastructure | Modest — on-device-first + 90-day retention keeps audio storage near-trivial |
| Validation study (Phase 2) | $100–500k if we want efficacy claims |

**Non-dilutive sources:** NIDCD SBIR/STTR, NIH R41/R43, IES SBIR, Apraxia Kids research grants (small money, disproportionate credibility and community access).

---

## 4. Validation strategy — addressing the premise risk

**The central premise is unproven.** Thomas, McCabe & Ballard (2017) found clinician-parent split delivery of ReST was *less* effective than clinician-delivered, and parents disengaged. We assert that software closes the fidelity and adherence gap that defeated those parents. **No app has demonstrated this.** (RR-22, gap G-1.)

We do not claim efficacy until evidence exists. We design to generate it.

### Tier 1 — Feasibility & adherence (Phase 1, design partners)
**Question:** can families actually deliver the dose?
**Measures:** trials/week, sessions/week, proportion reaching the ≥2×/week evidence floor, retention at 4/8/12 weeks, aversion-trigger rate, over-practice rate.
**This is a feasibility claim, and it is claimable.**

### Tier 2 — Measurement validity (Phase 2)
**Question:** are our metrics trustworthy?
**Measures:** parent-vs-SLP agreement (Cohen's κ); Tier-1 signal accuracy against human annotation; cue-level logging fidelity; DTW agreement with SLP labels, per child and pooled.
**Publishable, and it is what earns clinician trust.**

### Tier 3 — Efficacy (Phase 2–3, external)
**Design:** multiple-baseline single-case experimental design across participants — the standard and appropriate design for CAS, where RCTs are rare and populations are small. University partnership, IRB, pre-registered.
**Primary outcomes:** Percent Syllables Approximated on probe sets; cue-level distribution shift; **generalisation probes on untreated items** (the real index of learning); **maintenance at 1 week / 1 month / 3 months**.
**Secondary:** syllable-shape inventory growth, modality ratio, ICS.

> Only after Tier 3 reports may any efficacy language enter the [claims register](../05-compliance/claims-register.md).

---

## 5. Testing strategy

| Layer | Approach |
|---|---|
| **Audio/DSP** | **Recorded fixture corpus replayed through the pipeline on every build and every iOS beta.** The single most important regression suite in the product (RR-20) |
| **Cue hierarchy state machine** | Exhaustive property-based tests: no path may leave a child failing repeatedly; safety stop always fires; back-off never emits a child-visible event |
| **Offline** | Full practice loop exercised in airplane mode as a CI gate |
| **Accessibility** | Automated WCAG scanning + manual Switch Control, VoiceOver, Guided Access passes each release |
| **Dark patterns** | Banned-list checked in code review; a PR touching reward, notification, streak or paywall code requires a second reviewer |
| **Claims** | Every user-facing string diffed against the claims register at release |
| **Child-safety invariants** | Automated assertion that no failure state, timer, or machine verdict can render in the child zone |
| **Privacy** | Automated check that no third-party SDK is linked into the child target; audit-log completeness tests |

**Usability testing** runs with real families under NDA, in-home, observed rather than self-reported — a parent's account of a session is not the session.
