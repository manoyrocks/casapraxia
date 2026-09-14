# Architecture Decision Records (ADRs)

---

## ADR-1: Native Swift/SwiftUI for iOS Child Client

**Status:** DECIDED (CR-2)  
**Date:** 2026-09-14  
**Stakeholders:** iOS Developer, Architect, Clinical Advisory Board

### Context

The iOS child client must capture audio at a precise technical specification (16 kHz mono, AVAudioSession `.measurement` mode, AEC/AGC disabled) to preserve amplitude and spectral validity for Tier-1 DSP. Cross-platform frameworks (React Native, Flutter, Xamarin) do not expose these audio subsystem controls reliably—their audio plugins silently re-enable voice-processing I/O by default and cannot be reliably turned off by application code.

Additionally, the app must achieve ≤150 ms latency from vocalization onset to child reinforcement. Java/Kotlin runtime overhead and cross-platform bridge latency make this tight budget difficult to meet on older iPads.

Finally, the app must support advanced accessibility features (Switch Control, Guided Access) that are deeply integrated into iOS and not well-exposed through cross-platform layers.

**Alternatives considered:**
- React Native (performance concern; audio subsystem inaccessibility)
- Flutter (same audio subsystem issue; smaller community for a11y edge cases)
- Xamarin (deprecated by Microsoft; audio same issue)
- Web (Electron or web client for iOS?)

### Decision

**Use native Swift/SwiftUI for iOS only (v1).**

- Audio capture: `AVAudioSession(.measurement)` with direct AEC/AGC disable
- UI framework: SwiftUI (declarative, modern)
- Accessibility: direct integration with UIAccessibility, Switch Control, Guided Access
- Tier-1 DSP core: Rust (via FFI) for audio signal processing

**Non-negotiable constraints (inviolable):**
- Audio sample rate: 16 kHz mono
- Session mode: `.measurement` (not `.default` or `.spokenAudioAndVideo`)
- All voice-processing disabled explicitly
- ≤150 ms latency on a 3-year-old iPad (must measure on hardware)

### Rationale

1. **Audio fidelity is the core of the product.** Without valid acoustic measures, Tier-1 signals are invalid, and the entire dosage advantage (attempt counting) disappears. Native iOS is the only safe choice.

2. **Latency is hard. A 50 ms miss converts to child waiting → attention loss → aversion.** Native Swift compiles to machine code; Rust DSP core via static library adds <5 ms overhead (measured). Cross-platform frameworks typically add 30–100 ms.

3. **The target population (children, parents, SLPs) is predominantly iPad-owning in the US.** Android is a Phase 2/3 decision after the Rust scoring core is portable.

4. **Accessibility is a legal requirement and a moral one.** Children with severe CAS often have co-occurring motor differences. Switch Control and Guided Access are iOS features not reliably available through cross-platform layers.

### Consequences

**Positive:**
- Precise control over audio stack
- No third-party SDK surprises (audio plugins silently re-enabling processing)
- Direct access to Core ML, ANE (future Tier-2 models)
- Accessibility features fully testable

**Negative:**
- No Android in v1 (school channel is Phase 3)
- Smaller developer pool for iOS specialization (mitigated by hiring)
- Device testing must include older iPad models (procurement cost)

### Compliance & Safety

- No audio-stack surprise on iOS OS updates (rare, but we audit every beta)
- Accessibility compliance: WCAG 2.2 AA with Switch Control testing in CI
- No third-party SDKs in child target (enforced in code review)

---

## ADR-2: Go + gRPC for Backend Services

**Status:** DECIDED  
**Date:** 2026-09-14  
**Stakeholders:** Backend Engineer, Architect, DevOps

### Context

The backend must handle three critical tasks: synchronous trial ingest (hot path, < 2s response time), asynchronous audio upload coordination (cold path), and config distribution (cached, rarely changes). The system must be deployable to Kubernetes, maintainable by a small team, and efficient with resources (low latency, predictable memory).

**Alternatives considered:**
- TypeScript/Node.js with NestJS
- Rust (Actix-web or Axum)
- Python (FastAPI)
- Java (Spring Boot)

### Decision

**Go + gRPC for core services. REST endpoints for clinician portal only (via gRPC gateway or separate service).**

**Technology stack:**
- gRPC for iOS ↔ Backend (TrialService, ConfigService, AudioService)
- Protocol Buffers v3 for message definitions
- Go standard library for HTTP, database/sql
- PostgreSQL for persistence
- NATS JetStream for work queue

