# Privacy, Security & Regulatory Plan

> **This is the section that can kill the company. It is a design input, not a compliance afterthought.**

---

## 1. COPPA — amended rule, binding now

The FTC's amended COPPA Rule took effect 23 June 2025 with **full compliance required by 22 April 2026 — it is already binding.**

Provisions that directly shape our architecture:

| Provision | Our response |
|---|---|
| **Biometric identifiers — explicitly including voiceprints — are "personal information."** Audio recordings likewise enumerated | A speech-therapy app for children is squarely in scope. On-device-first audio; per-child embeddings treated as biometric |
| **Separate verifiable parental consent for third-party disclosure** | Clinician sharing is its own toggle; cannot be bundled with "use the app" |
| **Separate opt-in to use children's data to train AI/ML** | **The single most important provision for our flywheel. Bundling training consent into the ToS is a violation.** It is an independent, revocable toggle |
| **Written, published data-retention policy; indefinite retention prohibited** | Published, versioned retention schedule; automated deletion jobs with completion receipts |
| **Written children's-privacy information-security program** | Designated responsible individual, annual risk assessment, **vendor due diligence with written assurances** |
| Expanded parental access | Parents can demand to see the audio and voiceprints we hold — and our audit log shows them who played each clip |

**The 2017 "audio file exception"** (momentary audio used solely to replace text input, deleted immediately) **does not apply to us** — we retain audio, analyse it, and want to train on it.

### Verifiable parental consent
Approved methods: card transaction, signed consent form, government-ID match-then-delete, KBA, video-call verification, facial-age-estimation matched to ID.

> **"Email-plus" is permitted only for internal-use-only data. It does NOT cover our sharing or training use cases.**

**Our choice:** $0.50 card authorisation or signed-form upload, under an FTC-approved **Safe Harbor** (kidSAFE or PRIVO — decision Q4 in the [PRD](../02-product/prd.md)) as both mechanism and cover.

### Layered consent architecture

Five independently revocable toggles, each with its own record, timestamp, policy version and verification method:

1. Core service
2. On-device audio recording
3. Cloud storage of audio
4. Clinician sharing
5. **Model training**
6. Research publication

---

## 2. Voice as biometric — BIPA, CUBI

- **Illinois BIPA (740 ILCS 14).** "Voiceprint" is enumerated. Requires **written notice + written release before collection**, a published retention/destruction schedule, no sale or profit, reasonable care. **Private right of action**, $1,000/$5,000 per violation.
  > **Critical nuance:** BIPA covers a *template used to identify*. Raw audio analysed for articulation rather than identity is a defensible non-voiceprint position — **but our speaker-adaptation embeddings and per-child DTW exemplar banks look a lot like templates.** Assume BIPA applies. Get written consent. Publish the destruction schedule. Cheap insurance against an existential lawsuit.
- **Texas CUBI.** Voiceprints covered; AG enforcement; $25,000 per violation; **Texas has been actively enforcing** with large settlements against major tech. No private right of action, but the AG is the bigger threat.
- Washington HB 1493; Colorado/Texas/Oregon biometric provisions.
- **Minors + biometrics is the aggravating factor everywhere.**

**Controls:** treat any per-child voice embedding as biometric; **keep it on-device**; if server-side, encrypt under a per-child key held under guardian control; explicit written consent; documented destruction schedule; never sell or license.

---

## 3. FERPA / IDEA — and the structural tension

- Deployed via a school, student data is an **education record**; the district is the controller and we operate under the **"school official" exception** (§99.31(a)(1)) — requiring legitimate educational interest, direct district control, and **no secondary use.**
- **Under that exception we generally may NOT train our models on district data** without separate district and parent consent.
- **IDEA Part C** (birth–3, where most non-verbal CAS children are) has its own confidentiality regulations (34 CFR §303.400s); **Part B** (3–21) covers IEP data.
- **PPRA** limits surveys/evaluations in schools.

> **This is a permanent commercial tension between the school channel and the data flywheel.** Resolution: two deployment modes **enforced in the tenant model, in code** — Consumer (training permitted) and Institutional (training disabled by default, not toggleable). Consumer-first sequencing; build the corpus before entering districts. See [CR-3](../01-research/D-synthesis-and-conflict-resolution.md) and RR-09.

---

## 4. HIPAA

