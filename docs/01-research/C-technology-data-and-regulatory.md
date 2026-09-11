# RESEARCHER C — Technology, Data, Security & Regulatory
## Mobile app to help a NON-VERBAL child with Childhood Apraxia of Speech (CAS) learn to speak
Date: 2026-09-11. Scope: what is actually buildable in 2026, and the legal rails around it.

---

## 0. The framing constraint that drives every technical decision

The user is a **non-verbal or minimally-verbal child with CAS**. That means:

- The target productions are not words. Early on they are **vocalizations, vowels (/a/, /i/, /u/), CV syllables (ba, ma, up), reduplicated CVCV (baba), then CVC**. There is often no lexical content for an ASR to decode.
- Output is **inconsistent across repetitions of the same target** — that inconsistency *is* the diagnostic hallmark of CAS. A model that assumes a stable speaker prior will fail.
- Sessions are **high-frequency, low-duration, mass-practice** (principles of motor learning: 100+ trials in 15 min, distributed practice). The app must support rapid trial cycling, not conversational turns.
- The adult in the loop (parent or SLP) is present and is the highest-accuracy "sensor" in the system.

**Therefore: the app should NOT be architected around speech recognition. It should be architected around trial delivery, cueing hierarchy, human scoring, and *supplementary* acoustic signal extraction.** Any ASR/scoring is a confidence-tiered assist, never a gate.

This is the single most important engineering conclusion in this document.

---

## 1. SPEECH TECHNOLOGY — brutally honest

### 1.1 Why mainstream ASR fails here

Whisper, Apple `SFSpeechRecognizer`, Google STT/Chirp, Deepgram Nova, AssemblyAI Universal are all trained overwhelmingly on **adult, typical, read/broadcast/conversational speech**. Failure modes, in order of severity for our case:

1. **Acoustic mismatch.** Children have shorter vocal tracts → F0 roughly 250–400 Hz vs adult 85–180 Hz, and formants shifted up 20–50%. Sub-6yo speech sits substantially outside the training distribution. Log-mel front ends and learned encoders both degrade.
2. **Lexical/LM override.** Whisper is a seq2seq model with a strong internal language model. On weak or ambiguous acoustics it **hallucinates plausible words** — the single worst property for our use case. It will happily emit "bottle" for a grunt, or repeat the prompt text. It also emits looping repetitions and "Thank you for watching" style artifacts on near-silence. A confident wrong transcript given to a parent as feedback is actively harmful.
3. **No lexicon for non-words.** Our stimuli are frequently non-lexical (CV syllables, nonsense sequences used in DTTC/ReST protocols). ASR maps to a word inventory; there is no correct output.
4. **WER is the wrong metric and an invalid one.** Published numbers: Whisper on children with speech sound disorders shows **WER ~0.84 / CER ~0.56** in one study and ~50% error in another; fine-tuning yields ~30% relative improvement — i.e. still unusable as ground truth. Even at WER 0.3 you cannot tell a *clinician* whether /k/ was produced with correct place. WER conflates substitution/omission/distortion; clinicians need **phoneme-level and feature-level** information, plus prosody.
5. **Severity confound.** Recognition accuracy is inversely correlated with severity — so the system is *least* accurate precisely for the children who need it most. That is an equity failure, not just an accuracy failure.
6. **VAD failure.** Standard VADs (WebRTC, Silero) are tuned for speech-vs-noise. Weak breathy phonation, low-intensity vowel approximations, and vocal play get dropped as non-speech. Silero VAD is the best off-the-shelf option but needs threshold re-tuning and per-child calibration.

**Verdict: do not ship general ASR as a scoring mechanism for this population. Full stop.**

### 1.2 State of the art in atypical / child / disordered speech

- **Google Project Euphonia / Project Relate.** Personalized ASR: the user records ~300–500 phrases, a speaker-specific adaptation layer is trained, and WER drops dramatically (often 50%+ relative) for moderate dysarthria. Euphonia's published work (Frontiers, 2025) expanded collection and evaluation across etiologies. **Relevance caveat: it is built for adults with acquired motor speech disorders who have intact language and a stable (if distorted) production target.** A child with CAS cannot record 300 calibration phrases, and their productions are *inconsistent*, which breaks the core assumption of personalization. Relate is also consumer-facing, not an API you can embed with a child's data under COPPA.
- **Speech Accessibility Project (UIUC)** — consortium with Apple, Google, Microsoft, Meta, Amazon. ~959 speakers, 400+ hours, 190k+ utterances across Parkinson's, ALS, cerebral palsy, Down syndrome, stroke. Available under a **UIUC Data Use Agreement**; consortium partners first, then broader release. **Adults, not children with CAS.** Useful for robust-encoder pretraining, not for our target domain.
- **Voiceitt** — commercial personalized ASR for non-standard speech; trains on user-provided phrases. Same adult/consistency assumption.
- **Self-supervised encoders + light heads** are the practical SOTA: wav2vec2 / WavLM / HuBERT features are far more robust than mel-spectrogram pipelines for disordered speech; freeze the encoder, train a small classifier/CTC head on your own data. This is the realistic path for a startup.
- **Few-shot speaker adaptation / DTW against the child's own priors** is more tractable than speaker-independent recognition (see 1.3).

### 1.3 Datasets and licensing (the real picture)

| Dataset | Content | Licensing | Usefulness here |
|---|---|---|---|
| **TORGO** | Dysarthric adults (CP, ALS), aligned acoustic+articulatory | Free for research, restrictive for commercial | Robustness pretraining only |
| **UASpeech** | 15 dysarthric + 13 control adults, isolated words | Research license via UIUC | Same |
| **CSLU Kids** | ~1100 typical children K–10, scripted + spontaneous | LDC, paid, research-oriented | Child acoustic adaptation |
| **MyST (My Science Tutor)** | ~400h conversational child speech, ~1300 students | LDC / Boulder Learning; commercial terms available | Best child-speech corpus for encoder adaptation |
| **Speech Accessibility Project** | 400h+, 959 disordered adults | UIUC DUA, application-gated | Disorder robustness |
| **OGI Kids / PF-STAR / CMU Kids** | Smaller child corpora | Mixed research licenses | Supplementary |
| **ENNI / Talkbank / PhonBank (CHILDES)** | Child phonological corpora, some disordered | Mostly CC-BY-NC-SA — **NC blocks commercial training** | Linguistic reference, careful with NC |

**Bottom line: there is no public corpus of minimally-verbal children with CAS.** It does not exist. Any real modeling capability must be built from your own consented data. That is the moat — and the reason to design the data flywheel (1.6) from day one. Also note NC clauses: several attractive corpora are non-commercial, and mixing them into a production model creates a licensing defect that will surface in diligence.