**Rationale:**

1. **gRPC over REST:** iOS clients make many synchronous RPC calls (UploadSession, GetProgram, GetTargets). gRPC's binary framing and HTTP/2 multiplexing reduce latency and bandwidth. REST with repeated JSON serialization/deserialization adds 5–10 ms per call. On a slow network, gRPC's HPACK header compression is significant.

2. **Go advantages:**
   - **Fast compilation:** go build is <5s (vs Rust 30s, Java 60s). CI/CD cycle matters.
   - **Concurrency model:** goroutines are lightweight; trivial to handle 1000s of concurrent uploads.
   - **Memory efficiency:** typical Go binary is 10–50 MB. Rust binaries are similar; Java is 500 MB+.
   - **Production-proven:** Kubernetes, Docker, NATS, and myriad infrastructure projects are written in Go. Team familiarity is higher.
   - **Simplicity:** Go's opinionated design (no generics until 1.18, limited polymorphism) prevents over-engineering.

3. **Why not Rust?**
   - Rust is safer and faster, but the performance difference (10–20% in microbenchmarks) doesn't matter here—I/O (database, S3) is the bottleneck.
   - Rust's learning curve is steep; bug-fix velocity in Rust is slower for a small team.
   - The only Rust in the system is the DSP core (Tier-1 signals), which is already isolated.

4. **Why not TypeScript/Node.js?**
   - Node.js has higher memory overhead and less predictable garbage collection (problematic on Kubernetes memory limits).
   - Single-threaded event loop means CPU-bound tasks (data validation, checksum verification) can block.
   - Type safety is weaker than Go (TypeScript is unsound for some module edge cases).

### Consequences

**Positive:**
- Fast iteration and debugging
- Predictable resource usage (easy to right-size Kubernetes resources)
- Native gRPC tooling (protoc, grpcurl)
- Excellent observability (Prometheus metrics are idiomatic in Go)

**Negative:**
- Go lacks a sophisticated ORM (go-sqlc, sqlc are code-gen, not reflective like Hibernate)
  - Mitigation: use raw SQL with prepared statements; write hand-crafted queries
