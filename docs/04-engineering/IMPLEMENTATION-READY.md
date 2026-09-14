# Implementation Ready Checklist

**Status:** ✅ Architecture Complete, Ready for Implementation  
**Date:** 2026-09-14  
**Coordinator:** Claude Code (Architect)

---

## Deliverables Completed

### Architecture & Design Documents

| Document | Status | Location | Purpose |
|----------|--------|----------|---------|
| System Architecture (16,000 words) | ✅ Complete | `docs/04-engineering/ARCHITECTURE.md` | Complete system design, service definitions, data model DDL, API contracts |
| Architecture Decision Records (8 ADRs) | ✅ Complete | `docs/04-engineering/ADRS.md` | Technology choices with rationale & alternatives |
| Architecture Summary (Quick Start) | ✅ Complete | `docs/04-engineering/ARCHITECTURE-SUMMARY.md` | 5-min overview for implementers |
| Protobuf Generation Guide | ✅ Complete | `docs/04-engineering/PROTOBUF-GENERATION.md` | Instructions to generate Swift & Go stubs |
| This Checklist | ✅ Complete | `docs/04-engineering/IMPLEMENTATION-READY.md` | Readiness verification |

### Proto Definitions (gRPC Interfaces)

| Proto File | Status | Location | Service |
|-----------|--------|----------|---------|
| trial.proto | ✅ Updated & Ready | `backend/protos/trial.proto` | TrialService (upload, query, progress) |
| config.proto | ✅ Updated & Ready | `backend/protos/config.proto` | ConfigService (programs, targets, AAC) |
| audio.proto | ✅ Updated & Ready | `backend/protos/audio.proto` | AudioService (presign, verify, status) |

**Key:** All three `.proto` files are production-ready with full message definitions, enums, and RPC method signatures.

### PostgreSQL Schema (DDL)

| Table | Status | DDL |
|-------|--------|-----|
| trial_events (append-only) | ✅ Complete | `ARCHITECTURE.md §3.1` |
| cue_state (LWW mutable) | ✅ Complete | `ARCHITECTURE.md §3.1` |
| scores (multi-rater) | ✅ Complete | `ARCHITECTURE.md §3.1` |
| sessions, children, targets, goals, etc. | ✅ Complete | `ARCHITECTURE.md §3.1` |
| audit_log (compliance) | ✅ Complete | `ARCHITECTURE.md §3.1` |

**Total:** 15 tables, 30+ indexes, ACID-transactional, FERPA-compliant.

---

## What's Ready for Implementation

### iOS Developer

**✅ Ready to implement from:**

1. **Protobuf definitions** (`backend/protos/*.proto`)
   - Complete gRPC service definitions for TrialService, ConfigService, AudioService
   - All message types with correct enumerations
   - Ready to generate Swift stubs (see PROTOBUF-GENERATION.md)

2. **Audio Pipeline Spec** (`ARCHITECTURE.md §7`)
   - Capture configuration (AVAudioSession .measurement mode, no AEC/AGC)
   - Tier-1 DSP requirements (syllable count, pitch, latency)
   - 150 ms latency budget allocation
   - Tier-1 signals message format

3. **State Machine Spec** (`ARCHITECTURE.md §8`)
   - Cue hierarchy: L0–L5 with 4 modality dimensions
   - Advancement rule (3-up), back-off rule (2-down), safety stop (<40% @ L0)
   - Property-based correctness constraints
   - Local SQLite schema for cue_state

4. **Sync Design** (`ARCHITECTURE.md §6`)
   - Offline-first architecture
   - Idempotent batch upload
   - Retry logic (exponential backoff 2^n × 2s, max 4 retries)
   - Local outbox pattern

5. **Critical Files Build Order** (`ARCHITECTURE.md §12`)
   - Phase 1 (Weeks 1–2): AudioCaptureManager, Rust DSP core, TrialEngine
   - Phase 2 (Weeks 2–3): TrialStore, SyncManager
   - Phase 3 (Week 3–4): UI (Talk, Play, Collection)
   - Phase 4 (Week 4): Fixtures & regression suite

### Backend Engineer (Go)

**✅ Ready to implement from:**

1. **Protobuf definitions** (`backend/protos/*.proto`)
   - Complete gRPC service definitions
   - All request/response message types
   - Ready to generate Go stubs (see PROTOBUF-GENERATION.md)

2. **Go Backend Architecture** (`ARCHITECTURE.md §2.2`)
   - Service layout: TrialService, ConfigService, AudioService
   - Module structure: pkg/trialsvc, pkg/configsvc, pkg/audiosvc, pkg/auth, pkg/store
   - Dependency injection pattern