### 1.4 What to build INSTEAD of ASR — a tiered confidence stack

Design principle: **compute only signals you can validate, and expose each with an explicit confidence tier.** Tiers 1–2 ship in MVP; Tier 3 ships behind a research flag; Tier 4 is R&D.

**Tier 1 — Deterministic, ~always right, on-device, <50 ms (SHIP FIRST)**
- **Did the child vocalize at all?** Energy envelope + Silero VAD + per-child calibrated noise floor. For a non-verbal child, *attempt count* is the primary outcome measure and this alone justifies the app.
- **Latency to respond** (prompt offset → voicing onset). Clinically meaningful in CAS (groping, initiation difficulty).
- **Duration of phonation**, **intensity envelope**, **number of voiced segments (syllable proxy)** via energy-peak + dip detection on the low-pass envelope, or `pyin`-style voicing flags.
- **Pitch contour** via **CREPE (tiny/small)** or **pYIN**; rising/falling/flat classification. Useful for prosody targets and for intonation-based approximations.

**Tier 2 — Robust analytics, on-device or edge, 50–200 ms (SHIP FIRST or FAST-FOLLOW)**
- **Syllable segmentation / count** — compare produced syllable count to target syllable count. Directly scores a core CAS target (multisyllabic sequencing). Envelope-based methods (Mermelstein / de Jong & Wempe style) are noise-sensitive but workable with headset mic + per-child thresholds.
- **Vowel space: F1/F2** via LPC or robust formant tracking on the steady-state portion of a sustained vowel. Gives an objective, explainable "your child's /a/ moved toward the adult target" chart. Beware: formant tracking on child speech is genuinely hard (high F0 undersamples the spectral envelope → use higher LPC order, or use a neural formant tracker).
- **Voice onset time (VOT)** for stop contrasts (/b/ vs /p/) — burst detection + voicing onset. Feasible on clean audio; report as research-grade.
- **DTW template matching against the child's own best prior productions.** This is the highest-value, most under-appreciated technique for this population. You do not need a speaker-independent model of "correct /ba/". You need: *is today's attempt closer to the SLP-labeled-correct exemplars from this child than to the labeled-incorrect ones?* Implementation: MFCC or wav2vec2 frame embeddings → DTW distance → k-NN over the child's own labeled exemplar bank. Cold-start is solved by the parent/SLP labeling flow (1.6). Accuracy grows with usage — a genuine product flywheel.

**Tier 3 — Model-based, needs validation, server or larger on-device model (FLAGGED)**
- **Forced alignment + Goodness of Pronunciation (GOP).** Align the target phone sequence to the audio with a CTC/HMM acoustic model (**Montreal Forced Aligner**, Kaldi, **Charsiu**, or wav2vec2-CTC forced alignment / `torchaudio.functional.forced_align`), then compute per-phone GOP = log posterior of the target phone normalized over competing phones. This is the standard CAPT (computer-aided pronunciation training) approach.
  - **Honest caveat:** GOP assumes the alignment is meaningful. For a child who omits, substitutes and distorts, forced alignment forces a path through phones that were never produced, producing garbage confidences. Mitigate with *free-phone recognition* alongside forced alignment and flag large divergence as "unscoreable."
  - Better framing: report GOP as a **continuous "accuracy estimate" with a confidence band**, and *suppress display* below a confidence threshold.
- **Binary correct/incorrect classifier per target**, trained on your accumulated labeled data (wav2vec2/WavLM frozen encoder + small head). Only deploy per-target once you have sufficient labeled exemplars (rule of thumb: ≥200 labeled attempts spanning ≥15 children before any cross-child claim; per-child models need far fewer).

**Tier 4 — R&D**
- Phoneme-level disordered-speech recognition; automatic severity scoring; automatic PCC (percent consonants correct); CAS-specific inconsistency metrics (token-to-token variability across repetitions of the same target — computable as pairwise DTW variance and arguably the most CAS-specific automatic measure anyone could ship).

### 1.5 Recommended architecture

```
[Child device — iPad/iPhone, headset or built-in mic]
  AVAudioEngine capture: 16 kHz mono PCM, measurement mode,
  AEC/AGC DISABLED (they destroy amplitude/formant validity)
     |
     ├─ Ring buffer → Tier 1 DSP (Accelerate/vDSP, Swift)  ── <30 ms → immediate UI reinforcement
     ├─ Silero VAD (Core ML / ONNX int8)                    ── ~10 ms/chunk
     ├─ CREPE-tiny pitch (Core ML)                          ── ~20 ms
     ├─ wav2vec2-base encoder, quantized (Core ML)          ── ~150-250 ms for 1-2 s clip
     │     └─ DTW k-NN vs child's local exemplar bank       ── ~20 ms
     └─ Raw audio: ENCRYPTED LOCAL STORE (default), opt-in upload only
     |
[Edge/Server — only for opted-in, consented uploads]
     ├─ MFA / wav2vec2 forced alignment + GOP
     ├─ Per-target classifier inference
     ├─ Async SLP review queue
     └─ Training pipeline (labeled data → nightly/weekly model refresh)
```

**Latency budget (hard requirement — child attention and motor-learning feedback windows):**
- Visual/auditory reinforcement after vocalization detected: **≤150 ms** (feels causal; this is the "the app responded to ME" moment that drives engagement for a non-verbal child).
- Trial-level score/feedback: **≤300 ms** after utterance offset.
- Anything slower must be **asynchronous and non-blocking** — never make the child wait on a network round trip. Never.
- **The whole practice loop must work fully offline.** Car, waiting room, school with bad wifi, airplane. Non-negotiable.

**Graceful degradation ladder:** Tier-3 model unavailable → fall back to Tier-2 DTW → fall back to Tier-1 "we heard you!" → fall back to **parent taps the score**. At every rung the app remains usable. The app never says "couldn't hear you, try again" to the child; ambiguity is resolved silently upward to the adult.

