# Technical Architecture

---

## 1. The framing constraint

**Praxia is not architected around speech recognition.**

The target productions are vowels and CV syllables, frequently non-lexical, and production is **inconsistent by definition** — that inconsistency *is* the diagnostic hallmark of CAS. This breaks the stable-speaker assumption that every personalised-ASR system depends on. Published numbers: Whisper on children with speech sound disorders runs **WER ~0.84 / CER ~0.56**; fine-tuning buys ~30% relative and is still unusable as ground truth. Worse, Whisper's strong internal language model **hallucinates plausible words from weak acoustics**, and accuracy degrades *with severity* — least accurate for the children who need it most.

> **The system is architected around trial delivery, cueing hierarchy, human scoring, and supplementary acoustic signal extraction. Any scoring is a confidence-tiered assist, never a gate.**

The trial engine, cue hierarchy, reinforcement and data capture must be **fully functional with zero ML.**

---

## 2. Stack decision

### Child client — native Swift/SwiftUI, iOS/iPadOS

Justified specifically, not generically:

1. **Audio fidelity is the product.** We require `AVAudioSession .measurement` with **AEC/AGC/noise-suppression off** to preserve amplitude and spectral validity. Cross-platform audio plugins routinely enable voice-processing I/O and you cannot reliably disable it through them. **Getting this wrong invalidates every acoustic measure we compute.**
2. **This population is disproportionately on iPad.** AAC and special-ed device deployment is overwhelmingly iOS. Cross-platform's main benefit — day-one Android — is worth less here than almost anywhere else.
3. **Accessibility is legally and practically load-bearing.** Switch Control, Guided Access, Dwell, VoiceOver must work natively. Flutter's custom rendering surface is the weakest option here and Section 508/VPAT procurement will surface it.
4. **On-device ML.** Core ML + ANE is the difference between a 30-minute session and a hot, dead iPad.

**Portability hedge:** scoring/DSP/ML lives in a **portable Rust or C++ core** compiled for both platforms, with thin native UI on each. Cross-platform where it matters (correctness of scoring); platform control where it matters (audio, accessibility).

*Counter-case, recorded fairly:* with a 2-engineer all-TypeScript team, React Native + a custom native audio/ML module is defensible — but the native module must be budgeted as a **first-class workstream, not a plugin install.** Flutter ranks third for this app purely on accessibility grounds.

### Full stack

| Layer | Choice |
|---|---|
| **Child client** | Swift/SwiftUI · AVAudioEngine · Accelerate/vDSP · Core ML · GRDB + SQLCipher |
| **Scoring core** | Rust (or C++), compiled for iOS/Android |
| **On-device models** | Silero VAD, CREPE-tiny, quantised wav2vec2 (all Core ML / ANE) |
| **Backend** | TypeScript (NestJS) or Go · PostgreSQL · S3-compatible (SSE-KMS, per-tenant keys) · Redis |
| **ML pipeline** | Python · torchaudio forced alignment · MFA · wav2vec2/WavLM · reads a warehouse replica |
| **Clinician portal** | Next.js · TypeScript · Tailwind · TanStack Query · WaveSurfer.js · SAML/OIDC SSO |
| **Reports** | Server components + headless Chromium → PDF |
| **Compliance tooling** | Vanta or Drata · kidSAFE or PRIVO Safe Harbor · SDPC National DPA |

Boring, auditable, HIPAA-eligible infrastructure. Deliberately.

---

## 3. On-device audio pipeline

```
[iPad/iPhone — headset or built-in mic]
  AVAudioEngine: 16 kHz mono PCM, .measurement mode, AEC/AGC DISABLED
  Per-session calibration tone + SNR gate
     │
     ├─ Ring buffer → Tier-1 DSP (vDSP)         ──  <30 ms  → immediate UI reinforcement
     ├─ Silero VAD (Core ML, int8)              ──  ~10 ms/chunk
     ├─ CREPE-tiny pitch (Core ML)              ──  ~20 ms
     ├─ [v1.5] wav2vec2-base encoder, quantised ──  ~150–250 ms for a 1–2 s clip
     │      └─ DTW k-NN vs child's local exemplar bank  ── ~20 ms
     └─ Raw audio → ENCRYPTED LOCAL STORE (default) · opt-in upload only
     │
[Server — only for consented uploads]
     ├─ Async SLP review queue
     ├─ [Phase 2+] MFA / wav2vec2 forced alignment + GOP  (research-flagged)
     └─ Training pipeline (labelled data → periodic model refresh)
```

