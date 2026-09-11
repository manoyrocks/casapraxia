# Clinician Portal Specification

## Overview

The Praxia clinician portal is the **second interface** after the child app. It is:

- **Asynchronous** — no live sessions, no pressure to respond immediately
- **Keyboard-driven** — optimized for efficiency (~2 min/child/week)
- **Review-focused** — ~10 clips/week sampled automatically
- **Escalation-focused** — stuck targets, safety stops, regression signals
- **HIPAA-compliant** — via SAML/OIDC SSO, audit log, encrypted transfer

---

## Three core workflows

### 1. Triage Queue

**Entry point.** Shows:
- Children with new safety stops
- Targets stuck >3 weeks
- High uncertainty clips (<70% confidence in last 5 attempts)
- SLP's weekly schedule vs. dose delivered

**Actions:**
- "Looks good" (dismiss)
- "Check this out" (review clip)
- "Change target" (retire + recommend new)
- "Message parent" (pre-filled templates)

### 2. Clip Review (Async Video)

**Core workflow.** For each clip:

| Element | Content |
|---------|---------|
| **Waveform + spectrogram** | Interactive, zoomable |
| **Play button** | Seamless audio playback |
| **Target info** | IPA, cue level applied, prior attempts |
| **Scoring buttons** | ✓ correct · ~ close · ✗ not yet (1-key shortcuts) |
| **IPA transcription** | Optional; defaults to model guess |
| **"Cue needed"** | Dropdown 0–5; routes to curriculum adjustment |
| **Prior attempts** | Thumbnail-like cards, click to compare waveform |

**Latency:** <200 ms per clip scoring.

**Gold standard:** ~50 clips/week (4 clips × 12–15 children).

### 3. Target Management

**Per-child view:**

- **Current targets** (ordered by recency)
  - Success rate (last 5 sessions)
  - Cue-level distribution (bar chart)
  - Estimated mastery date (if on track)
  - Safety stop status

- **Actions:**
  - Retire target → "Mastered" / "Try later" / "Replace"
  - Adjust session parameters (practice structure, feedback density)
  - Add new target (inventory-driven: only offer shapes at current+1)

- **Maintenance probe schedule** (read-only)
  - "Mastered 3 weeks ago → probe due in 1 week"
  - Click to view probe results

---

## Dashboard: The 10,000-foot view

**Clinician-level aggregate metrics** (NEVER shown to child or parent):

- **Caseload dosage** — children with ≥2 sessions/week vs. <2
- **Safety stop rate** — % of targets auto-retired (tuning signal)
- **Parent engagement** — % with any optional scoring in last 7 days
- **SLP review backlog** — clips pending review by age
- **Model agreement** — % clips where ML score ≠ SLP score (bias signal)

---

## Implementation notes

### Tech stack
- Next.js (App Router)
- TanStack Query for async state
- WaveSurfer.js for audio waveform/spectrogram
- Tailwind CSS + shadcn/ui
- SAML/OIDC via Auth0 or equivalent

### Accessibility
- Keyboard-first (all actions 1-key shortcuts)
- High-contrast mode
- Screen reader support (clips properly labeled)

### Audit & compliance
- Every action logged (who viewed what, when, score submitted)
- Audit trail exportable as CSV
- HIPAA Business Associate Agreement with hosting provider

### Constraints from §3
- **No claims** — SLP reviews clips, app does not "tell" them anything
- **No emotion inference** — portal focuses on acoustic measures, not psychological constructs
- **Model explainability** — every ML score links to its driving features

---

## Wireframe: Triage Queue

```
┌─────────────────────────────────────────────────────┐
│ Praxia Clinician                      [SLP name ▼]  │
├─────────────────────────────────────────────────────┤
│ Triage Queue                  [Filter by: issue ▼]  │
├─────────────────────────────────────────────────────┤
│                                                      │
│ SAFETY STOPS (1)                                    │
│ ├─ Maya T. (age 4) — "ba" retired (30% success)    │
│ │  └─ [Review]  [Dismiss]  [Message]               │
│                                                      │
│ STUCK TARGETS (3)                                   │
│ ├─ Aiden (age 5) — "up" stuck 4 weeks              │
│ │  Success: 15% / Expected: 50%                     │
│ │  └─ [Review clips]  [Change target]              │
│                                                      │
│ HIGH UNCERTAINTY (2)                                │
│ ├─ Zoe (age 3) — "ma" (5 clips, avg confidence 60%│
│ │  └─ [Review]  [Dismiss]                          │
│                                                      │
│ DOSE ALERT (0)                                      │
│ └─ All children on track this week                  │
│                                                      │
└─────────────────────────────────────────────────────┘
```

---

## Wireframe: Clip Review

```
┌──────────────────────────────────────────────────────┐
│ Clip Review: Maya T., "ba"            [1/10 this week]│
├──────────────────────────────────────────────────────┤
│                                                       │
│  Target: /bɑ/  ·  Cue: L1 (together, slow)           │
│                                                       │
│  ┌─ Waveform ───────────────────────────────────┐   │
│  │ ┌─────────────────────────────┐              │   │
│  │ │  [▶ Play]                   │              │   │
│  │ │    Spectrogram               │              │   │
│  │ │  ╱╲  ╱╲  ╱╲                  │              │   │
│  │ └─────────────────────────────┘              │   │
│  │  SNR: 14 dB  ·  Duration: 1.2s  ·  Loudness OK  │
│  └──────────────────────────────────────────────┘   │
│                                                       │
│  Prior attempts:                                     │
│  ├─ [2 days ago] Waveform similar, cleaner          │
│  └─ [5 days ago] Waveform noisier, shorter          │
│                                                       │
│  Score this attempt:                                 │
│  ┌─────────────────────────────────────────────┐   │
│  │ [✓] Correct      [~] Close      [✗] Not Yet │   │
│  └─────────────────────────────────────────────┘   │
│                                                       │
│  IPA (optional): │ba_ʰ │  [Model suggested: ba]     │
│  Cue needed:      │ 1  │ (currently 1) [–][-][+]    │
│                                                       │
│  [Next clip →]  [Mark uncertain]  [Save & close]    │
│                                                       │
└──────────────────────────────────────────────────────┘
```

---

## Shortcut keys

| Key | Action |
|-----|--------|
| `1` | Score: Correct |
| `2` | Score: Close |
| `3` | Score: Not Yet |
| `→` | Next clip |
| `←` | Previous clip |
| `?` | Show help |
| `esc` | Close & return to queue |

---

## Data schema (view layer)

```typescript
interface ClipForReview {
  trialID: string;
  childID: string;
  childName: string;
  childAge: number;
  targetID: string;
  targetName: string;
  ipaTranscription: string;
  cueLevel: 0 | 1 | 2 | 3 | 4 | 5;
  audioURL: string;  // Signed, short-lived
  waveformData: number[];
  spectrogramFreqs: number[];
  spectrogramTimes: number[];
  spectrogramDbFS: number[][];
  attemptDuration: number;
  snrDb: number;
  priorAttempts: {
    timestamp: Date;
    score: "correct" | "close" | "notYet";
    ipaTranscription?: string;
    waveformData?: number[];
  }[];
  modelConfidence?: number;  // 0–1, nullable if absent
}

interface ClipReviewSubmission {
  trialID: string;
  clinicianID: string;
  score: "correct" | "close" | "notYet";
  ipaTranscription?: string;
  cueNeeded?: 0 | 1 | 2 | 3 | 4 | 5;
  notes?: string;  // Rare, for edge cases
  confidence: "certain" | "uncertain";
  timestamp: Date;
}
```