- **Direct-to-consumer, parent pays, no clinician:** we are generally **not** a covered entity and **not** a Business Associate. HIPAA doesn't apply — but FTC Act §5, COPPA, and the **FTC Health Breach Notification Rule** (strengthened 2024, and it *does* reach non-HIPAA health apps) all do.
- **We become a BA** the moment we create/receive/maintain/transmit PHI *on behalf of* a covered entity — an SLP practice, hospital, or Medicaid-billing school. Signing a clinic's BAA makes us one.
- **Decision: build to HIPAA from day one anyway.** Encryption, access controls, audit logs, minimum necessary, BAA-capable infrastructure (HIPAA-eligible cloud + signed BAA), workforce training, breach procedures. **Retrofitting HIPAA is far more expensive than building it in**, and clinics will ask for a BAA in our first enterprise deal.
- Note also **state health-data laws** — Washington My Health My Data (with a **private right of action** and a broad consumer-health-data definition), Nevada SB 370.

---

## 5. GDPR / UK AADC / state kids codes

- **GDPR Art. 9.** Voice used for unique identification is biometric special-category data. **Even if we insist we do acoustic analysis rather than identification, *health data* (speech disorder) is independently Art. 9** — so Art. 9 applies either way. Lawful basis: explicit consent (9(2)(a)), strained because consent must be freely given when the app is the treatment; consider 9(2)(h) (health care) where a clinician relationship exists.
- **DPIA is mandatory** (Art. 35) on **three independent triggers**: special-category data + vulnerable data subjects (children) + innovative technology and systematic evaluation. Do it, keep it current, expect to be asked for it.
- **UK Age Appropriate Design Code** — 15 standards: best interests of the child primary, high-privacy defaults, data minimisation, **no nudge techniques**, no profiling by default, child-appropriate transparency. **The most demanding design standard and the most useful to build to globally, because it generalises.**
- **US state kids codes:** California AADC, Maryland Kids Code, CT/VA/CO children's amendments; comprehensive state laws treating known-under-13 data as sensitive.

---

## 6. FDA — SaMD vs general wellness

FDA updated both the **Clinical Decision Support** and **General Wellness** guidances in **January 2026**, moving deregulatory. **But the line is drawn by claims and intended use, not by technology.**

### Safe zone — not a device / enforcement discretion
Practice and drill delivery · stimulus presentation · video modelling · scheduling · data logging · progress charting · transmitting and displaying data for a clinician (explicitly excluded under §520(o)(1)(A)–(C)) · motivational coaching.
Language: *"supports speech practice," "helps you practice at home," "tracks practice sessions."*

### Danger zone — likely a regulated device
- **Diagnosis:** "detects Childhood Apraxia of Speech," "screens for speech disorder"
- **Treatment claims:** "treats CAS," "clinically proven to remediate apraxia"
- **Severity scoring / automated assessment** presented as clinical measurement (automated PCC, severity index)
- **Autonomous algorithmic decisions a clinician cannot independently review.** The CDS exclusion requires the HCP can **independently review the basis** — so a black-box score the SLP must trust falls *outside* it. Note too that **the CDS exclusion covers recommendations to HCPs, not to caregivers** — advice delivered directly to a parent gets no carve-out.

### Our posture
1. MVP ships as a **general wellness / practice-support tool** with rigorously policed language. **Marketing copy is a regulatory artifact.**
2. All algorithmic output is framed as **"practice signals for the adult,"** with the SLP as decision-maker and the underlying evidence (audio, waveform, driving features) visible — **preserving the independent-review property** in case we later want the CDS exclusion.
3. Class II / De Novo pathway **only** if we pursue diagnostic or automated-assessment claims — where reimbursement lives, but an 18–36 month, $1–3M detour.
4. **EU MDR is far less forgiving than FDA.** Software with a medical purpose is generally **Class IIa minimum under Rule 11**, requiring a Notified Body. **"General wellness" is not an EU concept.** This argues for EU-later.

---

## 7. EU AI Act