### Latency budget — hard requirements

| Event | Budget | Why |
|---|---|---|
| Vocalization detected → child reinforcement | **≤150 ms** | Feels causal. This is the "the app responded to **me**" moment that drives engagement for a non-verbal child. |
| Utterance offset → trial feedback | **≤300 ms** | Motor-learning feedback window |
| Anything slower | **Asynchronous and non-blocking** | **Never make the child wait on a network round trip. Ever.** |

**The whole practice loop must work fully offline** — car, waiting room, school with bad wifi, airplane. Non-negotiable.

### Graceful degradation ladder

```
Tier-3 model unavailable → Tier-2 DTW → Tier-1 "we heard you!" → parent taps the score
```

At every rung the app remains usable. **The app never says "couldn't hear you, try again" to the child.** Ambiguity resolves silently upward to the adult.

---

## 4. Offline-first sync

- **Local DB:** SQLite via GRDB, encrypted with SQLCipher. Every trial written locally **synchronously, before any UI transition.**
- **Sync:** append-only outbox queue, **conflict-free by construction.** Trials are immutable events with client-generated UUIDv7 + device ID + monotonic sequence — there is nothing to merge.
- **Mutable config** (goal status, program settings): last-writer-wins with server timestamps **plus an audit log**. Genuinely concurrent clinician/parent edits are rare and surface for manual resolution.
- **Audio:** encrypted local container; upload deferred to wifi + charging + consent; content-addressed (SHA-256) for dedupe and idempotent retry.
- **Clock skew:** **never trust device time for research data.** Record both `client_ts` and `server_ts`.

---

## 5. Media & content pipeline

Video modelling — close-up mouth models per target — is core to the intervention and is a large asset library.

- HEVC + H.264 fallback; HLS with 2–3 renditions
- **Starter set bundled in-app** so day one works offline; remainder lazily downloaded
- **Active program assets are pinned and can never be evicted** — cache eviction must never break an offline session
- **Frame-accurate looping and 0.5×/0.75× slow motion** of the mouth model (AVPlayer handles this; browser and RN players do not)
- CDN with signed short-TTL URLs
- Stimulus images: vector or 2× WebP, bundled, strict style guide — high contrast, uncluttered backgrounds

> **Content production is frequently the largest line item on a project like this, and it is not an engineering cost.** It gets its own workstream and owner.

---

## 6. Top technical risks

| Risk | Severity | Mitigation |
|---|---|---|
| Acoustic scoring never reaches clinically useful accuracy | **Existential *if* the product is bet on it** | **Architect so the product is valuable at Tier 1.** Scoring is upside, not foundation. |
| Cold start — no training data | High | Human-in-the-loop labelling from day one; per-child DTW works at n≈10; university clinic partnership under IRB for a seed corpus |
| Mic/room variability destroys acoustic measures | High | Per-session calibration tone; SNR gate; recommend/bundle a headset; **refuse to compute below threshold rather than compute wrongly** |
| COPPA/BIPA/state-AG enforcement | High | Over-comply; Safe Harbor certification; on-device-first; outside privacy counsel **before** launch |
| Claim creep into FDA territory via marketing | Med-High | Claims register + regulatory review of every user-facing string; train the growth team |
| **Child disengagement** | High | This is a game-design problem more than an ML problem. Budget accordingly. |
| Parent burden → churn | High | ≤1s per trial scoring; scoring optional; **app works with zero parent input** |
| iOS audio-stack changes between OS versions | Medium | Regression suite of recorded fixtures replayed through the DSP on **every OS beta** |

---

## 7. Cost drivers

1. **Content production** — modeling videos, stimulus art, SLP-authored programs. Usually underestimated; often the largest line item.
2. **SLP labelling labour** — a recurring COGS line ($60–120/hr; ~200–400 clips/hr with a good keyboard-driven review UI). Consider graduate-student partnerships.
3. **Compliance** — privacy counsel, DPIA, Safe Harbor, SOC 2, pen test, VPAT: **$150–350k over 18 months.**
4. **Infrastructure** — modest. Audio is the variable: ~1 MB per 30 s at 16 kHz/16-bit; use FLAC or Opus for 5–10× reduction. On-device-first + 90-day retention keeps this near-trivial.
5. **Clinical validation study** — $100–500k if we want efficacy claims and reimbursement.
