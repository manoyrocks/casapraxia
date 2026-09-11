# Speech Signal Specification — The Tiered Confidence Stack

**Design principle: compute only signals you can validate, and expose each with an explicit confidence tier.**

---

## 1. Why not ASR

| Failure mode | Consequence here |
|---|---|
| **Acoustic mismatch** | Children have F0 ~250–400 Hz vs adult 85–180 Hz, formants shifted up 20–50%. Sub-6yo speech sits substantially outside the training distribution |
| **Lexical/LM override** | Whisper's strong internal LM **hallucinates plausible words** from weak acoustics — it will emit "bottle" for a grunt. **A confident wrong transcript given to a parent is actively harmful** |
| **No lexicon for non-words** | Our stimuli are frequently non-lexical (CV syllables, nonsense sequences). There is no correct ASR output |
| **WER is invalid here** | ~0.84 WER / ~0.56 CER on children with SSD; fine-tuning buys ~30% relative and is still unusable. WER also conflates substitution/omission/distortion — clinicians need **phoneme- and feature-level** information plus prosody |
| **Severity confound** | Accuracy is inversely correlated with severity — **least accurate for the children who need it most.** An equity failure, not just an accuracy failure |
| **VAD failure** | Standard VADs drop weak breathy phonation, low-intensity vowel approximations and vocal play as non-speech. Silero is the best off-the-shelf option but needs **per-child threshold calibration** |

> **Verdict: do not ship general ASR as a scoring mechanism for this population. Full stop.**

---

## 2. The tiers

### Tier 1 — Deterministic · on-device · <50 ms · **SHIP IN v1**

| Signal | Method |
|---|---|
| **Did the child vocalize?** | Energy envelope + Silero VAD + per-child calibrated noise floor |
| **Response latency** (prompt offset → voicing onset) | Clinically meaningful in CAS — groping, initiation difficulty |
| **Phonation duration** | Envelope |
| **Intensity envelope** | vDSP |
| **Voiced-segment count** (syllable proxy) | Energy-peak + dip detection on the low-pass envelope |
| **Pitch contour** (rising/falling/flat) | CREPE-tiny or pYIN |

> **For a non-verbal child, attempt count is the primary outcome measure — and this tier alone justifies the product.** No ML required.

### Tier 2 — Robust analytics · on-device/edge · 50–200 ms · **v1.5 FAST-FOLLOW**

- **Syllable segmentation and count vs target** — directly scores a core CAS target (multisyllabic sequencing). Envelope-based; noise-sensitive; needs headset mic + per-child thresholds.
- **DTW template matching against the child's own best prior productions.** **This is the highest-value, most under-appreciated technique for this population.**

> We do not need a speaker-independent model of "correct /ba/". We need: *is today's attempt closer to the SLP-labelled-correct exemplars **from this child** than to the labelled-incorrect ones?*
>
> MFCC or wav2vec2 frame embeddings → DTW distance → k-NN over the child's own labelled exemplar bank. Cold start is solved by the parent/SLP labelling flow. **Works at n≈10 exemplars and improves with use — a genuine product flywheel.** Runs on-device.

- **Vowel space F1/F2** on sustained-vowel steady state — objective, explainable ("your child's /ɑ/ moved toward the adult target"). *Caveat: formant tracking on child speech is genuinely hard — high F0 undersamples the spectral envelope. Use higher LPC order or a neural tracker. Report as research-grade.*
- **Voice Onset Time** for stop contrasts (/b/ vs /p/). Feasible on clean audio; research-grade.

### Tier 3 — Model-based · needs validation · **RESEARCH FLAG, Phase 2+**

- **Forced alignment + Goodness of Pronunciation.** Align target phone sequence (MFA, Kaldi, Charsiu, or `torchaudio.functional.forced_align`), compute per-phone GOP.
  > **Honest caveat: forced alignment forces a path through phones that were never produced**, producing garbage confidences for a child who omits, substitutes and distorts. Mitigate by running **free-phone recognition alongside** and flagging large divergence as **"unscoreable."** Report GOP as a continuous estimate with a confidence band and **suppress display below threshold.**
- **Per-target binary classifier** (frozen wav2vec2/WavLM + small head). Deploy per target only at **≥200 labelled attempts spanning ≥15 children** before any cross-child claim; per-child models need far fewer.

### Tier 4 — R&D · may never fully work

Phoneme-level disordered-speech recognition · automated severity scoring · automated PCC · **CAS-specific inconsistency metrics** (token-to-token variability across repetitions, computable as pairwise DTW variance — arguably the most CAS-specific automatic measure anyone could ship).

