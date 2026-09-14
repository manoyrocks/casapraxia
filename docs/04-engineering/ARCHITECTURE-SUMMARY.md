# Praxia System Architecture — Quick Start for Implementers

**Status:** Ready to build  
**Document:** Start here before reading ARCHITECTURE.md  
**Duration:** 5 minutes

---

## The 30-Second Version

Praxia is a native iOS speech-practice app that:

1. **Captures audio locally** (16 kHz mono, no AEC/AGC)
2. **Computes Tier-1 DSP signals on-device** (vocalization, latency, syllable count, pitch) in <150 ms
3. **Stores trials locally** in encrypted SQLite
4. **Syncs batches offline-first** to a Go backend when WiFi is available
5. **Persists immutably** to PostgreSQL (append-only trial_events table)
6. **Uploads audio to S3** (with consent)
7. **Never computes machine accuracy scores** (parent taps 3-way: got it / close / not yet)

**All of this works completely offline. The critical path (audio capture → reinforcement) never touches the network.**

---

## Tech Stack at a Glance

| Component | Technology | Why |
|-----------|-----------|-----|
| iOS client | Swift + SwiftUI | Audio subsystem control, latency < 150 ms, accessibility |
| Tier-1 DSP | Rust (static lib) | Performance, portability, type safety |
| Backend | Go + gRPC | Small team, fast iteration, Kubernetes-native |
| Database | PostgreSQL | ACID, audit trail, event sourcing |
| Work queue | NATS JetStream | Simplicity, self-hosted, deduplication |
| Audio storage | S3 (encrypted) | Scalable, compliance-friendly, lifecycle policies |
| Local store | SQLite (encrypted) | On-device, offline-first |

---

## Architecture Diagram (Text)

```
┌─ iOS Client ────────────────────────┐
│                                      │
│  [Audio Capture] → [Tier-1 DSP]     │
│       ↓                              │
│  [SQLite Local Store] (encrypted)   │
│       ↓                              │
│  [Sync Outbox] (batched)            │
│       ↓                              │
└──────┼──────────────────────────────┘
       │
   gRPC/HTTPS (sync on WiFi)
       │
       ▼
┌─ Go Backend ────────────────────────┐
│                                      │
│  [TrialService.UploadSession]       │
│       ↓                              │
│  [Validate] → [Persist to PG]       │
│       ↓                              │
│  [Emit to NATS]                     │
│       ↓                              │
└──────┼──────────────────────────────┘
       │
       ├─ [PostgreSQL] trial_events (immutable log)
       ├─ [NATS] audio-upload queue
       └─ [S3] audio storage (encrypted per-tenant)
```

---

## Critical Constraints (The Inviolable Rules)

**From UNIFIED-BUILD-PROMPT §3 — implement these or reject the feature:**

1. ✅ No machine verdict reaches the child (ever)
2. ✅ No failure states in child experience (red X, buzzer, timer)
3. ✅ Back-off is silent (no child-visible signal)
4. ✅ Safety stop fires @ <40% accuracy over 10 trials @ L0 → auto-retire target
5. ✅ Audio capture: 16 kHz mono, `.measurement` mode, AEC/AGC OFF
6. ✅ ≤150 ms vocalization → reinforcement (measured on real iPad)
7. ✅ Trial log is append-only, immutable, never updated
8. ✅ Offline-first: entire practice loop works without network
9. ✅ No third-party analytics/ads/attribution SDK in child target

If a requirement conflicts with these, stop and escalate.

---

## Build Order (Do This)

**Week 1–2: Foundation**
1. Write `protos/trial.proto` (message definitions)
2. Write PostgreSQL schema (`migrations/001_trial_events.sql`)
3. Implement `AudioCaptureManager.swift` (audio setup)
4. Implement Rust Tier-1 DSP core (`scoring/src/lib.rs`)
5. Implement `TrialEngine.swift` (state machine)

**Week 2–3: Server Integration**
6. Implement `TrialService.UploadSession` handler (Go)
7. Implement `TrialStore.swift` (local SQLite)
8. Implement `SyncManager.swift` (batch upload + retry)

**Week 3–4: Features**
9. Implement UI (Talk, Play, Collection surfaces)
10. Implement clinician portal (Next.js, separate from iOS)
11. Add audit logging and consent enforcement

**Week 4: Validation**
12. Fixture regression suite (recorded audio test cases)
13. End-to-end sync test (upload → server → NATS → S3)
14. Load test (simulate 1000 concurrent iOS uploads)

---

## The Data Model — Three Tables You Must Understand

### 1. trial_events (Append-Only Log)

