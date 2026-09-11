# Claims Register

**Every user-facing and marketing string passes through this register before shipping.** Marketing copy is a regulatory artifact: it is what determines whether we are a general wellness product or an unapproved medical device.

Owner: PM + regulatory reviewer. Reviewed at every release and every marketing campaign.

---

## 1. The governing rule

> **A product claim must never outrun the evidence line.**

Three separate regimes police our claims:
- **FDA** — claims determine device status (diagnosis/treatment/severity-measurement claims create a regulated device)
- **FTC Act §5** — deceptive health claims, with heightened scrutiny for claims aimed at desperate parents
- **App Store / Play** — health-claim review and category policy

---

## 2. Approved claim shapes

✅ **These are cleared for use:**

| Claim | Notes |
|---|---|
| "Structured, high-repetition speech practice between therapy sessions." | The canonical positioning sentence |
| "Built on published motor-learning principles." | True; cite Maas et al. 2008 |
| "Helps you practise at home with confidence." | Coaching claim, not outcome claim |
| "Tracks how much practice your child is getting." | We measure this with certainty |
| "Designed with speech-language pathologists." | Only once the advisory board is real and named |
| "Gives your SLP a clear picture of what happened at home." | Data-transmission function, explicitly non-device |
| "Communication tools that are always available, free." | AAC positioning |
| "Research shows AAC does not reduce speech — it often increases it." | Millar, Light & Schlosser 2006. **Must include the authors' own caution that gains were modest** |

---

## 3. Forbidden claims

🚫 **These require a regulatory pathway we have not taken. They do not ship, in any surface, ever — including social media, app store copy, investor-facing material that becomes public, and support replies.**

| Forbidden | Why |
|---|---|
| "Teach your non-verbal child to talk" | No evidence any app does this. The category's signature over-claim |
| "Treats CAS" / "therapy" / "treatment for apraxia" | Treatment claim → regulated device |
| "Detects" / "screens for" / "identifies" CAS | Diagnostic claim → regulated device. Also clinically false — CAS diagnosis is expert perceptual judgment |
| "Clinically proven" / "evidence-based treatment" *(applied to our product)* | We may say our *principles* are evidence-based; we may **not** say our *product* is proven until a study reports |
| Any automated severity score, PCC, or severity index presented as clinical measurement | Measurement of a pathological state → regulated device |
| "Replaces speech therapy" / "skip the waitlist" / any SLP-substitution framing | Causes real harm by delaying assessment, and destroys the distribution channel |
| "Cure," "fix," "unlock your child's voice," "guaranteed results" | Deceptive; also cruel |
| Before/after testimonials as **primary** marketing | FTC exposure; sets false expectations |
| Milestone comparison ("your child is behind 78% of 3-year-olds") | Harmful by default; opt-in and clinically framed at most |
| Any claim our AI "understands" or "judges" the child's speech | False — and it is the exact claim our architecture refuses to make |
| Emotion-inference framing in an educational context | **Prohibited under EU AI Act Art. 5** |

---

## 4. Required disclosures

These must appear where relevant, not buried:

1. **"Praxia supports practice between sessions with a speech-language pathologist. It does not diagnose or treat, and it is not a substitute for professional assessment."** — onboarding and app store description.
2. **Evidence-level statements on thin content.** Phase 0 (the non-verbal starting point) carries an explicit note that it is based on clinical consensus rather than controlled trials. (Gap G-2.)
3. **"Your parent or clinician decides whether an attempt was correct. Praxia does not judge your child's speech."** — wherever scoring appears.
4. **AI disclosure** (EU AI Act Art. 50) wherever any algorithmic signal is shown.
5. **Honest progress framing** — "CAS progress is measured in months, not days" — in onboarding, before the first session.

---

## 5. Review process

```
Draft string
   → PM review against this register
   → Regulatory reviewer sign-off (required for any string touching efficacy, diagnosis,
     measurement, or AI capability)
   → Logged with version + date + reviewer
   → Ships
```

**Growth and marketing hires are trained on this register during onboarding.** Claim creep via marketing is logged as risk RR-05 and is one of the likeliest ways this product ends up in FDA territory without intending to.

---

## 6. Change log

| Date | Change | Reviewer |
|---|---|---|
| 2026-09-11 | Register established from research synthesis | — |