3. **PostgreSQL Schema** (`ARCHITECTURE.md §3.1`)
   - Complete DDL (15 tables, 30+ indexes)
   - Ready to migrate (use `backend/migrations/`)
   - Append-only trial_events design
   - Optimistic concurrency for cue_state

4. **NATS JetStream Integration** (`ARCHITECTURE.md §2.3`)
   - Stream definitions (trial-scored, audio-upload-queue, training-pipeline)
   - Consumer configuration
   - Deduplication via trial_id composite key

5. **Critical Files Build Order** (`ARCHITECTURE.md §12`)
   - Phase 1 (Weeks 1–2): migrations, postgres.go, main.go
   - Phase 2 (Weeks 2–3): TrialService.UploadSession, trialsvc/ingest.go
   - Phase 3 (Week 3–4): ConfigService, AudioService
   - Phase 4 (Week 4): Audit logging, compliance endpoints

6. **Makefile Proto Generation** (`backend/Makefile`)
   - `make proto` — generate Go stubs
   - `make proto-clean` — remove generated files
   - `make proto-regen` — clean + regenerate

### Clinician Portal Engineer (Next.js)

**✅ Reference documents:**
- `docs/backend/clinician-portal-spec.md` (existing)
- `ARCHITECTURE.md §2.2` (AdminService RPC calls)
- `ADRS.md ADR-6` (async + synchronous response design)

---

## Pre-Build Checklist

### Environment Setup

- [ ] **iOS Dev:**
  - [ ] Xcode 15+
  - [ ] Swift 5.9+
  - [ ] CocoaPods or SPM
  - [ ] protoc >= 3.21.0 installed
  - [ ] swift-protobuf installed

- [ ] **Backend Dev:**
  - [ ] Go 1.25+ (or wait for 1.25.0 release for latest protobuf plugins)
  - [ ] protoc >= 3.21.0 installed
  - [ ] PostgreSQL 15+ local/Docker
  - [ ] NATS JetStream (docker run nats -js)
  - [ ] MinIO for S3-compatible storage

### Proto Code Generation

- [ ] **Backend:** Run `cd backend && make proto-regen` to generate Go stubs
  - Expected output: `pkg/gen/praxia/v1/{trial,config,audio}.pb.go` + gRPC service files
  - Commit generated files to repo

- [ ] **iOS:** Run proto generation (see PROTOBUF-GENERATION.md)
  - Expected output: `Sources/PraxiaChild/Generated/Praxia_*.pb.swift`
  - Commit generated files to repo

### Critical File Checklist (Build in This Order)

**Week 1:**

- [ ] iOS: `AudioCaptureManager.swift` with AVAudioSession setup
- [ ] iOS: `Tier1DSPCore.rs` (Rust DSP, vocalization + syllable + pitch)
- [ ] Backend: `protos/trial.proto` — gRPC definitions ✅ (done)
- [ ] Backend: `migrations/001_trial_events.sql` — PostgreSQL schema
- [ ] Backend: `cmd/server/main.go` — gRPC server bootstrap
- [ ] Backend: `pkg/store/postgres.go` — connection pool + basic queries

**Week 2:**

- [ ] iOS: `TrialEngine.swift` — state machine implementation
- [ ] iOS: `TrialStore.swift` — SQLite encryption + queries
- [ ] iOS: `SyncManager.swift` — outbox + retry logic
- [ ] Backend: `pkg/trialsvc/ingest.go` — UploadSession handler
- [ ] Backend: `pkg/trialsvc/event.go` — trial_events append logic

**Week 3:**

- [ ] iOS: UI layer (Talk, Play, Collection surfaces)
- [ ] iOS: Test audio latency on 3-year-old iPad (regression suite)
- [ ] Backend: `pkg/configsvc/loader.go` — Program + Target queries
- [ ] Backend: `pkg/audiosvc/presign.go` — S3 pre-signed URLs
- [ ] End-to-end test: upload → server → database

**Week 4:**

- [ ] iOS: AAC integration, parent scoring UI
- [ ] iOS: Recorded audio fixture regression suite (15 test cases)
- [ ] Backend: Audit logging implementation
- [ ] Backend: Compliance endpoints (retention, deletion, consent)
- [ ] Full integration test (sync workflow)

---

## Blockers & Dependencies

### No Blockers

✅ All architecture, specifications, and proto contracts are complete.  
✅ Both iOS and Backend can start implementation independently.  
✅ Proto files can be generated immediately (pending Go 1.25 for latest plugins).

### Known Constraints to Build Around

1. **Go Version for Protobuf Plugins**
   - Current environment: Go 1.24.7
   - Required: Go 1.25+ for latest protoc-gen-go-grpc
   - Workaround: Use older plugin version or wait for Go 1.25 release (late 2026?)
   - Recommendation: Manually generate proto stubs with available tools or use pre-built binaries