```sql
CREATE TABLE trial_events (
  event_id CHAR(26) PRIMARY KEY,      -- UUIDv7
  trial_id UUID NOT NULL,             -- composite key with child_id, session_id
  child_id CHAR(21) NOT NULL,         -- pseudonymous
  event_type TEXT NOT NULL,           -- "stimulus_presented", "attempt_recorded", "cue_advanced", etc.
  cue_level TEXT,                     -- "L0" through "L5"
  payload JSONB,                      -- event-specific data
  server_ts TIMESTAMP DEFAULT NOW(),  -- append timestamp
  -- IMMUTABLE: no UPDATE, no DELETE
);
```

**Key property:** Every row is inserted once. Corrections are logged as new events. This creates a complete audit trail.

### 2. cue_state (Mutable, LWW)

```sql
CREATE TABLE cue_state (
  child_id CHAR(21),
  target_id UUID,
  current_level TEXT,                 -- "L0" to "L5", the active cue level
  consecutive_accurate INT,           -- for advancement
  consecutive_inaccurate INT,         -- for back-off
  version INT,                        -- optimistic concurrency
  PRIMARY KEY (child_id, target_id)
);
```

**Key property:** This table is mutable (state changes). Updated via optimistic concurrency (check version before UPDATE). If version mismatch, client backs off and re-fetches.

### 3. scores (Multi-Rater)

```sql
CREATE TABLE scores (
  score_id UUID PRIMARY KEY,
  trial_id UUID,
  rater TEXT,                         -- "parent" | "slp" | "model:v1.2"
  value TEXT,                         -- "got_it" | "close" | "not_yet" | "abstain"
  confidence FLOAT,
  UNIQUE (trial_id, rater)            -- one score per trial per rater
);
```

**Key property:** Multiple rows per trial, keyed by rater. Parent score is the ground truth in v1. Machine score (v1.5+) is a hint visible to clinician only.

---

## The State Machine (Cue Hierarchy)

**Per-target, per-child:**

```
ADVANCE (3-up): 3 consecutive "got_it" → level++
BACK_OFF (2-down): 2 consecutive "close"/"not_yet" → level--, silently
SAFETY_STOP: < 40% accuracy over 10 trials @ L0 → retire target, no child signal

Rule: Back-off never crosses below L0. Level never advances past L5.
Proof needed: property-based tests that verify:
  1. No path leaves child failing repeatedly
  2. Safety stop always fires
  3. Back-off never emits child-visible event
```

**Critical:** iOS app stores cue_state locally; server pushes updates. If server backs off due to poor performance, iOS never learns about it (silent on device). Next session, iOS fetches fresh cue_state and continues at the backed-off level.

---

## Sync Design — How Offline-First Works

**Scenario: Parent practices with no WiFi**

```
1. iOS captures trial → persists to SQLite
2. iOS computes Tier-1 signals locally (Rust DSP)
3. iOS queues trial to sync_outbox table
4. [No network call here]
5. When WiFi detected (or bedtime charging), iOS batches trials
6. iOS POSTs to backend: UploadSession(device_id, session_id, trials[])
7. Backend validates:
   - (trial_id, device_id) not in DB already? (idempotency)
   - child_id matches auth token?
   - all field types correct?
8. Backend appends to trial_events (atomic transaction)
9. Backend publishes to NATS: "audio-upload-queue.child_123"
10. Backend returns 202 Accepted
11. iOS marks trials synced in SQLite; deletes outbox row
```

**Key: Trial is recorded locally before attempting upload. Upload is "nice to have"; practice loop doesn't wait for it.**

---

## Audio Pipeline — The 150 ms Budget

**Total: <150 ms from vocalization onset to reinforcement rendered**

| Stage | Budget | Actual |
|-------|--------|--------|
| Audio capture → ring buffer | 10 ms | ~5 ms |
| Vocalization detection (Silero VAD) | 30 ms | ~20 ms |
| Tier-1 signals (syllable, pitch) | 50 ms | ~30 ms |
| App logic (state machine, UI) | 40 ms | ~20 ms |
| UI rendering (SwiftUI) | 20 ms | ~15 ms |
| **Total** | **150 ms** | **~90 ms** ✓ |

**Validation:** Must measure on a 3-year-old iPad. If latency exceeds 150 ms, back off DSP quality (abstract Tier-1 signals that consume less CPU).

---

## API Contracts (gRPC — Start Here)

**Three services the iOS client calls:**

### TrialService

```protobuf
rpc UploadSession(UploadSessionRequest) returns (UploadSessionResponse);
  Input:  { device_id, session_id, trial_events[], audio_urls[] }
  Output: { accepted_count, error_count, retry_after_ms }
```

### ConfigService

```protobuf
rpc GetProgram(GetProgramRequest) returns (Program);
  Input:  { program_id }
  Output: { cue_hierarchy, advancement_rules, trial_target, ... }
  
rpc GetTargets(GetTargetsRequest) returns (GetTargetsResponse);
  Input:  { program_id }
  Output: { targets[] with IPA, syllable_shape, image_url, model_audio_url }
```