**On-device runtime choice:** **Core ML** on iOS (ANE gives best perf/watt; thermal and battery matter for a 30-min session on a child's iPad), **ONNX Runtime Mobile** or **LiteRT (TFLite)** on Android, **whisper.cpp only if** you ever need adult/clinician dictation — not for the child.

### 1.6 Human-in-the-loop and the data flywheel

This is the actual product, not a fallback.

- **Parent scoring UI.** After each attempt: three giant tap targets — ✓ correct / ~ approximation / ✗ no attempt — plus playback. Must be one-thumb, <1 s per trial, and optional (silence = unscored, not zero). Parents are moderately reliable on binary correct/incorrect for simple targets; do not ask them for phonetic transcription.
- **SLP async review.** Clinician web portal: queued attempt clips with waveform + spectrogram, target, prior attempts for comparison; SLP applies **broad/narrow phonetic transcription (IPA), cue level actually needed, and a correctness judgment**. This is gold-standard labeling.
- **Inter-rater reliability**: route ~10% of clips to two raters; track Cohen's κ; use it both for data quality and as a published validity claim.
- **Flywheel:** consented audio + SLP labels → per-child exemplar bank (immediate product value) → cross-child target-specific classifiers (medium term) → a proprietary corpus of minimally-verbal child CAS speech that literally does not exist elsewhere (long-term moat and research asset).
- **Consent is the gate.** Default = audio stays on device, deleted after N days. Training use requires separate, granular, revocable opt-in. Revocation must trigger deletion *and* a documented model-retraining/exclusion process — decide now whether you promise retraining (expensive) or only exclusion from future training (defensible if disclosed precisely).

---

## 2. MOBILE ARCHITECTURE

### 2.1 Framework comparison for *this* app

| Criterion | React Native | Flutter | Native Swift (+ later Kotlin) |
|---|---|---|---|
| Low-latency audio capture w/ AEC/AGC control | Poor–fair; needs custom native module anyway | Fair; needs platform channels + custom plugin | **Excellent** — direct AVAudioEngine/AudioUnit control |
| Real-time DSP (<50 ms) | Bridge/JSI overhead, GC jitter | Dart FFI workable but audio thread is native anyway | **Excellent** — vDSP/Accelerate, C++ audio thread |
| On-device ML (Core ML / ANE) | Wrapper libs, lagging | Wrapper libs, lagging | **Excellent** — first-party Core ML |
| Accessibility APIs (switch control, VoiceOver, AssistiveTouch, Guided Access) | Partial, buggy | **Weakest** — custom render surface fights platform a11y | **Excellent** |
| Video playback + precise sync (video modeling) | Fair | Fair | **Excellent** — AVPlayer, frame-accurate |
| Offline-first local DB | Works (WatermelonDB/SQLite) | Works (Drift/Isar) | **Excellent** (GRDB/SQLite, SwiftData) |
| Speed to two platforms | Best | Best | Slowest |
| Team cost | Lowest | Low | Highest |

### 2.2 Recommendation

**Native Swift/SwiftUI for the child-facing iOS app. Android later, native Kotlin, once the model and protocol are proven.**

Justification, specific to this app and not generic:
1. **Audio fidelity is the product.** You need `AVAudioSession` `.measurement` mode with AEC/AGC/noise-suppression *off* to preserve amplitude and spectral validity for formant and intensity analysis. Cross-platform audio plugins routinely enable voice-processing I/O and you cannot reliably turn it off through them. Getting this wrong invalidates every acoustic measure you compute.
2. **This population is disproportionately on iPad.** AAC and special-ed device deployment is overwhelmingly iOS; school and clinic ecosystems are iOS-first. Cross-platform's main benefit (day-one Android) is worth less here than almost anywhere else.
3. **Accessibility is legally and practically load-bearing.** Many CAS children are co-occurring motor-impaired; Switch Control, Guided Access (critical — keeps a child inside the app), Dwell, and VoiceOver must work natively. Flutter's custom rendering surface is the weakest option here and Section 508/VPAT procurement will surface it.
4. **On-device ML.** Core ML + ANE is the difference between a 30-minute session and a hot, dead iPad.
5. Shared logic can still be portable: put **scoring/DSP/ML in a C++ or Rust core** compiled for both platforms, with thin native UI on each. This gets you cross-platform where it matters (correctness of scoring) without giving up platform control where it matters (audio, a11y).

Counter-case, stated fairly: if the team is 2 engineers and both are RN/TS, **React Native + a custom native audio/ML module** is defensible — but budget the native module as a first-class workstream, not a plugin install. Flutter I'd rank third for this specific app purely on accessibility grounds.

### 2.3 Offline-first sync

- **Local DB:** SQLite (GRDB) or SwiftData. Every trial written locally first, synchronously, before any UI transition.
- **Sync model:** append-only outbox queue + **CRDT-ish, conflict-free by construction**. Trials are immutable events with client-generated UUIDv7 + device ID + monotonic sequence; there is nothing to merge. Mutable entities (goal status, program config) use last-writer-wins with server timestamps *plus* an audit log; genuinely concurrent clinician/parent edits on the same goal are rare and can be surfaced for manual resolution.
- **Audio:** stored locally in an encrypted container; upload deferred to wifi + charging + consent. Content-addressed (SHA-256) for dedupe and idempotent retry.
- **Clock skew:** never trust device time for research data; record both device time and server-received time.

### 2.4 Media / content pipeline

- **Video modeling** (close-up mouth models of target productions) is core to CAS intervention and is a large asset library.
- Encode HEVC + H.264 fallback, HLS with 2–3 renditions; **bundle the starter set in-app** (offline day one), lazily download the rest and pin the child's active program.
- Frame-accurate looping and slow-motion playback (0.5×/0.75×) of the mouth model — AVPlayer handles this; browser/RN players do not do it well.
- CDN with signed short-TTL URLs. Cache eviction must never evict assets belonging to the *active* program.
- Stimulus images: vector or 2× WebP, bundled, with a strict style guide (high contrast, uncluttered background — visual clutter is a real barrier for this population).

### 2.5 Clinician web portal

- **Next.js (React, TypeScript) + Tailwind + TanStack Query**, server components for report generation, PDF via headless Chromium.
- Waveform/spectrogram review: WaveSurfer.js or custom Canvas; keyboard-driven review (space=play, 1/2/3=score) because SLPs review hundreds of clips and mouse-driven review does not scale.
- SSO (SAML/OIDC) for clinics and districts; role-based access with per-child consent scoping enforced server-side, never client-side.

---

## 3. BACKEND & DATA MODEL

**Stack:** TypeScript (NestJS) or Go; **PostgreSQL** primary; S3-compatible object store for audio (SSE-KMS, per-tenant keys); Redis for queues; a batch ML pipeline (Python) reading from a warehouse replica. Boring, auditable, HIPAA-eligible infrastructure.

### Entities

- **Guardian** — identity, parental-consent records (versioned), notification prefs.
- **Child** — pseudonymous ID; **minimize direct identifiers** (first name + DOB month/year is usually enough); linked guardians; linked clinicians; consent state.
- **Clinician** — credentials (ASHA CCC-SLP #), licensure state, org, role.
- **Organization / Tenant** — clinic, school district; data-residency and retention policy attach here.
- **Stimulus / Target** — the thing to say. Phonetic transcription (IPA), syllable shape (V, CV, CVC, CVCV), phoneme inventory, word/non-word, image asset, model audio, model video, complexity features (stress pattern, sequence length).
- **Program / Hierarchy** — ordered set of targets + mastery criteria + cue hierarchy definition (e.g., DTTC: simultaneous production → immediate imitation → delayed imitation → spontaneous).
- **Goal** — child × skill, baseline, criterion, target date, IEP linkage, status.
- **Session** — child, date, setting (home/clinic/tele), who administered, duration, device.
- **Trial** — session × stimulus × ordinal. The atomic unit. **Immutable.**
- **Attempt / Recording** — trial × audio blob ref, duration, SNR, device/mic metadata, retention class.
- **CueLevel** — the cue actually provided (independent / verbal model / visual model / tactile / gestural / simultaneous production) — *the* critical variable in CAS treatment and the thing most apps omit.
- **Score** — trial × rater (`parent` | `slp` | `model:v1.2.3`) × value × confidence × rubric version. **Multiple scores per trial, never one.** Machine scores are just another rater.
- **Report** — generated artifact, snapshotted inputs, immutable, hash for integrity.

### Event-sourced trial log

Append-only `trial_events` table (or Kafka + Postgres projection):
`{event_id (uuidv7), child_id, session_id, trial_id, event_type, payload jsonb, client_ts, server_ts, device_id, app_version, protocol_version, model_version, schema_version}`

`event_type` ∈ `stimulus_presented`, `cue_given`, `vocalization_detected`, `attempt_recorded`, `parent_scored`, `slp_scored`, `model_scored`, `reinforcement_delivered`, `trial_aborted`.

Why: (a) research-grade reproducibility — you can replay any session; (b) you can re-score historical audio with a new model version and compare against human labels *retrospectively*, which is how you validate Tier-3 models without a prospective trial; (c) it is the audit log regulators and IRBs ask for; (d) versioned `protocol_version` lets you A/B intervention parameters honestly.

Derived tables (mastery %, trials-to-criterion, cue-level fading curves) are **projections**, always rebuildable.

---

## 4. PRIVACY, SECURITY & REGULATORY

This section is the one that can kill the company. Treat it as a design input, not a compliance afterthought.

### 4.1 COPPA — including the 2025 amendments (deadline passed 22 April 2026)

The FTC's amended COPPA Rule was published in 2025, effective 23 June 2025, with **full compliance required by 22 April 2026** — i.e. it is **already binding now**.

Directly relevant changes:
- **Biometric identifiers — explicitly including voiceprints — are now "personal information."** A speech-therapy app for children is squarely in scope. Audio recordings and government IDs are likewise enumerated.
- **Separate verifiable parental consent for third-party disclosure**, including disclosure for targeted advertising. You cannot bundle "use the app" consent with "share data with partners."
- **Separate opt-in consent required to use children's data to train AI/ML models.** This is explicit and is the single most important provision for our flywheel. Bundling training consent into the ToS is a violation.
- **Written, published data-retention policy**; data may be retained only as long as necessary for the purpose collected; **indefinite retention prohibited**.
- **Written children's-privacy information-security program** with a designated responsible individual, annual risk assessment, and **vendor due diligence with written assurances**.
- Expanded direct-notice and parental-access obligations — parents can demand to see the voiceprints/audio you hold.

**The old "audio file exception"** (FTC's 2017 policy statement permitting momentary audio used solely as a replacement for text input, deleted immediately) **does not apply** — we retain audio, analyze it, and want to train on it.

**Design consequence:** a **layered consent architecture** with independently revocable toggles: (1) core service, (2) cloud storage of audio, (3) clinician sharing, (4) model training, (5) research publication. Each with its own record, timestamp, policy version, and method of verification.

### 4.2 Verifiable parental consent (VPC)

Approved methods: credit/debit card transaction, signed consent form (scan/photo), government-ID match-then-delete, knowledge-based authentication, video-call verification, and (newer) **facial-age-estimation matched to ID**. **Email-plus ("email plus") is only permitted for internal-use-only data** — it does NOT cover our sharing/training use cases. Since we share with clinicians and want to train, we need a **strong VPC method**. Practical choice: $0.50 card authorization or signed-form upload, with an FTC-approved Safe Harbor program (kidSAFE, PRIVO, CARU) as both mechanism and cover.

### 4.3 FERPA / IDEA / PPRA

- If deployed via a **school or district**, student data is an **education record**; the district is the controller and you operate under the **"school official" exception** (§99.31(a)(1)) — requires legitimate educational interest, direct control by the district, and no secondary use. **Under the school-official exception you generally may NOT use the data to train your models** without separate district+parent consent. This is a hard commercial tension: school channel and data flywheel conflict.
- **IDEA Part C** (early intervention, birth–3 — where most non-verbal CAS kids are) and **Part B** (3–21): IFSP/IEP data is highly protected; Part C has its own confidentiality regs (34 CFR §303.400s).
- **PPRA** limits surveys/evaluations in schools.
- Practical: ship **two deployment modes** — Consumer (COPPA, parent-consented, training allowed) and Institutional (FERPA/IDEA, district DPA, training disabled by default). Enforce the distinction in the tenant model, in code, not in policy documents.

### 4.4 HIPAA — when does a consumer app become a Business Associate?

- **Direct-to-consumer, parent pays, no clinician:** you are generally **not** a covered entity and **not** a BA. HIPAA doesn't apply; FTC Act §5, COPPA and the **FTC Health Breach Notification Rule** (which *does* reach non-HIPAA health apps and was strengthened in 2024) do.
- **You become a BA the moment** you create/receive/maintain/transmit PHI *on behalf of* a covered entity — i.e. an SLP practice, hospital, or a school that bills Medicaid. Signing a clinic's BAA makes you one.
- **Practical answer: build to HIPAA from day one anyway.** Encryption, access controls, audit logs, minimum necessary, BAA-capable infrastructure (AWS/GCP HIPAA-eligible services + signed BAA), workforce training, breach procedures. Retrofitting HIPAA later is far more expensive than building it in, and clinics will ask for a BAA in your first enterprise deal. Also note **42 CFR Part 2** does not apply, but **state health-data laws (WA My Health My Data, NV SB 370)** may — WA MHMD has a private right of action and a broad definition of consumer health data.

### 4.5 GDPR / GDPR-K / UK AADC / US state kids codes

- **GDPR Art. 9:** voice used for **unique identification** is biometric special-category data. Even if you insist you're doing acoustic analysis rather than identification, **health data** (speech disorder) is independently Art. 9 — so Art. 9 applies either way. Lawful basis: **explicit consent** (Art. 9(2)(a)) — and consent must be freely given, which is strained when the app is the treatment. Consider Art. 9(2)(h) (health care) where a clinician relationship exists.
- **Art. 8 / GDPR-K:** digital-services consent age is 13–16 depending on member state; for under-age users, parental-holder consent with reasonable verification. Our users are far below any threshold → always parental.
- **DPIA is mandatory** (Art. 35): special-category data + vulnerable data subjects (children) + innovative technology + systematic evaluation. Three independent triggers. Do it, keep it current, and it will be asked for.
- **UK Age Appropriate Design Code (Children's Code):** 15 standards — best interests of the child primary, DPIA, age-appropriate application, high-privacy defaults, **data minimisation**, no nudge techniques, no profiling by default, transparency in child-appropriate language, connected toys/devices, online tools for exercising rights. This is the most demanding *design* standard and the most useful one to build to, because it generalizes.
- **US state kids codes:** California AADC (litigation over 1A has narrowed enforcement but the DPIA and default provisions remain influential), Maryland Kids Code, and similar in CT/VA/CO (children's amendments); **Colorado/Connecticut/Texas** comprehensive laws with specific minor protections. Plus **state comprehensive privacy laws** treating data of known-under-13s as sensitive → consent + DPA required.

### 4.6 Voice as biometric — BIPA, CUBI, and friends

- **Illinois BIPA (740 ILCS 14):** "voiceprint" is an enumerated biometric identifier. Requires **written notice + written release before collection**, a published retention/destruction schedule (destroy at purpose satisfaction or 3 years after last interaction, whichever first), no sale/profit, and reasonable care. **Private right of action**, $1,000/$5,000 per violation; 2024 amendment limited per-scan accrual to one recovery per person per modality, but exposure remains severe.
  - **Critical nuance:** BIPA covers a voiceprint — a biometric template used to identify an individual. Raw audio analyzed for articulation, not identity, is a defensible non-voiceprint position. But **speaker-adaptation/personalization embeddings and DTW exemplar banks keyed to a child look a lot like a template**. Assume BIPA applies; get written consent; publish the retention schedule. Cheap insurance against an existential lawsuit.
- **Texas CUBI (Bus. & Com. §503.001):** voiceprints covered, AG enforcement, $25,000 per violation, and Texas has been actively enforcing (large settlements against major tech). No private right of action but the AG is the bigger threat here.
- **Washington HB 1493**, **Colorado/Texas/Oregon** biometric provisions in comprehensive laws.
- **Minors + biometrics is the aggravating factor everywhere.**

**Controls:** treat any per-child speaker embedding as biometric; keep it **on-device**; if server-side, store encrypted with a per-child key held under guardian control; explicit written consent; documented destruction schedule; never sell or license it.

### 4.7 App Store / Play Store

**Apple, Guideline 1.3 (Kids Category) + 5.1.4:**
- Kids Category apps **must not include third-party analytics or third-party advertising**, except narrow cases where no IDFA/identifiable child data is transmitted and, for contextual ads, the network has published Kids-app policies with human review of creatives.
- No links out, no purchase flows, no other-app promos outside a **parental gate**.
- Must include a privacy policy and comply with COPPA/GDPR-K.
- **Practical consequence: no Firebase Analytics, no Amplitude, no Mixpanel, no Sentry-with-PII, no Meta/TikTok SDK, no attribution SDK in the child app.** Build first-party, on-device-aggregated telemetry that transmits only non-identifying counters, or keep all analytics in the *parent/clinician* app which is not in the Kids Category.
- Strategy note: you may not want the Kids Category at all. A **Medical or Education** category app whose *user* is a child but whose *account holder* is an adult avoids the Kids Category ruleset while still needing COPPA compliance. Decide deliberately; it changes your SDK budget.

**Google Play Families:**
- Target-audience declaration; Families Policy applies; **only certified "Families Self-Certified Ads SDKs"**; **no personalized advertising** to children; Designed for Families / Teacher Approved program for the Kids tab.
- 2026 update: advertising restrictions extend to **any app where children are a significant share of the actual user base**, regardless of declared category. You cannot category-shop your way out on Android.
- Data safety declarations must be accurate; misdeclaration is a common removal cause.

### 4.8 FDA — SaMD vs general wellness

Current posture (FDA updated both the **Clinical Decision Support** and **General Wellness** guidances in **January 2026**, moving in a deregulatory direction with broadened enforcement discretion). Even so, the line is drawn by **claims and intended use**, not by technology.

**Likely NOT a device / enforcement discretion (safe zone):**
- Practice/drill delivery, stimulus presentation, video modeling, scheduling, data logging, progress charting.
- "Supports speech practice," "helps you practice at home," "tracks practice sessions," "encourages communication development."
- Transmitting/storing/displaying data for a clinician (electronic-records-type functions are explicitly excluded under §520(o)(1)(A)–(C)).
- Coaching/behavioral-support tools for a general state of wellness or a low-risk chronic condition when claims stay motivational.

**Likely a REGULATED DEVICE (danger zone):**
- **Diagnosis**: "detects Childhood Apraxia of Speech," "screens for speech disorder," "identifies whether your child has CAS."
- **Treatment claims**: "treats CAS," "clinically proven to remediate apraxia," dose/protocol prescriptions that the software itself sets and adapts as therapy.
- **Severity scoring / automated assessment** presented as a clinical measurement (automated PCC, severity index) — this is measurement of a physiological/pathological state.
- **Autonomous algorithmic decisions a clinician cannot independently review.** The CDS exclusion (Cures Act §520(o)(1)(E)) requires, among other things, that the HCP can **independently review the basis** of the recommendation — so a black-box score that the SLP must trust is *outside* the exclusion. Also note the CDS exclusion covers recommendations to *HCPs*, not to patients/caregivers: **advice delivered directly to a parent does not get the CDS carve-out.**

**Recommendation:**
1. MVP ships as a **general wellness / practice-support tool** with rigorously policed marketing language. Maintain a **claims register** — every marketing and in-app string reviewed against it, with regulatory sign-off. Marketing copy is a regulatory artifact.
2. Position all algorithmic scores as **"practice signals for the adult,"** with the SLP as decision-maker, and make the underlying evidence (audio, waveform, which features drove it) visible — preserving the independent-review property in case you later want the CDS exclusion.
3. Plan a **Class II / De Novo** pathway *only* if you decide to pursue diagnostic or automated-assessment claims (that's where reimbursement lives, but it's a 18–36 month, $1–3M detour). Note there is existing precedent for cleared digital therapeutics (e.g., prescription digital therapeutics via De Novo/510(k)) so the path exists.
4. Non-US: **EU MDR** is far less forgiving than FDA — software with a medical purpose is generally **Class IIa minimum** under Rule 11, requiring a Notified Body. "General wellness" is not an EU concept. Budget for this before EU launch; it may argue for EU-later.

### 4.9 Accessibility law

- **WCAG 2.2 AA** for the web portal and any web views; **WCAG 2.2 AA + platform a11y APIs** for the app. Note 2.2 adds Target Size (Minimum) 2.5.8 (24×24 CSS px; we should far exceed it — use **≥64 pt** targets for motor-impaired children), Dragging Movements 2.5.7 (provide a non-drag alternative for every drag), Focus Not Obscured, Accessible Authentication.
- **Section 508 / VPAT (ITI Accessibility Requirements Report)** — mandatory for federal and, in practice, for most school-district and state procurement. Produce a real VPAT early; districts will ask in the RFP and "we'll do it later" loses deals.
- **ADA Title II final rule (2024)** requires state/local government entities (public schools) to meet **WCAG 2.1 AA** by **April 2026 (large) / April 2027 (small)** — so districts will push the requirement onto vendors contractually. Build to 2.2 AA and you clear it.
- **EN 301 549** (EU procurement standard) and the **European Accessibility Act**, whose obligations began **28 June 2025** — applies to consumer-facing e-commerce, e-books, and services; a paid consumer app distributed in the EU is likely in scope.
- **Population-specific a11y beyond the standards:** Switch Control / single-switch scanning; Guided Access lock; adjustable timing everywhere (children with motor planning deficits need long, configurable response windows — no fixed timeouts); reduced-motion; no flashing (seizure risk, 2.3.1); AAC device coexistence (do not fight the child's existing AAC app or hardware); simple consistent layouts; high-contrast, low-clutter visuals.

### 4.10 Concrete security controls

1. **On-device-first audio.** Raw audio never leaves the device unless a specific consent toggle is on. This is the strongest privacy claim available and the best marketing asset.
2. **Encryption at rest:** iOS Data Protection class `NSFileProtectionComplete` for audio; SQLCipher or app-layer AES-256-GCM for the local DB; server-side envelope encryption, per-tenant (ideally per-child) KMS keys.
3. **In transit:** TLS 1.3, certificate pinning, no plaintext fallback.
4. **Data minimization:** pseudonymous child IDs everywhere; identity mapping isolated in a separate service/schema with separate access controls; no DOB precision beyond month/year; no geolocation; no device advertising IDs; no contact list.
5. **Retention:** default 90 days for raw audio unless training-consented; **published, versioned retention schedule** (COPPA-mandated, BIPA-mandated); automated deletion jobs with completion receipts; derived features and scores can outlive the audio.
6. **Deletion:** one-tap "delete my child's data" honored within 30 days, cascading to backups (documented backup-expiry window) and object storage; deletion receipts.
7. **Consent & assent:** VPC for the guardian; **age-appropriate child assent** — a simple, pictorial "we're going to record your voice so you can hear yourself" screen. Ethically important for a non-verbal child who cannot object.
8. **DPA + SCCs** for EU; **subprocessor register**, published; vendor due diligence with written security assurances (now explicitly COPPA-required).
9. **SOC 2 Type II path:** policies + evidence automation (Vanta/Drata) from month 1, Type I ~month 9, Type II ~month 15–18. Schools and clinics will ask. Add **HECVAT** (higher-ed) and the **Student Data Privacy Consortium (SDPC) National DPA** — districts increasingly require the NDPA rather than your paper.
10. **Student Privacy Pledge 2020** signature — cheap, expected in K-12.
11. **Incident response:** documented IR plan, 72-hour GDPR notification capability, state breach-law matrix, **FTC Health Breach Notification Rule** applicability assessment, tabletop exercise annually.
12. **Access control:** RBAC + per-child consent scoping enforced server-side; clinician access requires an active care relationship; **full audit log of every audio playback** — who listened to a child's voice, when. Show this log to parents. It is a differentiator.
13. Penetration test annually; dependency scanning; no PII in logs or crash reports (scrub or disable third-party crash SDKs in the child app).

---

## 5. AI/ML OPS & ETHICS

- **Model registry & versioning.** Every score carries `model_version`; every model has a datasheet (training data provenance, consent basis, eval slices, known failure modes). Non-negotiable for clinician trust and for any future regulatory filing.
- **Drift monitoring.** Track score distributions, confidence distributions, abstention rate, and per-child agreement with human raters over time. Watch for device/OS/mic changes (an iOS audio-stack update can silently shift your features — this *will* happen).
- **Bias auditing.** Evaluate on slices: age band, sex, race/ethnicity (self-reported, optional, separately consented), regional accent, home language / bilingual status (**huge** — bilingual children are systematically misidentified by speech tools), severity level, co-occurring diagnoses, device model, mic type. Publish disparity metrics. **The base rates are stacked against you:** your earliest users will skew toward affluent, English-monolingual, iOS-owning families, and a model trained on them will underperform for everyone else. Actively oversample.
- **Abstention over error.** The model must be able to say "I don't know" and route to the human. Optimize for **high precision on 'correct'** and high abstention, not for coverage. A false "correct" teaches an error motor pattern — that is clinical harm, not just a bad UX.
- **Never tell a child they are wrong.** Design rule: reinforcement is for *effort and attempt*, always. Accuracy information goes to the adult, on the adult's surface, in adult language. Differential feedback ("that was close, try again with your lips together") comes from the cueing hierarchy driven by the adult or by a conservative rule, not from a probabilistic classifier. A child with CAS has usually already accumulated communication failure and learned helplessness; the app's job is to make trying feel good.
- **Explainability for clinicians.** Every score links to the audio, the waveform/spectrogram, the specific features that drove it, the confidence, and the model version. SLPs should be able to overrule with one tap, and overrules should feed training (active learning on disagreements is your highest-value labeling signal).
- **EU AI Act classification.** Timeline as of now: the Omnibus (Regulation (EU) 2026/1744, in force 27 July 2026) **deferred Annex III high-risk obligations to 2 December 2027** and Annex I to 2 August 2028; Article 5 prohibitions, Article 50 transparency, and GPAI obligations applied on schedule (Aug 2025 / Aug 2026).
  - Our likely status: **not** high-risk under Annex III if positioned as wellness/practice support — Annex III education triggers cover *access/admission and evaluation of learning outcomes*; an automated assessment used for educational placement or IEP eligibility **would** trigger Annex III(3). Emotion recognition in education is **prohibited** under Art. 5 — so do not ship anything framed as inferring the child's emotional state in an educational setting.
  - If the product becomes a medical device under MDR, it is **high-risk under Annex I** (product-safety route) automatically.
  - Children are an explicitly protected vulnerable group; Art. 5 prohibits exploiting vulnerabilities of age/disability to materially distort behaviour — relevant to how aggressively you gamify.
  - **Practical stance:** build the high-risk artifacts anyway (risk management system, data governance, technical documentation, logging, human oversight, accuracy/robustness/cybersecurity). You need almost all of it for FDA/MDR and for SOC 2 regardless, and it future-proofs you against reclassification. Art. 50 transparency (disclose AI interaction) applies now.

---

## 6. BUILD FEASIBILITY

### Realistic 4–6 month MVP (one strong iOS engineer + one backend + design + SLP advisor)
- Native iOS app: trial delivery engine, cueing hierarchy, stimulus library with images + model audio + ~100 modeling videos, reinforcement system, session flow.
- Audio capture done *right* (measurement mode, 16 kHz, calibration step, headset guidance).
- **Tier 1 signals only**, shipped: vocalization detection, attempt counting, response latency, duration, syllable-count estimate, pitch contour, playback.
- Parent 3-tap scoring + playback + "share with my SLP."
- Event-sourced local store + offline-first sync + encrypted storage.
- Clinician web portal v1: program assignment, review queue, labeling UI, progress charts, PDF report.
- Consent/VPC flows, privacy policy, retention job, deletion flow, DPIA, COPPA program documentation.
- Accessibility pass + VPAT draft.

### Fast-follow (6–12 months)
- DTW-against-own-exemplars scoring once the labeled bank exists; Android; per-target classifiers; formant/vowel-space charts as research features; SLP tele-review; first bias audit.

### Needs real research (12–36 months, and may never fully work)
- Speaker-independent phoneme-level scoring of minimally-verbal child speech; automated severity/PCC; automated CAS-vs-phonological-disorder differentiation (**do not promise this — it is a hard differential diagnosis for expert humans**); fully autonomous therapy without an adult.

### Top technical risks

| Risk | Severity | Mitigation |
|---|---|---|
| Acoustic scoring never reaches clinically useful accuracy | **Existential if you bet the product on it** | Architect so the product is valuable at Tier 1. Scoring is upside, not foundation. |
| No training data (cold start) | High | Human-in-the-loop labeling from day one; per-child DTW works at n=10 exemplars; partner with a university clinic for a seed corpus under IRB. |
| Mic/room variability destroys acoustic measures | High | Per-session calibration tone; SNR gate; recommend/bundle a headset; refuse to compute formants below an SNR threshold rather than compute them wrongly. |
| COPPA/BIPA/state-AG enforcement | High | Over-comply; Safe Harbor certification (kidSAFE/PRIVO); on-device-first; outside privacy counsel before launch, not after. |
| Claim creep into FDA territory via marketing | Medium-High | Claims register + regulatory review of every user-facing string; train the growth team. |
| Child disengagement (the actual product risk) | High | This is a game-design problem more than an ML problem. Budget for it accordingly — reinforcement variety, short sessions, novelty rotation. |
| Parent burden → churn | High | ≤1 s per trial scoring; scoring optional; app works with zero parent input. |
| iOS audio-stack changes between OS versions | Medium | Regression test suite of recorded fixtures replayed through the DSP on every OS beta. |

### Cost drivers
1. **Content production** — modeling videos, stimulus art, SLP-authored programs. Frequently underestimated; often the largest line item and it is *not* an engineering cost.
2. **SLP labeling labor** — budget as a recurring COGS line ($60–120/hr; ~200–400 clips/hr with a good keyboard-driven review UI). Consider SLP graduate-student partnerships.
3. **Compliance** — privacy counsel, DPIA, Safe Harbor certification, SOC 2, pen test, VPAT: $150–350k over 18 months.
4. **Infra** — modest. Audio storage is the variable: ~1 MB per 30 s at 16 kHz/16-bit (use FLAC or Opus → 5–10× smaller); on-device-first plus 90-day retention keeps this near-trivial.
5. **Clinical validation study** — $100–500k if you want efficacy claims and reimbursement.

---

## IMPLICATIONS FOR APP DESIGN

**Architecture & speech tech**
1. **Do not gate any core loop on speech recognition.** The trial engine, cueing hierarchy, reinforcement and data capture must be fully functional with zero ML. ASR/scoring is an enhancement layer with an off switch.
2. **Ship Tier 1 signals only in v1** — vocalization detected, attempt count, response latency, phonation duration, syllable-count estimate, pitch contour. These are deterministic, explainable, and clinically meaningful for a non-verbal child.
3. **Every machine-derived score carries an explicit confidence tier and `model_version`, and can abstain.** Suppress display below threshold; route ambiguity to the adult. Optimize for precision + abstention, never coverage.
4. **Build the per-child DTW exemplar bank as the primary personalization mechanism** — k-NN over the child's own SLP-labeled prior productions, stored and matched **on-device**. Works at n≈10 exemplars; improves with use; avoids the speaker-independent problem entirely.
5. **Capture audio at 16 kHz mono with AEC/AGC/noise-suppression DISABLED** (`AVAudioSession .measurement`), plus a per-session calibration and SNR gate. Refuse to compute acoustic measures below the SNR threshold rather than report invalid ones.
6. **Hard latency budget: ≤150 ms to child reinforcement, ≤300 ms to trial feedback, and the entire practice loop must work fully offline.** No network call is ever on the child's critical path.
7. **Native Swift/SwiftUI for iOS first**, with scoring/DSP in a portable C++/Rust core for later Android reuse. Justified by audio-stack control, Core ML/ANE, platform accessibility APIs, and the iPad-dominant installed base of this population.
8. **Human-in-the-loop by design:** ≤1-second 3-tap parent scoring (optional, never required) plus a keyboard-driven async SLP review/labeling portal. Route ~10% of clips to dual raters and track Cohen's κ.
9. **Event-sourced, append-only immutable trial log** with `client_ts`/`server_ts`, device, app/protocol/model/schema versions — enabling session replay, retrospective re-scoring of new models against historical human labels, and research-grade auditability.
10. **Model `CueLevel` as a first-class field on every trial**, and allow **multiple `Score` rows per trial** keyed by rater (`parent` / `slp` / `model:vX`). Never collapse to a single score.
11. **Offline-first with conflict-free-by-construction sync:** client-generated UUIDv7 immutable trial events in an outbox; LWW + audit log only for mutable config.
12. **Bundle the starter video-modeling and stimulus set in-app**; pin the active program's assets so eviction can never break an offline session; support frame-accurate looping and 0.5×/0.75× slow motion.

**Privacy, security, regulatory**
13. **On-device-first audio as an architectural guarantee**: raw audio never leaves the device without a specific, granular, revocable consent toggle. Default retention 90 days, encrypted with `NSFileProtectionComplete`.
14. **Layered independently-revocable consent** — core service / cloud storage / clinician sharing / **model training** / research publication — with a **strong VPC method** (card auth or signed form; email-plus is insufficient because we share and train). The amended COPPA Rule (full compliance since 22 April 2026) **requires separate opt-in for AI training** and treats **voiceprints and audio as personal information**.
15. **Treat any per-child voice embedding as a biometric identifier** under BIPA/CUBI: written notice and written release before collection, a published retention/destruction schedule, no sale or licensing, keep templates on-device where possible.
16. **Two deployment modes enforced in the tenant model, in code**: Consumer (COPPA, training permitted with consent) and Institutional (FERPA/IDEA/district DPA, **training disabled by default**). Do not let school-channel data enter the training pipeline.
17. **Build to HIPAA from day one** (BAA-capable infra, per-tenant KMS envelope encryption, minimum necessary, RBAC scoped by active care relationship) even while not yet a Business Associate, and maintain a **full audit log of every audio playback**, visible to parents.
18. **Zero third-party analytics, ads, attribution, or PII-carrying crash SDKs in the child-facing app** (Apple Guideline 1.3; Google Play Families 2026 extends restrictions by actual audience, not declared category). First-party, on-device-aggregated, non-identifying telemetry only.
19. **Maintain a claims register and route every user-facing and marketing string through regulatory review.** Positioning: practice support and general wellness. Forbidden without a regulatory pathway: "diagnoses," "screens for," "treats," "clinically proven," and any automated severity/PCC score presented as a clinical measurement.
20. **Preserve the independent-review property**: every algorithmic output links to its audio, waveform/spectrogram, driving features, confidence and model version, with one-tap clinician override that feeds active learning. This protects the CDS-exclusion posture and is required for clinician trust.
21. **Accessibility to WCAG 2.2 AA + EN 301 549**, plus population-specific requirements: ≥64 pt touch targets, Switch Control and single-switch scanning, Guided Access compatibility, **fully configurable response windows with no fixed timeouts**, reduced motion, no flashing, non-drag alternative for every drag, AAC-device coexistence. Produce a real **VPAT** before the first district RFP.
22. **Complete a DPIA before EU/UK launch** (mandatory: special-category data + children + innovative tech) and design to the UK Age Appropriate Design Code's high-privacy defaults and data-minimisation standards as the global baseline.
23. **Never surface "incorrect" to the child.** Reinforce effort and attempt, always; accuracy information goes only to the adult surface in adult language. Corrective cueing comes from the deterministic cueing hierarchy, never from a probabilistic classifier.
24. **Bias-audit from v1 across age, sex, race/ethnicity, accent, bilingual status, severity, device and mic**, publish disparity metrics, and deliberately oversample under-represented groups against an early user base that will skew affluent, monolingual and iOS-owning.
25. **Build the EU AI Act high-risk artifact set now** (risk management, data governance, technical documentation, logging, human oversight, accuracy/robustness/cybersecurity) even though Annex III obligations were deferred to **2 December 2027** — it overlaps almost entirely with FDA/MDR and SOC 2 needs. Ship Art. 50 AI-disclosure today, and **never frame any feature as emotion recognition in an educational context** (prohibited under Art. 5).

**Recommended stack:** iOS native Swift/SwiftUI + AVAudioEngine + Accelerate/vDSP + Core ML (Silero VAD, CREPE-tiny, quantized wav2vec2) + GRDB/SQLCipher; portable Rust/C++ scoring core; backend TypeScript (NestJS) or Go on Postgres + S3 (SSE-KMS, per-tenant keys) + Redis, HIPAA-eligible cloud with BAA; Python ML pipeline (torchaudio forced alignment, MFA, wav2vec2/WavLM) reading a warehouse replica; clinician portal Next.js + TypeScript + Tailwind + TanStack Query with SAML/OIDC SSO; compliance tooling Vanta/Drata, Safe Harbor via kidSAFE or PRIVO, SDPC National DPA for districts.

---

### Sources
- https://www.ncbi.nlm.nih.gov/pmc/articles/PMC11775490/ — ASR assessment of children with speech sound disorders (validation study)
- https://arxiv.org/abs/2507.14451 — Adapting Whisper for on-device child ASR
- https://link.springer.com/chapter/10.1007/978-3-031-97825-8_91 — Fine-tuning Whisper for children's speech
- https://arxiv.org/pdf/2509.19231 — Generative reconstruction of disordered speech for clinical evaluation
- https://www.frontiersin.org/journals/language-sciences/articles/10.3389/flang.2025.1569448/full — Project Euphonia
- https://github.com/speechaccessibility — Speech Accessibility Project (UIUC)
- https://publish.illinois.edu/hkim17/universal-access-ua-speech-corpus-development-universal-access-automatic-speech-recognition-project-for-talkers-with-dysarthria/ — UASpeech
- https://www.finnegan.com/en/insights/articles/coppas-amended-rule-is-now-in-full-effect-what-operators-need-to-know.html — Amended COPPA Rule in force
- https://privacylawmap.com/blog/coppa-compliance-guide-2026 — COPPA 2026 compliance guide
- https://stateofsurveillance.org/news/coppa-2026-new-rules-children-privacy-biometric-data/ — COPPA biometric/voiceprint provisions
- https://www.dlapiper.com/en-us/insights/publications/2026/01/fda-updates-its-clinical-decision-support-and-general-wellness-guidances-key-points — FDA CDS + General Wellness guidance updates (Jan 2026)
- https://www.ropesgray.com/en/insights/alerts/2026/01/fda-adapts-with-the-times-on-digital-health-updated-guidances-on-general-wellness-products — FDA digital health guidance analysis
- https://www.gibsondunn.com/eu-ai-act-omnibus-agreement-postponed-high-risk-deadlines-and-other-key-changes/ — EU AI Act Omnibus, deferred high-risk deadlines
- https://artificialintelligenceact.eu/high-level-summary/ — EU AI Act risk tiers
- https://developer.apple.com/app-store/review/guidelines/ — Apple App Review Guidelines (1.3 Kids Category)
- https://support.google.com/googleplay/android-developer/answer/9893335 — Google Play Families Policies
- https://support.google.com/googleplay/android-developer/answer/12918983 — Families Self-Certified Ads SDK Policy