**Do not promise automated CAS-vs-phonological-disorder differentiation.** It is a hard differential diagnosis for expert humans.

---

## 3. Capture requirements

```swift
AVAudioSession: .measurement mode
Sample rate:    16 kHz mono PCM
AEC:            DISABLED
AGC:            DISABLED
Noise suppression: DISABLED
```

These destroy amplitude and spectral validity. **Cross-platform audio plugins routinely re-enable voice-processing I/O and you cannot reliably turn it off through them** — this is a primary reason for the native-iOS decision.

- **Per-session calibration tone** establishes the noise floor
- **SNR gate:** below threshold, **refuse to compute acoustic measures rather than report invalid ones**
- Recommend (or bundle) a headset
- Encode stored audio as FLAC or Opus — 5–10× smaller than raw PCM

---

## 4. Human-in-the-loop and the data flywheel

**This is the actual product, not a fallback.**

| Stage | Mechanism |
|---|---|
| **Parent scoring** | Three giant taps — ✓ correct / ~ approximation / ✗ no attempt — plus playback. One-thumb, <1s, **optional** (silence = unscored, not zero). Parents are moderately reliable on binary correct/incorrect for simple targets; **never ask them for phonetic transcription** |
| **SLP async review** | Clip queue with waveform + spectrogram, target, and prior attempts for comparison. SLP applies broad/narrow IPA, **cue level actually needed**, and a correctness judgment. Gold-standard labelling |
| **Inter-rater reliability** | Route ~10% of clips to two raters; track **Cohen's κ** — both a data-quality control and a publishable validity claim |
| **Flywheel** | Consented audio + SLP labels → per-child exemplar bank (**immediate** product value) → cross-child target classifiers (medium term) → **a proprietary corpus of minimally-verbal child CAS speech that does not exist anywhere else** (long-term moat and research asset) |

### Consent is the gate
Default: **audio stays on device, deleted after 90 days.** Training use requires **separate, granular, revocable opt-in** (COPPA-mandated as separate since 22 April 2026).

**Revocation must trigger deletion *and* a documented model-retraining/exclusion process.** Decide now and disclose precisely: we promise **exclusion from future training**, not retroactive retraining of deployed models — defensible only if stated exactly.

---

## 5. Dataset landscape

| Dataset | Content | Licence | Use here |
|---|---|---|---|
| TORGO | Dysarthric adults | Research-only, restrictive commercially | Robustness pretraining |
| UASpeech | 15 dysarthric + 13 control adults | UIUC research licence | Same |
| CSLU Kids | ~1100 typical children K–10 | LDC, paid | Child acoustic adaptation |
| **MyST** | ~400h conversational child speech | LDC/Boulder, commercial terms available | **Best child-speech corpus for encoder adaptation** |
| Speech Accessibility Project | 400h+, 959 disordered **adults** | UIUC DUA, application-gated | Disorder robustness |
| PhonBank / CHILDES | Child phonological corpora | **Mostly CC-BY-NC-SA — NC blocks commercial training** | Linguistic reference only |

> **There is no public corpus of minimally-verbal children with CAS. It does not exist.** Any real modelling capability must be built from our own consented data — which is precisely why the flywheel is the moat.

**Licensing hazard:** several attractive corpora are non-commercial. Mixing them into a production model creates a **licensing defect that will surface in diligence.** Maintain a dataset provenance register.

---

## 6. ML ops & ethics

- **Model registry.** Every score carries `model_version`; every model has a **datasheet** — training data provenance, consent basis, eval slices, known failure modes.
- **Drift monitoring.** Score distributions, confidence distributions, **abstention rate**, per-child agreement with human raters. Watch for device/OS/mic changes — **an iOS audio-stack update can silently shift your features, and it will happen.**
- **Bias auditing from v1** across: age band, sex, race/ethnicity (self-reported, optional, separately consented), regional accent, **home language / bilingual status (huge — bilingual children are systematically misidentified by speech tools)**, severity, co-occurring diagnoses, device model, mic type. Publish disparity metrics.
  > **The base rates are stacked against us:** our earliest users will skew affluent, English-monolingual and iOS-owning. A model trained on them will underperform for everyone else. **Actively oversample.**
- **Abstention over error.** The model must be able to say "I don't know" and route to the human.
- **Never tell a child they are wrong.** Reinforcement is for effort and attempt, always. Corrective cueing comes from the **deterministic cue hierarchy**, never from a probabilistic classifier.
- **Explainability.** Every score links to its audio, waveform/spectrogram, driving features, confidence and model version, with **one-tap clinician override that feeds active learning.** This also preserves the FDA CDS-exclusion posture.