### AudioService

```protobuf
rpc PresignAudioUpload(PresignAudioUploadRequest) returns (PresignAudioUploadResponse);
  Input:  { child_id, attempt_id, content_length, checksum }
  Output: { s3_url, expiry_seconds }
  
rpc VerifyAudioUpload(VerifyAudioUploadRequest) returns (VerifyAudioUploadResponse);
  Input:  { child_id, attempt_id, checksum }
  Output: { verified }
```

**Full protobuf definitions:** See `ARCHITECTURE.md § 5`.

---

## Key Decision Records

**Eight ADRs document why we chose this stack:**

1. **Native Swift (not React Native)** — audio subsystem control
2. **Go backend (not Rust, not Node)** — small team, fast iteration
3. **PostgreSQL (not DynamoDB)** — ACID, immutability, audit trail
4. **NATS JetStream (not Kafka)** — simplicity, self-hosted
5. **S3 with on-device default** — scalable, compliant, privacy-first
6. **Hybrid sync (sync persist + async Tier-2)** — low critical-path latency
7. **Rust Tier-1 DSP (not Python)** — portability to iOS + backend
8. **On-device Tier-2 only (no cloud Tier-2 in v1.5)** — privacy, fast to market

**See `ADRS.md` for full reasoning and alternatives considered.**

---

## Deployment Checklist

**Before shipping v1:**

- [ ] Recorded audio fixture regression suite passes on current iOS beta
- [ ] gRPC latency measured on 3-year-old iPad: ≤150 ms critical path
- [ ] Sync retry tested with packet loss (5%, 10%, 50%)
- [ ] Audit log verified (all data access logged)
- [ ] S3 lifecycle policy in place (delete after 90 days)
- [ ] PostgreSQL PITR backup running (test restore)
- [ ] Consent enforcement in code review (no training data without consent toggle)
- [ ] Zero child-visible failure states in automated scan
- [ ] VPAT draft (WCAG 2.2 AA, Switch Control verified)
- [ ] No third-party SDKs in child target (grep verified)

---

## Questions for the Architect (Before Coding)

Before you start, confirm these design points:

1. **gRPC versioning:** How do we handle iOS app updates? (Answer: service version in URL; v1 forever in v1.0, v2 only in v2.0)

2. **Audio encoding:** Opus VBR 8–24 kbps or fixed 16 kbps? (Answer: VBR, adapts to SNR)

3. **Cue modality fading:** Can visual cue stay on while gestural fades? (Answer: yes, four independent dimensions)

4. **Parent score trust:** Do we require SLP override on >10% parent/SLP disagreement? (Answer: no, log it for training; SLP has final override)

5. **Multi-child devices:** Shared iPad with multiple kids (different child_ids)? (Answer: yes, session chooses child; trials tagged with child_id)

6. **Offline updates:** Clinician retires a target on the portal; iOS offline? (Answer: iOS fetches fresh config on next sync; continues with old config meanwhile)

---

## Success Criteria (Definition of Done for v1)

```
✅ 10 design-partner families practising ≥2×/week for 4 weeks
✅ ≥3 clinicians using portal, within 2-min/client budget
✅ Median 60+ trials per practice session
✅ Day-10 before/after clip delivered to every active family
✅ Zero child-visible failure states (independent audit)
✅ Zero machine accuracy scores anywhere in build
✅ Full practice loop verified offline (airplane mode)
✅ ≤150 ms reinforcement latency on 3yr-old iPad
✅ WCAG 2.2 AA; Switch Control verified; VPAT drafted
✅ Every string passed through claims register
✅ Layered consent; training toggle independent; deletion jobs verified
✅ Fixture regression suite green on current iOS beta
✅ No third-party analytics/ads/attribution in child target
```

---

## Reading Order

1. **This document** (5 min) — overview
2. **`ADRS.md`** (20 min) — why we chose this tech
3. **`ARCHITECTURE.md`** (60 min) — detailed design, full DDL, gRPC definitions
4. **`UNIFIED-BUILD-PROMPT.md` §1–§5** (30 min) — constraints and mission

**Then:**
- iOS Dev: start with `ARCHITECTURE.md §2.1` (iOS architecture)
- Backend Dev: start with `ARCHITECTURE.md §2.2` (Go backend)
- Both: implement from `ARCHITECTURE.md §12` (critical files in order)

---

## Contact & Escalation

**Architect standing by for:**
- gRPC schema questions
- Data model edge cases
- Protobuf versioning strategy
- Edge case decisions (multi-child devices, offline config updates, etc.)
- Follow-up ADRs (phase 2 roadmap, ML pipeline, Android portability)

---

**Built by:** Claude Code (Architect)  
**Date:** 2026-09-14  
**Status:** Ready for implementation
