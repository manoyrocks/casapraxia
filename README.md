# Praxia — a speech-practice app for non-verbal children with Childhood Apraxia of Speech

> **Planning repository. No application code has been written yet, deliberately.**
> This repository contains the research, strategy, product specification, architecture, compliance plan and the build prompt to be issued to the implementation team.

---

## The problem

Childhood Apraxia of Speech is a **dosage problem wearing the costume of a content problem.**

A child with severe CAS needs 60–100 speech-production trials per short session, most days of the week, for months to years. What they actually get is two 30-minute clinic sessions a week and **near-zero practice trials on every other day** — because the parent was handed a photocopied word list and no model of *how*.

That gap of ~700 missing trials per week is the entire opportunity. And it is not closed by giving parents more exercises: when researchers tested exactly that, splitting therapy delivery between clinician and parent made outcomes **worse**, and parents disengaged. The failure modes were mechanical — parents could not reliably judge accuracy, sustain feedback timing, or maintain motivation.

Those three failure modes are software-shaped.

## The product

**Praxia is not a speech teacher. It is a practice-delivery and coaching system** that turns a parent into a competent, consistent, non-anxious practice partner, and makes the SLP's target hierarchy executable six days a week instead of one.

Two commitments are non-negotiable:

1. **The clinician governs; the app delivers volume; the clinician reviews.**
2. **For a non-verbal child, the app is never the only voice.** AAC ships free, ungated, one tap from anywhere.

## How this was researched

Three agents researched independently on deliberately different axes, then their findings were reconciled:

| | Stream | Focus |
|---|---|---|
| **A** | [Clinical & Evidence](docs/01-research/A-clinical-and-evidence.md) | Diagnosis, DTTC/ReST/NDP3/PROMPT/K-SLP, the zero-speech starting point, AAC evidence, dose, outcome measures, clinical risk |
| **B** | [Product, UX & Market](docs/01-research/B-product-ux-and-market.md) | Four users, personas, neurodivergent-safe UX, engagement ethics, interaction model, clinician portal, competitors, business model |
| **C** | [Technology & Regulatory](docs/01-research/C-technology-data-and-regulatory.md) | Why ASR fails here and what to build instead, mobile architecture, data model, COPPA/BIPA/FERPA/HIPAA/FDA/EU AI Act |
| **D** | [**Synthesis & Conflict Resolution**](docs/01-research/D-synthesis-and-conflict-resolution.md) | **Authoritative.** Convergences, the eight real conflicts and their resolutions, and the gaps nobody owned |

**Seven conclusions were reached independently by all three** — including that no machine verdict may ever reach the child, and that ASR cannot arbitrate accuracy for this population. Independent convergence from clinical, product and engineering directions is why those are treated as inviolable.

## Documentation map

```
docs/
├── 01-research/     Three independent research streams + the authoritative synthesis
├── 02-product/      Vision & positioning · Clinical program spec · PRD · Personas & flows
├── 03-design/       UX principles, engagement ethics, banned dark patterns, accessibility
├── 04-engineering/  Technical architecture · Data model & events · Speech signal spec
├── 05-compliance/   Privacy/security/regulatory plan · Claims register · Risk register
├── 06-delivery/     Roadmap, team, budget shape, validation & testing strategy
├── 07-traceability/ Evidence → feature matrix, with evidence-strength grading
└── 08-prompts/      ► UNIFIED BUILD PROMPT ◄  to issue to the implementation team
```

**Start here:** [Executive summary](docs/00-executive-summary.md) → [Synthesis](docs/01-research/D-synthesis-and-conflict-resolution.md) → [Clinical program spec](docs/02-product/clinical-program-spec.md) → [Unified build prompt](docs/08-prompts/UNIFIED-BUILD-PROMPT.md)

## The central technical finding

**Do not architect this app around speech recognition.**

Whisper on children with speech sound disorders runs **WER ~0.84**, degrades *further* with severity — least accurate for the children who need it most — and hallucinates plausible words from weak acoustics. A confident wrong verdict in a motor-learning paradigm does not merely fail to help: **it trains the wrong motor plan.**

What is buildable is a tiered stack where Tier 1 (vocalization, latency, syllable count, pitch contour — deterministic, on-device, <50 ms) is genuinely reliable, and **for a non-verbal child, attempt count alone justifies the product.** Accuracy judgment stays with a human, in every version.

## The honest risk

The central premise — that an app can close the fidelity and adherence gap that defeated parent-delivered therapy in the literature — **is unproven.** No app has demonstrated it. We say so in the product, and the [validation strategy](docs/06-delivery/roadmap-and-validation.md) is designed to answer it rather than assume it.

A CAS parent has usually been sold false hope several times already. Being the product that is honest about uncertainty is both the ethical position and the differentiated one.

## Status

| | |
|---|---|
| Research | ✅ Complete — three streams, synthesised |
| Product specification | ✅ Complete — vision, clinical spec, PRD, IA |
| Design specification | ✅ Complete — principles, ethics, accessibility |
| Architecture & data model | ✅ Complete at planning fidelity |
| Compliance plan | ✅ Complete — privacy, claims, risk |
| Delivery plan | ✅ Complete — roadmap, validation, testing |
| **Build prompt** | ✅ **Ready to issue** |
| Implementation | ⬜ Not started — by design |

---

*"Praxia" is a provisional product name pending trademark clearance.*