2. **Audio Latency Testing**
   - Requires actual iPad hardware (3+ years old)
   - Must measure on-device, not simulator
   - Budget: 150 ms vocalization → reinforcement
   - Plan: Use design-partner iPad during Phase 2 integration

3. **gRPC Swift Code Generation**
   - Requires grpc-swift compiler (more complex than simple protobuf)
   - iOS Dev can start with basic proto-generated Swift, add gRPC layer later
   - Reference: PROTOBUF-GENERATION.md for full setup

---

## Next Steps (Immediate)

### For Architect

1. **Approve this checklist** with Product/Clinical Advisory Board
2. **Stand by** for gRPC schema questions during implementation
3. **Pre-review** critical files (TrialEngine, AudioCaptureManager, TrialService.UploadSession)

### For iOS Developer

1. **Read:** ARCHITECTURE-SUMMARY.md (5 min) + ARCHITECTURE.md §2.1, §7 (30 min)
2. **Generate:** Swift protobuf stubs from trial.proto (see PROTOBUF-GENERATION.md)
3. **Start:** AudioCaptureManager.swift (Week 1, Phase 1)

### For Backend Engineer

1. **Read:** ARCHITECTURE-SUMMARY.md (5 min) + ARCHITECTURE.md §2.2, §3.1 (30 min)
2. **Generate:** Go protobuf stubs from *.proto files (make proto-regen, pending Go 1.25)
3. **Start:** PostgreSQL migrations + cmd/server/main.go (Week 1, Phase 1)

### For Clinician Portal Engineer

1. **Read:** clinician-portal-spec.md (existing)
2. **Reference:** ARCHITECTURE.md §2.2 for AdminService RPC calls
3. **Wait:** Backend service stubs + approval to start (Week 2)

---

## Success Criteria (v1 Validation)

From UNIFIED-BUILD-PROMPT §7:

- [ ] 10 design-partner families practising ≥2×/week for 4 weeks
- [ ] ≥3 clinicians using portal weekly (within 2-min/client budget)
- [ ] Median 60+ trials per practice session
- [ ] Day-10 before/after clip delivered to every active family
- [ ] **Zero child-visible failure states** (independent audit)
- [ ] **Zero machine accuracy scores** anywhere in build
- [ ] Full practice loop verified offline (airplane mode)
- [ ] ≤150 ms reinforcement latency verified on 3yr-old iPad
- [ ] WCAG 2.2 AA conformance; VPAT drafted; Switch Control verified
- [ ] Every string passed through claims register
- [ ] Layered consent; training toggle independent; deletion jobs verified
- [ ] Fixture regression suite green on current iOS beta
- [ ] No third-party analytics/ads/attribution SDK in child target

---

## Document Map (For Reference)

```
docs/04-engineering/
├── ARCHITECTURE.md                    ← Main spec (16,000 words)
├── ARCHITECTURE-SUMMARY.md            ← 5-min quick start
├── ADRS.md                            ← 8 decision records
├── PROTOBUF-GENERATION.md             ← How to generate stubs
├── IMPLEMENTATION-READY.md            ← This file
├── data-model-and-events.md           ← Existing (referenced)
├── speech-signal-spec.md              ← Existing (referenced)
└── technical-architecture.md          ← Existing (referenced)

docs/02-product/
├── clinical-program-spec.md           ← DTTC hierarchy
└── prd.md                             ← Product requirements

docs/08-prompts/
└── UNIFIED-BUILD-PROMPT.md            ← §1–§5 are inviolable
```

---

## Architect Contact & Escalation

**Architect available for:**
- gRPC message definition questions
- Protobuf version/import path clarifications
- PostgreSQL schema edge cases
- Data model conflicts (e.g., multi-child devices)
- Latency/performance trade-offs
- Follow-up ADRs (Phase 2, Android, ML pipeline)

**Do NOT ship without architect sign-off on:**
- Any change to Inviolable Constraints (§3)
- Trial event immutability (append-only enforcement)
- Safety stop logic (automated retirement)
- Consent enforcement (all 6 purposes)
- Audit logging (FERPA compliance)

---

## Sign-Off

**Architect:** Claude Code  
**Date:** 2026-09-14  
**Status:** ✅ **READY FOR BUILD**

All deliverables complete. iOS Developer and Backend Engineer can begin implementation immediately. Protobuf stubs can be generated. No architectural blockers.

**Next review:** After Week 1 Phase completion (audio capture + Tier-1 DSP foundation).

---

**Questions?** Ask the architect. This is your complete reference for building Praxia v1.
