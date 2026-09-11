# Praxia — Product Vision & Positioning

> *Working product name. "Praxia" is provisional pending trademark search; the repository name `casapraxia` is the working codename.*

---

## The problem, stated precisely

Childhood Apraxia of Speech is a **dosage problem wearing the costume of a content problem.**

A child with severe CAS needs very high-frequency, distributed, motor-based practice — on the order of 60–100 production trials per short session, most days of the week, sustained for months to years. The published evidence supports two things strongly: **more trials** and **at least twice-weekly frequency** (Edeal & Gildersleeve-Neumann 2011; Namasivayam et al. 2015).

What a child actually receives:

- **Two 30-minute SLP sessions per week**, in which a stranger asks for sounds ~80 times.
- **Near-zero practice trials on every other day**, because the parent was handed a photocopied word list and no model of *how*.

That gap — call it ~700 missing trials per week — is the entire product opportunity. And it is not closed by giving parents more exercises. Thomas, McCabe & Ballard (2017) tested exactly that: splitting ReST delivery between clinician and parent made outcomes **worse**, and parents disengaged. The failure modes were specific and mechanical — parents could not reliably **judge accuracy**, could not sustain **feedback timing and frequency**, and could not maintain **motivation**.

Those three failure modes are software-shaped.

## The thesis

**Praxia is not a speech teacher. It is a practice-delivery and coaching system that turns a parent into a competent, consistent, non-anxious practice partner — and makes the SLP's target hierarchy executable six days a week instead of one.**

Two commitments follow immediately and are not negotiable:

1. **The clinician governs; the app delivers volume; the clinician reviews.** This is the shape the evidence actually supports — telepractice-delivered ReST matched in-person delivery, while clinician-*replaced*-by-parent did not (Thomas et al. 2016 vs 2017).
2. **For a non-verbal child, the app is never the only voice.** AAC ships free, ungated, one tap from anywhere. Withholding communication pending speech is both unethical and clinically wrong — and the fear that AAC suppresses speech is empirically unfounded (Millar, Light & Schlosser 2006: speech production increased in ~89% of participants; **no participant showed a decrease**).

## Who it is for

| User | What they get | Why they matter |
|---|---|---|
| **The child** (18mo–8yr, non-verbal/minimally verbal) | Volume of speech attempts under low social pressure, and a way to communicate today | The only user who produces the outcome |
| **The parent** | Coaching, not homework. Certainty they're doing it right. Proof it's working. | Delivers the dose; churns if week 3 shows nothing |
| **The SLP** | Control of targets and cue levels, trustworthy home data, IEP paperwork that writes itself | **The gatekeeper and the distribution channel** — each brings 3–15 families |
| **The school / IEP team** | Measurable baseline and progress data in a defensible format | Phase 3 channel; buys on compliance and IEP defensibility |

Three of the four never produce the core outcome, and **all four can kill the product.**

## Positioning

Every existing product occupies exactly one of three boxes:

1. **AAC** — Proloquo2Go, LAMP Words for Life, TouchChat. Excellent, expensive, **communication only**. The motor-planning philosophy stops at the screen and never reaches the mouth.
2. **Clinician drill content** — Articulation Station, Apraxia Ville, Tactus. Built for the 30-minute session, not the other 167 hours. Articulation Station is also built for the *wrong disorder* — articulation is not motor planning — and is widely misapplied to CAS.
3. **Consumer engagement** — Speech Blubs. Delightful, high-reach, clinically shallow, **no accuracy feedback at all** (it does not know what the child said), and no clinician in the loop.

**Praxia occupies the intersection: a clinician-governed, parent-coached, child-engaging, data-generating home practice system for the pre-verbal child, with AAC alongside rather than instead.**

The second, sharper gap: **almost nothing serves the pre-verbal child.** Nearly every "speech therapy app" assumes the child already produces words and needs them corrected. The 18-month-to-4-year non-verbal child — the highest-anxiety, highest-willingness-to-pay moment in the entire parent journey — is served by Speech Blubs and essentially nothing else.

The closest structural precedent is **Constant Therapy**: adaptive practice + clinician dashboard + published evidence + payer motion. It proves the model. It is adult-only.

## What makes it defensible

1. **The cue hierarchy as a real state machine**, not a content tag — dynamic, trial-by-trial escalation and fading. This is the DTTC spine and it is the core IP.
2. **The video modelling asset library** — close-up real-mouth models per target. Expensive to produce, and the thing a competitor cannot clone in a quarter.
3. **The proprietary labelled corpus.** There is **no public corpus of minimally-verbal children with CAS.** It does not exist. Every consented, SLP-labelled clip we collect builds an asset nobody else has — and per-child DTW scoring delivers product value from n≈10 exemplars, so the flywheel pays out immediately rather than after a research programme.
4. **SLP trust**, which compounds and cannot be bought. It is earned by giving clinicians control, never marketing around them, and reporting honestly when progress is slow.

## What we will not do

- Claim to diagnose, treat, screen for, or cure CAS.
- Claim to replace an SLP, or market to parents around their clinician.
- Ship non-speech oral motor exercises (blowing, whistles, straws, tongue push-ups) — contradicted by McCauley et al. 2009 and the category's original sin.
- Show a child a failure state, or let a machine tell a child they were wrong.
- Gate communication behind speech performance or payment.
- Let a product claim outrun the evidence line.

## The honest risk

The central premise — that an app can close the fidelity and adherence gap that defeated parent-delivered therapy in the literature — **is unproven.** No app has demonstrated this. We are compensating for a documented failure mode, and the evidence that our compensation works does not yet exist.

We say so in the product, and we design the study that would answer it. A CAS parent has usually been sold false hope several times already. **Being the product that is honest about uncertainty is both the ethical position and, in this market, the differentiated one.**

---

## Business model summary

| Tier | Price | Rationale |
|---|---|---|
| **Communication (free, forever)** | $0 | AAC + basic practice. Ethically required; strategically the wedge. Kills the "you're gating a child's voice" objection. |
| **Family** | $19–29/mo, ~$180–250/yr | Anchored against private SLP at $100–250/session. A parent paying $800/mo will pay $25/mo for something their SLP endorses that multiplies that therapy's dose. Visible hardship/scholarship tier. |
| **Clinician portal** | Free (Pro ~$15–25/mo) | The portal is **distribution, not revenue**. Pro adds IEP report generation and caseload analytics. |
| **District/site** | $2–8k/site/yr | Phase 3. Requires DPA, VPAT, SSO, roster sync, web fallback. |

**TAM:** Idiopathic CAS alone is ~50–100k US children — a genuine niche (~$60–120M US). The defensible expansion, which must be a **product decision made now rather than a marketing afterthought**, is the adjacent population with the identical product need: severe speech sound disorders, late talkers, minimally verbal autistic children, Down syndrome, childhood dysarthria. That aggregate is millions of US children and a realistic **$500M–1.5B** US TAM.

**Strategy: build for CAS — the hardest case, the most credible clinical positioning, the most motivated buyers, the best SLP endorsement — and design the data model so the same engine expands outward without a rebuild.**

Non-dilutive funding is unusually accessible: NIDCD SBIR/STTR, NIH R41/R43, IES SBIR, and Apraxia Kids research grants (small money, disproportionate credibility and community access).