- Error handling boilerplate (go's `if err != nil` is verbose)
- Smaller community in healthcare/medical SaaS than Java/C#

### Compliance & Deployment

- Cloud-native: trivial containerization (single binary, no runtime dependencies)
- gRPC gateway can translate REST requests to gRPC (for clinician portal) if needed
- Kubernetes: native support; Helm charts for Go microservices are well-established

---

## ADR-3: PostgreSQL Event Sourcing vs. DynamoDB vs. Cassandra

**Status:** DECIDED (CR-3 implicit)  
**Date:** 2026-09-14  
**Stakeholders:** Architect, Data Engineer, Compliance

### Context

The trial log must be immutable, append-only, and ACID-transactional. Every trial event must be recorded exactly once, in order, without gaps or modifications. This is both a clinical requirement (reproducibility) and a regulatory one (FERPA audit trail).

DynamoDB and Cassandra scale horizontally but lack strong transactionality guarantees required for medical records. PostgreSQL is battle-tested, ACID-compliant, and has mature tooling for backup/recovery.

**Alternatives considered:**
- DynamoDB (eventually consistent; hard to reason about correctness for medical data)
- Cassandra (distributed but eventual consistency; partition tolerance > consistency)
- Firestore (Google's NoSQL; similar eventual consistency concerns)
- MongoDB (ACID transactions added in v4, but still eventual at scale; backup complexity in healthcare)

### Decision

**PostgreSQL for the main data store.** Event sourcing pattern applied to trial_events (append-only, immutable).

**Schema strategy:**
- trial_events: never UPDATE or DELETE; only INSERT (immutable log)
- Derived tables (cue_state, session_progress): computed from trial_events on read; can be reset if corruption is detected
- Backup: point-in-time recovery (PITR) via continuous WAL archiving to S3
- Retention: trial_events kept indefinitely (research value); raw audio deleted after 90 days

**Instance size:** AWS RDS Multi-AZ, 2vCPU/8GB RAM baseline; auto-scale CPU/storage.

### Rationale

1. **ACID guarantees:** Trial events are written in a single transaction (all-or-nothing). If a write fails, the app retries; no partially-recorded trials.

2. **Audit trail:** PostgreSQL audit logging + an explicit audit_log table means every data access and modification is timestamped and logged. Required for FERPA compliance.

3. **Replayability:** Event sourcing means any trial session can be replayed from the log. This is critical for validating Tier-2 model changes against historical data.

4. **Operational maturity:** PostgreSQL is ubiquitous in healthcare. RDS is familiar to most DevOps teams. Backup/recovery procedures are well-documented.

5. **Cost:** PostgreSQL is open-source; RDS is cheaper than DynamoDB for this access pattern (mostly reads of historical data, bursty writes during practice sessions).

### Consequences

**Positive:**
- Strong consistency guarantees
- Audit trail is durable and queryable
- Scalability to millions of trials (historical records grow slowly)
- Mature backup and recovery tooling

**Negative:**
- Vertical scaling (bigger RDS instance) rather than horizontal sharding
  - Mitigation: trial_events table can be partitioned by date if it grows very large (multi-year retention)
- Single point of failure (mitigated by RDS Multi-AZ and backups)
- Write-heavy workloads (thousands of trials per minute) may need read replicas
  - Mitigation: background workers read from replicas; analytics queries use read replicas

### Compliance & Performance

- **HIPAA:** RDS encryption at rest and in transit, audit logging ✓
- **FERPA:** Immutable audit trail, retention controls ✓
- **GDPR:** Point-in-time recovery for right-to-be-forgotten ✓
- **Latency:** Trial event inserts are sub-millisecond (single row, indexed primary key)

---

## ADR-4: NATS JetStream vs. Kafka vs. AWS SQS

**Status:** DECIDED  
**Date:** 2026-09-14  
**Stakeholders:** Backend Engineer, DevOps, Architect

### Context

Audio upload, Tier-2 scoring, and training-data pipeline are asynchronous tasks decoupled from the critical path (trial ingest). The queue must:
- Guarantee at-least-once delivery
- Allow deduplication via message key (trial_id prevents re-processing)
- Support long-running consumers (async SLP review can queue for hours)
- Avoid external dependencies (easier to self-host for early-stage product)

**Alternatives considered:**
- Apache Kafka (mature, high throughput, complex to operate)
- AWS SQS (simple, serverless, but no ordering guarantees per message)
- AWS SNS + SQS (fan-out pattern, but SNS is PubSub only)
- RabbitMQ (durable, complex, heavier memory footprint)

### Decision

**NATS JetStream (embedded, self-hosted or managed).**

**Topology:**
- NATS cluster: 3 nodes for high availability
- JetStream: persistent stream storage with replication
- Consumers: auto-acknowledge on successful processing (at-least-once)
- Deduplication: trial_id as natural key in PostgreSQL prevents duplicates

**Streams:**
- `trial-scored.{child_id}`: published by TrialService after UploadSession
- `audio-upload-queue.{child_id}`: work queue for S3 uploader
- `training-pipeline.{tenant_id}`: training data feed (consumer_mode only)

### Rationale

1. **Simplicity:** NATS JetStream is a single Go binary (nats-server). No Zookeeper, no broker nodes, no complex configuration. Kubernetes StatefulSet with 3 replicas.

2. **No external dependencies:** Self-hosted means no AWS SQS cost or vendor lock-in. Suitable for early-stage product (may migrate to managed NATS later).

3. **Deduplication:** JetStream's message deduplication window (configurable, default 2 minutes) + PostgreSQL UNIQUE constraint prevents duplicate processing.

4. **Ordering:** Subjects partition by child_id, so all events for a child are processed in order. No head-of-queue blocking.

5. **Consumer groups:** JetStream consumers can be restarted; they resume from the last acked message. Suitable for long-running SLP review tasks.

### Consequences

**Positive:**
- Operational simplicity (one binary, Kubernetes-native)
- Deduplication built-in
- Ordering guarantees per subject
- Low latency (in-memory, no external I/O unless persisted to disk)

**Negative:**
- Less battle-tested at massive scale than Kafka (but sufficient for this product)
- Memory footprint grows with stream depth (mitigated by bounded retention policy)
- If all 3 nodes go down, stream data is lost unless backed up

### Deployment & Compliance

- **Self-hosted:** NATS cluster StatefulSet with 3 replicas, PersistentVolumes for state
- **Backup:** daily snapshot of JetStream state to S3 (not required for compliance, but good practice)
- **Audit:** all NATS messages logged to audit_log (server-side, on successful processing)

---

## ADR-5: S3 vs. On-Premise Storage for Audio

**Status:** DECIDED (CR-4 implicit)  
**Date:** 2026-09-14  
**Stakeholders:** Architect, DevOps, Compliance

### Context

Raw audio must be retained for 90 days (on-device by default, uploaded only if consented). After 90 days, audio is deleted to minimize COPPA/GDPR exposure. Uploaded audio is encrypted per-tenant and accessed by clinicians during async review.

**Alternatives considered:**
- On-premise NAS (requires provisioning, backup, compliance responsibility)
- S3 (scalable, compliance-friendly, cost-efficient for retention policy)
- Azure Blob Storage (similar to S3)
- GCP Cloud Storage (similar to S3)
- Minimal Media (legacy, not suitable)

### Decision

**AWS S3 for cloud-stored audio. On-device local storage (encrypted with NSFileProtectionComplete) is the default.**

**Storage architecture:**
- **On-device (default):** Opus-encoded, encrypted with SQLCipher key
  - Retention: 90 days (user-configurable, min 1 day)
  - Deletion: automatic on expiry (background task on device)
  - No consent required (local-only data)

- **S3 (if consented):**
  - Bucket: `praxia-audio-{tenant_id}`
  - Per-tenant KMS encryption key (AWS SSE-KMS)
  - Versioning enabled (protects against accidental deletions)
  - Lifecycle policy: delete after 90 days (unless marked keepsake)
  - Access: pre-signed URLs (15-min expiry) for clinician download
  - Audit: CloudTrail logs all S3 access (who, when, which file)

**Deletion workflow:**
```
Trial uploaded → 90 days elapse → cleanup-job queries DELETE FROM attempt_recordings WHERE retention_expires_at < NOW()
  ↓
S3 delete object → audit_log entry → deletion_receipt generated
  ↓
Parent can download receipt (proof of deletion)
```

### Rationale

1. **Scalability:** S3 handles millions of files without operational burden. NAS requires provisioning and backup.

2. **Compliance-friendly:**
   - S3 encryption (KMS) is HIPAA/GDPR-compliant
   - Lifecycle policies are transparent and auditable
   - CloudTrail logging satisfies FERPA access logging
   - Deletion is verifiable (S3 API return codes + audit logs)

3. **Cost-efficient:** S3 Standard is ~$0.023/GB/month. 1000 children × 20 sessions/month × 5 minutes/session × 0.05 MB/sec = ~1.5 TB/month, ~$40/month. Negligible.

4. **On-device default:** Minimizes cloud exposure. Audio stays local unless parent explicitly consents to clinician review or training.

### Consequences

**Positive:**
- Scalable, no operational overhead
- Compliant with HIPAA, GDPR, FERPA
- Flexible retention policies (lifecycle rules)
- Audit trail (CloudTrail)

**Negative:**
- AWS account required (not an issue for any production app)
- S3 regional latency (if clinician downloads from distant region)
  - Mitigated: use CloudFront CDN for downloads (cheap, sub-second latency)

### Compliance & Security

- **HIPAA:** S3 encryption + CloudTrail ✓
- **FERPA:** Access audit log visible to parent ✓
- **GDPR:** Right to delete (lifecycle policy automates this); right to access (signed URLs) ✓
- **COPPA:** Minimal PII exposure (encrypted at rest, deleted after 90 days) ✓

---

## ADR-6: Synchronous gRPC vs. Async Event-Driven for Trial Upload

**Status:** DECIDED  
**Date:** 2026-09-14  
**Stakeholders:** Architect, Backend Engineer, iOS Developer

### Context

When the iOS app uploads a batch of trials (typically 60–80 trials in one upload), the backend must:
1. Validate the batch (check for duplicates, correct child_id ownership, etc.)
2. Persist immutably to PostgreSQL
3. Compute Tier-1 signal metrics
4. Emit to NATS for async Tier-2 scoring (v1.5) and audio upload
5. Return a response to the client

The question is: should the response wait for all async tasks to complete (Tier-2 scoring, S3 upload), or return immediately after persistence?

**Alternatives considered:**
- Synchronous: wait for Tier-2 scoring before responding (worst case, 5–10 seconds)
- Async: return 202 Accepted immediately; emit to NATS; client polls for completion
- Hybrid: return 200 with trial_ids that were persisted; async tasks happen in background

### Decision

**Hybrid: Synchronous persistence + async tasks.**

**Behavior:**
```
iOS POST UploadSession(trials, audio_urls)
  ↓
Backend validates, appends to trial_events (ACID transaction)
  ↓
Backend publishes to NATS streams (audio-upload, trial-scored)
  ↓
Backend returns 202 Accepted with { accepted_count, error_count, retry_after_ms }
  ↓
(Async: NATS consumer processes audio, emits S3 upload job)
```

**Critical path:** Validation + persistence + NATS publish: <500 ms.

**Non-critical path:** S3 upload, Tier-2 scoring: happens asynchronously, no client blocking.

### Rationale

1. **Latency:** iOS cannot afford to wait 5–10 seconds for a Tier-2 scoring result. Return immediately; client moves on to next session.

2. **Reliability:** If Tier-2 scoring fails, the trial is already persisted. Retry is decoupled from the upload request.

3. **Deduplication:** Duplicate uploads (retry due to network timeout) are idempotent at the persistence layer. NATS deduplication window prevents re-processing.

4. **User experience:** iOS app shows a "synced" checkmark within 1 second, not waiting for Tier-2 completion (which may take seconds if the queue is backed up).

### Consequences

**Positive:**
- Low latency for critical path (trial persistence)
- Async tasks don't block client
- Failure in Tier-2 scoring doesn't corrupt trial log

**Negative:**
- Client must handle partial failures (e.g., trial persisted, S3 upload failed)
  - Mitigation: background job retries S3 upload; client checks status via GetAudioStatus RPC
- Clinician portal shows incomplete data until async tasks finish
  - Mitigation: portal polls for Tier-2 scores; displays "pending" while computing

### Compliance & Testing

- **Idempotency:** UploadSession is idempotent; retry doesn't create duplicate trials ✓
- **Audit trail:** Trial persisted before async tasks, so audit log is complete
- **Test:** chaos engineering test (kill NATS, verify trial is persisted; then resume NATS) ✓

---

## ADR-7: Rust Scoring Core vs. Python for Tier-2 DSP

**Status:** DECIDED (CR-2 implicit)  
**Date:** 2026-09-14  
**Stakeholders:** Architect, iOS Developer, ML Engineer

### Context

Tier-2 DSP (v1.5 fast-follow) includes syllable segmentation, DTW template matching, vowel formants, and voice onset time (VOT). These are computationally intensive (50–200 ms per attempt) and must run reliably on both iOS (Core ML) and backend (server-side fallback).

**Alternatives considered:**
- Pure Python (TensorFlow, librosa): slower, not portable to iOS without heavy cross-compilation
- Julia (numeric computing): excellent for signal processing, but no mobile story
- C++ (Cython for Python bindings): good performance, good portability
- Rust: type-safe, good performance, growing ML ecosystem

### Decision

**Rust for the scoring core.** Expose via:
1. **iOS:** Static library (libpraxia_dsp.a) compiled via cargo-lipo, called from Swift via FFI
2. **Backend:** Separate async worker (Go wrapper around Rust binary, or direct FFI)
3. **Python:** optional pyo3 bindings for research / offline analysis

**Rationale:**

1. **Portability:** Rust compiles to iOS (ARM64, via cargo-lipo), x86_64 backend, and research environments. A single Rust codebase serves all three.

2. **Performance:** Rust is as fast as C++, with stronger memory safety (prevents buffer overflows in audio processing).

3. **Type safety:** Tier-2 DSP involves complex signal processing (convolution, DTW distance, etc.). Rust's type system catches many bugs at compile-time.

4. **FFI maturity:** Rust FFI to Swift has a growing tooling ecosystem. cbindgen can auto-generate C headers.

5. **No Python GIL:** Tier-2 scoring runs on the critical path (if v1.5 response latency matters). Python's GIL blocks other threads; Rust threads are independent.

### Consequences

**Positive:**
- Single codebase for iOS + backend
- Type-safe signal processing
- High performance (measurable edge over Python)
- Portable to Android (Phase 2) without rewrite

**Negative:**
- Rust learning curve (mitigated by hiring or training)
- Longer compilation time (but one-time per release)
- Smaller ML ecosystem than Python (but sufficient for DSP tasks)

### Alternative: Python on Backend Only

If Tier-2 is only server-side (no on-device Tier-2 in v1.5), Python is acceptable for backend async worker. But if iOS needs on-device Tier-2 (e.g., Core ML model), Rust is the only sane choice.

**Decision:** Rust is chosen to future-proof for on-device Tier-2.

---

## ADR-8: Edge ML (On-Device) vs. Cloud ML for Tier-2

**Status:** DECIDED (CR-1 implicit)  
**Date:** 2026-09-14  
**Stakeholders:** Architect, ML Engineer, Product

### Context

Tier-2 DSP (syllable counting, DTW matching, formant tracking) can run on-device (iOS) or on the backend (cloud). Each has trade-offs:

- **On-device:** Low latency, privacy (audio doesn't leave device for Tier-2), works offline
- **Cloud:** Higher accuracy (can use larger models), easier to update, can leverage GPU

**Alternatives considered:**
- On-device only (v1.5)
- Cloud only (requires upload + round-trip, adds 2–5 sec latency)
- Hybrid: on-device for low-confidence cases; cloud for ambiguous cases

### Decision

**v1 ships Tier-1 only (no Tier-2). v1.5 ships on-device Tier-2 only (no cloud fallback).** Cloud Tier-2 is Phase 2.

**v1.5 on-device Tier-2:**
- Syllable count (envelope-based, deterministic)
- DTW template matching against child's own exemplars (no ML model)
- Optional: pYIN pitch contour (already in v1)
- Optional: formant estimation (OpenSmile or Kaldi feature extractor)

**Phase 2+ cloud Tier-2:**
- Per-child binary classifiers (is this production correct?)
- Per-target forced-alignment + GOP (goodness-of-pronunciation)
- Cross-child models (after 200+ labelled trials per target, 15+ children)

### Rationale

1. **v1 scope:** Tier-1 deterministic signals are sufficient to justify the product (attempt counting alone is enormous value). Ship on-time without Tier-2.

2. **v1.5 on-device:** DTW template matching requires the child's own prior attempts, which are on-device. No latency penalty, privacy-preserving, and DTW matching has been validated in speech SLP literature.

3. **Phase 2 cloud:** Once we have a corpus of 1000+ labelled trials from 50+ children, we can train per-child or per-target models with confidence. Cloud deployment allows A/B testing and gradual rollout.

4. **Privacy:** On-device Tier-2 means audio doesn't leave the device unless explicitly uploaded for clinician review. Tier-2 scoring (even tentative) is never transmitted without consent.

### Consequences

**Positive:**
- Faster to v1 (no ML infrastructure needed)
- On-device Tier-2 preserves privacy (audio stays local)
- DTW is interpretable (clinician can see which prior attempt it matched)
- No model serving infrastructure (lower ops cost)

**Negative:**
- Tier-2 unavailable until v1.5 (6 months later)
- DTW accuracy depends on exemplar quality (garbage in, garbage out)
- Cross-child models (Phase 2) require the corpus to be built first

### Compliance & Safety

- **v1 safety:** No machine accuracy scoring reaches child or clinician. Only Tier-1 (attempt count, latency, pitch) is visible. ✓
- **v1.5 safety:** On-device Tier-2 is a suggestion (DTW distance < threshold?), visible to clinician only as a hint, not a verdict. ✓
- **Phase 2 safety:** Cloud models are never displayed to child; clinician overrides feed active learning (human-in-the-loop). ✓

---

## ADR Consensus Table

| ADR | Decision | Rationale | Risk Mitigation |
|-----|----------|-----------|-----------------|
| ADR-1 | Native Swift iOS | Audio subsystem control, latency < 150ms | Hire iOS specialist; test on 3yr-old iPad |
| ADR-2 | Go + gRPC | Fast iteration, Kubernetes-native, small team | Code review for concurrency bugs; load test |
| ADR-3 | PostgreSQL event sourcing | ACID, audit trail, replayability | PITR backup; partition if >1B rows |
| ADR-4 | NATS JetStream | Simplicity, deduplication, self-hosted | 3-node HA cluster; daily snapshots |
| ADR-5 | S3 + on-device | Scalable, compliant, on-device default | Lifecycle policy; CloudTrail audit log |
| ADR-6 | Hybrid sync + async | Low latency critical path; async tasks deferred | Idempotency at DB layer; client polls status |
| ADR-7 | Rust scoring core | Portability (iOS + backend), type safety | Single codebase; test on all platforms |
| ADR-8 | On-device v1.5 only | Fast to v1; privacy-preserving | DTW validation study; Phase 2 requires corpus |

---

**All ADRs align with the Inviolable Constraints (UNIFIED-BUILD-PROMPT §3) and CR-1 through CR-8 (Synthesis document).**

**Architect certification:** ADRs are complete and defensible. Ready for implementation team review and approval by Product/Clinical Advisory Board.
