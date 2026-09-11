# Risk Register

Severity × likelihood, with the mitigation owner. Reviewed monthly.

---

## Clinical & safety risks

| ID | Risk | Sev | Mitigation |
|---|---|---|---|
| **RR-01** | **Speech aversion.** A child drilled at too-high difficulty, or marked wrong repeatedly, stops attempting speech. **Effectively irreversible, and worse than no practice at all.** | **Critical** | Error-reduced learning as a *safety* rule; 40%/10-trial auto-retire circuit breaker; aversion detection (latency, no-response, mid-session exit); hard session cap; no failure states; "stopping early was right" coaching. Tracked as a counter-metric |
| **RR-02** | **Parent over-drilling.** The most motivated parents are the most dangerous; gamifying volume invites it | High | Session ends itself; no reward for high daily volume; over-practice flag to the SLP; "stopping is a skill" coaching |
| **RR-03** | **Delayed referral / false reassurance.** A dashboard shows "improvement" while a child needs neurology, or a family substitutes the app for evaluation | **Critical** | Red-flag screening with **hard interrupts**, not warnings; hearing-status gate; 90-day re-screen; onboarding actively routes to evaluation; stuck-target pathway escalates |
| **RR-04** | **Wrong feedback trains the wrong motor plan.** A false "correct" is clinical harm, not just bad UX | **Critical** | No machine accuracy score in v1; abstention over coverage; human is always the arbiter; never child-visible |

## Regulatory & legal risks

| ID | Risk | Sev | Mitigation |
|---|---|---|---|
| **RR-05** | **Claim creep into FDA device territory via marketing.** The likeliest path to accidental regulation | High | [Claims register](claims-register.md) with mandatory regulatory sign-off; growth team trained at onboarding |
| **RR-06** | **COPPA enforcement** — voiceprints and audio are personal information; separate training consent required since 22 Apr 2026 | **Critical** | Layered consent; strong VPC (not email-plus); Safe Harbor certification; published retention schedule; outside privacy counsel **before** launch |
| **RR-07** | **BIPA/CUBI exposure.** Per-child embeddings and DTW exemplar banks resemble biometric templates. BIPA carries a private right of action at $1,000/$5,000 per violation | High | Assume BIPA applies; written notice + release; published destruction schedule; keep templates on-device; never sell or license |
| **RR-08** | **EU MDR.** "General wellness" is not an EU concept; Rule 11 puts medical-purpose software at Class IIa minimum | Med-High | EU-later sequencing; DPIA before any EU launch; budget Notified Body before committing |
| **RR-09** | **Structural: school channel vs data flywheel.** FERPA's school-official exception blocks training on district data | High | **Permanent** two-tenant-mode architecture enforced in code; consumer-first sequencing to build the corpus before entering districts |
| **RR-10** | **Dataset licensing defect.** NC-licensed corpora mixed into a production model surfaces in diligence | Medium | Dataset provenance register; NC corpora for reference only, never training |

## Product & market risks

| ID | Risk | Sev | Mitigation |
|---|---|---|---|
| **RR-11** | **Abandonment — the #1 commercial risk.** Consumer health retention is brutal; most families churn in 2–4 weeks, *before CAS progress is even detectable* | **Critical** | Visible win inside week 1 (day-10 before/after clip from the day-1 baseline); the **SLP relationship** is the real retention mechanism; ≤90s setup; coaching as its own reason to open; 12-week default reporting window |
| **RR-12** | **Clinician rejection.** One influential SLP post can define the product in the community | High | Co-develop with practising CAS clinicians; publish methodology; give clinicians control and credit; **never market around them** |
| **RR-13** | **False hope.** Desperate parents read any marketing as a promise; a child who doesn't progress makes the app the villain | High | No cure/therapy/guarantee language; expectation-setting in onboarding; no testimonial-led marketing; honest slow-progress reporting |
| **RR-14** | **Screen-time objection** from paediatricians and SLPs, given an 18-month lower bound against AAP/WHO under-2 guidance | Medium | Joint-media-engagement positioning, published; parent-mediated and short; off-screen generalisation cards; honest screen-minute reporting; no autoplay |
| **RR-15** | **Honesty vs retention tension.** Honest slow-progress reporting raises short-term churn | Medium | **Accept it.** The long-term asset is SLP trust; a product that flatters parents loses the distribution channel |
| **RR-16** | **Content production cost overrun** — often the largest line item and not an engineering cost | Med-High | Separate workstream with its own owner and budget; scope v1 at ~150 model videos |

## Technical risks

| ID | Risk | Sev | Mitigation |
|---|---|---|---|
| **RR-17** | **Acoustic scoring never reaches clinically useful accuracy** | **Existential *if* the product is bet on it** | **Architect so the product is valuable at Tier 1.** Scoring is upside, never foundation |
| **RR-18** | **Cold start — no training data.** No public corpus of minimally-verbal children with CAS exists | High | Human-in-the-loop labelling from day one; per-child DTW works at n≈10; university clinic partnership under IRB for a seed corpus |
| **RR-19** | **Mic/room variability invalidates acoustic measures** | High | Per-session calibration tone; SNR gate; recommend/bundle headset; **refuse to compute rather than compute wrongly** |
| **RR-20** | **iOS audio-stack changes silently shift features between OS versions** — this will happen | Medium | Regression suite of recorded fixtures replayed through the DSP on every OS beta |
| **RR-21** | **Bias against bilingual, non-mainstream-dialect and under-served children.** Early users will skew affluent, monolingual, iOS-owning | High | Bias-audit slices from v1; publish disparity metrics; **actively oversample**; disclaim where unvalidated |

## The premise risk

| ID | Risk | Sev | Mitigation |
|---|---|---|---|
| **RR-22** | **The central thesis is unproven.** Thomas et al. (2017) found clinician-parent split delivery was **less** effective and parents disengaged. We claim an app closes that fidelity/adherence gap. **No app has demonstrated this.** | **Critical / foundational** | Say so in the product; never claim efficacy before a study reports; design the validation study in Phase 2; treat the day-1 baseline corpus as the substrate for it. This risk is not mitigable by engineering — only by evidence |