- Timeline: the Omnibus **deferred Annex III high-risk obligations to 2 December 2027** and Annex I to 2 August 2028. **Article 5 prohibitions and Article 50 transparency apply now.**
- **Our likely status: not high-risk** under Annex III if positioned as wellness/practice support. Annex III education triggers cover *access/admission and evaluation of learning outcomes* — an automated assessment used for **educational placement or IEP eligibility would trigger Annex III(3).**
- **Emotion recognition in education is prohibited under Art. 5.** **We never ship anything framed as inferring the child's emotional state in an educational setting.** (Note: our aversion detection is framed and implemented as *engagement//behavioural signal for session safety*, not emotion inference — this framing must be reviewed by counsel and held consistently.)
- Art. 5 also prohibits **exploiting vulnerabilities of age or disability to materially distort behaviour** — directly relevant to how aggressively we gamify, and another reason for the banned-dark-patterns list.
- If the product ever becomes an MDR medical device, it is **automatically high-risk under Annex I.**
- **Practical stance: build the high-risk artifact set now** (risk management, data governance, technical documentation, logging, human oversight, accuracy/robustness/cybersecurity). It overlaps almost entirely with FDA/MDR and SOC 2 needs and future-proofs against reclassification.

---

## 8. App Store & Play Store

**Decision: Education category, adult account holder. Not Kids Category.** See [CR-7](../01-research/D-synthesis-and-conflict-resolution.md).

Rationale: Google Play Families applies by **actual audience regardless of declared category** (2026 update), so category-shopping buys nothing on Android. What Education buys is freedom to run a normal adult parent/clinician surface without the parental-gate ruleset distorting it — while we retain the *substance* of the restrictions voluntarily.

**Regardless of category, in the child client:**
> **Zero third-party analytics, ads, attribution, or PII-carrying crash SDKs.** No Firebase Analytics, no Amplitude, no Mixpanel, no Sentry-with-PII, no Meta/TikTok SDK, no attribution SDK.

First-party, on-device-aggregated telemetry transmitting only non-identifying counters. Any richer analytics lives in the adult surface.

Data-safety declarations must be accurate — **misdeclaration is a common removal cause.**

---

## 9. Accessibility law

- **WCAG 2.2 AA** for app and portal, plus platform accessibility APIs
- **Section 508 / VPAT** — produce a real VPAT **before the first district RFP**
- **ADA Title II final rule (2024)** — public schools must meet WCAG 2.1 AA (large entities April 2026); districts push this onto vendors contractually. Building to 2.2 AA clears it
- **EN 301 549** and the **European Accessibility Act** (obligations began 28 June 2025)

Full spec in [UX principles §4](../03-design/ux-principles.md).

---

## 10. Security controls

1. **On-device-first audio** — raw audio never leaves the device absent a specific consent toggle. **The strongest privacy claim available and our best marketing asset.**
2. **At rest:** `NSFileProtectionComplete` for audio; SQLCipher / AES-256-GCM for the local DB; server-side envelope encryption with **per-tenant (ideally per-child) KMS keys**
3. **In transit:** TLS 1.3, certificate pinning, no plaintext fallback
4. **Data minimisation:** pseudonymous child IDs; identity mapping isolated in a separate service/schema; **no DOB precision beyond month/year; no geolocation; no advertising IDs; no contact list**
5. **Retention:** published, versioned schedule (COPPA- and BIPA-mandated); automated deletion with completion receipts
6. **Deletion:** one-tap, honoured within 30 days, cascading to backups and object storage, with receipts
7. **Consent & assent:** VPC for the guardian; **age-appropriate pictorial child assent** — ethically important for a non-verbal child who cannot object
8. **DPA + SCCs** for EU; published subprocessor register; vendor due diligence with written assurances (now COPPA-required)
9. **SOC 2 Type II path** — policies and evidence automation from month 1, Type I ~month 9, Type II ~month 15–18. Add **HECVAT** and the **SDPC National DPA** (districts increasingly require the NDPA rather than our paper)
10. **Student Privacy Pledge** signature — cheap, expected in K-12
11. **Incident response** — documented plan, 72-hour GDPR notification capability, state breach-law matrix, FTC Health Breach Notification Rule assessment, annual tabletop
12. **Access control** — RBAC + per-child consent scoping **enforced server-side, never client-side**; clinician access requires an active care relationship; **full audit log of every audio playback, shown to parents. It is a differentiator.**
13. Annual penetration test; dependency scanning; **no PII in logs or crash reports**

---

## 11. Compliance calendar

| When | What |
|---|---|
| Before any recording ships | VPC flow, layered consent, retention job, privacy policy, Safe Harbor engagement |
| Before EU/UK launch | **DPIA** (mandatory), DPA + SCCs, AADC design review |
| Before first district RFP | VPAT, SDPC NDPA, Student Privacy Pledge, HECVAT |
| Before first clinic enterprise deal | BAA-capable infra verified, SOC 2 Type I |
| Continuous | Claims register review of **every** user-facing string; bias audit; model datasheets; subprocessor register |
