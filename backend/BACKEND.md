# Praxia Backend - Architecture & Operations Guide

**Version:** 1.0  
**Last Updated:** September 14, 2026  
**Author:** Backend Engineering Team

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Services](#services)
4. [Data Model](#data-model)
5. [API Documentation](#api-documentation)
6. [Deployment](#deployment)
7. [Operations](#operations)
8. [Monitoring](#monitoring)
9. [Troubleshooting](#troubleshooting)
10. [Security & Compliance](#security--compliance)

---

## Overview

The Praxia backend is a production-grade, speech-therapy data platform built in Go with gRPC. It ingests trial data from iOS devices, persists immutably, processes audio asynchronously, and exposes APIs for the clinician portal.

**Key Properties:**
- **Event-sourced, append-only trial log** — immutable audit trail
- **Distributed, zero-downtime deployment** — Kubernetes-ready
- **Real-time audio processing** — NATS JetStream workers
- **Multi-tenant enforcement** — Consumer vs. Institutional modes
- **HIPAA/COPPA compliance** — encryption, audit logs, retention policies
- **High throughput** — handles 1M+ trials/month

---

## Architecture

### System Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                      iOS Client (Swift)                        │
│                                                                │
│  • Offline-first SQLite + SQLCipher                           │
│  • Trial queue (append-only outbox)                           │
│  • Sync on wifi + charging                                    │
└────────────────────┬─────────────────────────────────────────┘
                     │ gRPC (TLS 1.2+)
                     ▼
┌────────────────────────────────────────────────────────────────┐
│                  Praxia Backend (Go/gRPC)                      │
│                                                                │
│  TrialService        AudioService       ConfigService         │
│  • UploadSession     • UploadAudio      • GetProgram          │
│  • GetSessionTrials  • GetAudioStatus   • GetTargets          │
│  • GetChildProgress  • GetAudioMeta     • GetCueHierarchy    │
│  • QueryTrials                         • GetAAC              │
│                                                                │
│  ┌──────────────────┬───────────────────┬─────────────────┐  │
│  │   PostgreSQL     │   Redis Cache     │   NATS Events   │  │
│  │                  │                   │                 │  │
│  │ • trial_events   │ • Progress cache  │ • audio.uploaded│  │
│  │ • scores         │ • Config cache    │ • scores.tier2  │  │
│  │ • audio metadata │ • Session cache   │ • audit.>       │  │
│  │ • audit_log      │                   │                 │  │
│  └──────────────────┴───────────────────┴─────────────────┘  │
│                                                                │
│  Background Workers:                                          │
│  • AudioWorker: processes audio.uploaded → DSP → scores      │
│  • RetentionWorker: daily cleanup of expired audio           │
│  • ProgressCacheWorker: hourly progress aggregation          │
└────────────────────┬──────────────────────────┬──────────────┘
                     │                          │
          ┌──────────▼──────────────┐   ┌──────▼──────────┐
          │  S3 (Audio Storage)    │   │ Clinician      │
          │  • s3://audio/*/       │   │ Portal (Next.js)│
          │  • 90-day retention    │   │                 │
          │  • SSE-KMS encryption  │   │ • ReportGen     │
          │  • Per-tenant keys     │   │ • Analytics     │
          └────────────────────────┘   └─────────────────┘
```

### Deployment Architecture

**Development:**
- docker-compose: PostgreSQL + Redis + NATS + MinIO
- ~5 minutes to full stack

**Staging/Production:**
- Kubernetes: StatefulSet for backend, managed RDS, ElastiCache, NATS cluster
- Horizontal autoscaling (2–20 replicas based on CPU/gRPC requests)
- Multi-AZ, cross-region failover via Route53

---

## Services

### 1. TrialService (gRPC)

Manages speech therapy trial data — the core event log.

#### UploadSession

**Request:**
```protobuf
message UploadSessionRequest {
  string session_id = 1;          // UUID
  string child_id = 2;            // Pseudonymous ID
  string device_id = 3;           // iPhone UDID or generated
  repeated TrialData trials = 4;  // Batch (typically 10–100)
}
```

**Process:**
1. Validate session_id, child_id, device_id (required)
2. Create session if missing
3. For each trial:
   - Validate trial_id + target_word (required)
   - Check for duplicate by trial_id (UNIQUE constraint)
   - Insert to trial_events (atomic, one txn)
   - If audio_path: schedule Tier-2 processing (NATS publish)
4. Return synced trial IDs + duplicate count + error count

**Response:**
```protobuf
message UploadSessionResponse {
  int32 synced_count = 1;
  repeated string synced_trial_ids = 2;
  int32 duplicate_count = 3;
  repeated string duplicate_trial_ids = 4;
  int32 error_count = 5;
  string message = 6;
}
```

**SLA:** < 100 ms for 50 trials (locally persisted before any response).

#### GetSessionTrials

**Request:**
```protobuf
message GetSessionTrialsRequest {
  string session_id = 1;
  string child_id = 2;
}
```

**Returns:** Ordered list of trials (device_timestamp ASC).

**SLA:** < 200 ms (with index on session_id + device_timestamp).

#### GetChildProgress

**Request:**
```protobuf
message GetChildProgressRequest {
  string child_id = 1;
  TimeRange time_range = 2;  // THIS_WEEK | THIS_MONTH | ALL_TIME
}
```

**Response:**
```protobuf
message ChildProgress {
  int32 attempt_count = 1;
  float success_percentage = 2;  // Percent of 'got_it' trials
  map<int32, int32> cue_level_distribution = 3;
  float average_latency_ms = 4;
  float average_snr_db = 5;
}
```

**Caching:** Redis (TTL 1 hour). Cache key: `{child_id}:{time_range}`.

**SLA:** < 50 ms (cache hit), ~300 ms (miss, aggregation query).

#### QueryTrials

**Request:**
```protobuf
message QueryTrialsRequest {
  string child_id = 1;
  google.protobuf.Timestamp start_date = 2;
  google.protobuf.Timestamp end_date = 3;
  string target_word = 4;      // Optional filter
  int32 cue_level = 5;         // -1 = all levels
  int32 limit = 6;             // Default 100, max 1000
  int32 offset = 7;
}
```

**Response:** Paginated trials + total_count + offset.

**Indexes required:**
- `idx_trial_events_child_id`
- `idx_trial_events_device_timestamp`
- Composite: `(child_id, target_word, device_timestamp)`

**SLA:** < 500 ms (offset + limit pagination).

---

### 2. AudioService (gRPC)

Manages audio uploads and metadata.

#### UploadAudio

**Process:**
1. Validate trial exists (foreign key check)
2. Upload audio blob to S3:
   - Path: `s3://audio/{session_id}/{trial_id}.opus`
   - Encryption: SSE-S3
   - Content-Type: audio/opus
3. Insert attempt_recordings (trial_id is UNIQUE FK)
4. **Non-blocking:** Publish `audio.uploaded` message to NATS
   - Tier-2 worker picks it up asynchronously
   - Latency to iOS: **~50 ms** (S3 + DB, no processing)

**Response:**
```protobuf
message UploadAudioResponse {
  string trial_id = 1;
  string s3_path = 2;
  google.protobuf.Timestamp uploaded_at = 3;
  string message = 4;
}
```

#### GetAudioStatus

**Returns:** `AVAILABLE | EXPIRED | DELETED | NOT_FOUND`

Logic:
- Expired: `audio_retention_expires < NOW()`
- Deleted: `audio_path IS NULL` or key doesn't exist in S3
- Available: key exists in S3 + within retention window

---

### 3. ConfigService (gRPC)

Loads therapy program, targets, cue hierarchy, and AAC board config.

**Caching:** Redis, TTL 24 hours.

---

## Data Model

### trial_events (Immutable, Append-Only)

```sql
CREATE TABLE trial_events (
  id SERIAL PRIMARY KEY,
  trial_id TEXT UNIQUE NOT NULL,        -- UUID from iOS
  session_id TEXT NOT NULL,             -- FK → sessions
  child_id TEXT NOT NULL,               -- FK → children
  device_id TEXT NOT NULL,              -- iPhone UDID
  device_timestamp TIMESTAMPTZ,         -- Client-side time
  server_timestamp TIMESTAMPTZ DEFAULT NOW(),
  target_word TEXT NOT NULL,            -- 'ball', 'dog', etc.
  cue_level SMALLINT NOT NULL,          -- 0–5 (CHECK constraint)
  score TEXT NOT NULL,                  -- 'got_it' | 'close' | 'not_yet'
  tier1_vocalization_detected BOOLEAN,  -- On-device VAD
  tier1_latency_ms SMALLINT,            -- ms from vocalization→reinforcement
  tier1_snr_db REAL,                    -- Signal-to-noise ratio
  tier1_syllable_estimate SMALLINT,     -- Count
  audio_path TEXT,                      -- S3 key (nullable)
  audio_retention_expires TIMESTAMPTZ,  -- 90 days default
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_trial_events_child_id ON trial_events(child_id);
CREATE INDEX idx_trial_events_session_id ON trial_events(session_id);
CREATE INDEX idx_trial_events_device_timestamp ON trial_events(device_timestamp DESC);
```

### attempt_recordings

```sql
CREATE TABLE attempt_recordings (
  id SERIAL PRIMARY KEY,
  trial_id TEXT UNIQUE NOT NULL,        -- FK → trial_events
  duration_seconds REAL,
  sample_rate SMALLINT,                 -- 16000 Hz typical
  channels SMALLINT,                    -- 1 (mono)
  bit_depth SMALLINT,                   -- 16-bit
  uploaded_at TIMESTAMPTZ,
  s3_path TEXT NOT NULL UNIQUE,         -- Exact S3 key
  content_type TEXT DEFAULT 'audio/opus',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### scores

```sql
CREATE TABLE scores (
  id SERIAL PRIMARY KEY,
  trial_id TEXT NOT NULL,               -- FK → trial_events
  rater TEXT NOT NULL,                  -- 'parent' | 'slp' | 'model_tier2' | 'model_tier3'
  score TEXT NOT NULL,                  -- 'got_it' | 'close' | 'not_yet'
  confidence REAL,                      -- 0–1 (machine scores only)
  ipa_transcription TEXT,               -- SLP annotation
  cue_needed TEXT,                      -- What cue helped
  scored_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (trial_id, rater)              -- One score per rater per trial
);
```

### Retention

**Raw audio (on S3):**
- Default: 90 days
- On-demand deletion via `DELETE /trials/{id}/audio` endpoint
- Deletion logged to audit_log + audio_retention_log

**Trial events & scores:**
- Indefinite (research value, no audio)
- Cascading delete when child data is GDPR-deleted

---

## API Documentation

### gRPC Endpoints

All endpoints require:
- **TLS 1.2+** (production)
- **Bearer token in metadata** (OIDC/JWT)
- **RBAC check** per endpoint

```protobuf
service TrialService {
  rpc UploadSession(UploadSessionRequest) returns (UploadSessionResponse);
  rpc GetSessionTrials(GetSessionTrialsRequest) returns (GetSessionTrialsResponse);
  rpc GetChildProgress(GetChildProgressRequest) returns (GetChildProgressResponse);
  rpc QueryTrials(QueryTrialsRequest) returns (QueryTrialsResponse);
}

service AudioService {
  rpc UploadAudio(UploadAudioRequest) returns (UploadAudioResponse);
  rpc GetAudioStatus(GetAudioStatusRequest) returns (GetAudioStatusResponse);
  rpc GetAudioMetadata(GetAudioMetadataRequest) returns (GetAudioMetadataResponse);
}

service ConfigService {
  rpc GetProgram(GetProgramRequest) returns (GetProgramResponse);
  rpc GetTargets(GetTargetsRequest) returns (GetTargetsResponse);
  rpc GetCueHierarchy(GetCueHierarchyRequest) returns (GetCueHierarchyResponse);
  rpc GetAAC(GetAACRequest) returns (GetAACResponse);
}
```

### Error Codes

| Code | Message | Handling |
|------|---------|----------|
| `INVALID_ARGUMENT` | Missing required field | Client retry with valid input |
| `NOT_FOUND` | Trial/child/program doesn't exist | Client error (404-like) |
| `ALREADY_EXISTS` | Duplicate trial_id | Idempotent — return success |
| `RESOURCE_EXHAUSTED` | Rate limit or quota | Exponential backoff + retry |
| `INTERNAL` | Database/S3 error | Server retry (5xx-like) |

---

## Deployment

### Development

```bash
# Start all services
make docker-up

# View logs
make docker-logs

# Run tests
make test

# Generate protobuf code
make proto
```

### Staging/Production

#### Prerequisites

- AWS account (RDS, S3, ECR)
- Kubernetes cluster (EKS)
- Helm installed

#### Steps

1. **Build & push Docker image:**
   ```bash
   docker build -t praxia-backend:latest .
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ECR_URL>
   docker tag praxia-backend:latest <ECR_URL>/praxia-backend:latest
   docker push <ECR_URL>/praxia-backend:latest
   ```

2. **Update RDS (PostgreSQL):**
   ```bash
   # One-time: create instance
   aws rds create-db-instance \
     --db-instance-identifier praxia-prod \
     --db-instance-class db.t3.medium \
     --engine postgres \
     --master-username admin \
     --master-user-password "<STRONG_PASSWORD>" \
     --allocated-storage 100 \
     --storage-encrypted \
     --backup-retention-period 30
   
   # Run migrations
   kubectl exec -it <pod> -- /app/server -migrate
   ```

3. **Deploy Helm chart:**
   ```bash
   helm install praxia ./deploy/k8s/helm \
     --namespace praxia \
     --values values-prod.yaml
   ```

4. **Verify:**
   ```bash
   kubectl get pods -n praxia
   kubectl logs -n praxia -l app=backend --tail=50
   ```

---

## Operations

### Scaling

**Horizontal:** Kubernetes HPA automatically scales based on:
- CPU: 70% threshold
- gRPC requests: 1000 req/min per pod
- Min replicas: 2, Max: 20

**Vertical:** Database connection pooling (25 open, 5 idle per instance).

### Monitoring & Observability

#### Prometheus Metrics (exposed on :8081/metrics)

```
# Trial uploads
trial_upload_total{status="success|duplicate|error"} — counter
trial_upload_duration_seconds{} — histogram

# Audio uploads
audio_upload_total{status="success|failed"} — counter
audio_upload_bytes{} — histogram

# Database latency
pg_query_duration_seconds{query="trial_events|scores"} — histogram

# Cache hit rate
redis_cache_hits_total — counter
redis_cache_misses_total — counter

# gRPC
grpc_server_handling_seconds_bucket{grpc_method,grpc_status} — histogram
```

#### DataDog Agent (structured JSON logging)

```json
{
  "timestamp": "2026-09-14T15:30:00Z",
  "level": "info",
  "service": "praxia-backend",
  "message": "trial uploaded",
  "trial_id": "...",
  "child_id": "...",
  "duration_ms": 45,
  "tags": ["prod", "us-east-1"]
}
```

#### Alerting

**PagerDuty triggers on:**
- 5xx errors > 1% (5-minute window)
- Audio uploads failing > 5%
- Database response time > 1s (p95)
- Pod crashes (restart count > 3)

### Backups & Recovery

**Daily backup:** RDS automated snapshots (30-day retention).

**Recovery procedure:**
```bash
# 1. Restore RDS from snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier praxia-restored \
  --db-snapshot-identifier <snapshot-id>

# 2. Update connection string in Secrets Manager
aws secretsmanager update-secret \
  --secret-id praxia/db-url \
  --secret-string "postgres://...new-endpoint..."

# 3. Roll deployment
kubectl rollout restart deployment/backend -n praxia

# 4. Verify
kubectl exec <pod> -- /app/server -health
```

### Audio Retention Cleanup

**Automated job** runs daily at 02:00 UTC:
1. Query trials where `audio_retention_expires < NOW()`
2. Delete from S3 (batch delete API)
3. Clear `audio_path` in DB (SET NULL)
4. Log to audit_log + audio_retention_log

**Manual cleanup:**
```bash
# Delete audio for a specific trial
curl -X DELETE https://api.praxia.ai/v1/trials/<trial_id>/audio \
  -H "Authorization: Bearer <token>"

# Purge all audio for a child (GDPR)
curl -X DELETE https://api.praxia.ai/v1/children/<child_id>/audio \
  -H "Authorization: Bearer <token>"
```

### NATS Maintenance

**Consumer lag monitoring:**
```bash
nats consumer info praxia audio-events audio-processor
# Expected lag: < 100 messages (< 1 second)
```

**Replay (if processing failed):**
```bash
# Resend last 1000 messages
nats consumer create praxia audio-events \
  --deliver-policy all \
  --max-deliver 5 \
  --sample 100
```

---

## Troubleshooting

### High database latency

**Symptoms:** Response times > 500 ms, Prometheus p95 > 1s.

**Diagnosis:**
```bash
# Check slow queries
SELECT query, calls, total_time FROM pg_stat_statements
  ORDER BY total_time DESC LIMIT 10;

# Check index usage
SELECT schemaname, tablename, indexname, idx_scan FROM pg_stat_user_indexes
  WHERE idx_scan = 0;
```

**Fix:**
1. Add missing indexes: `CREATE INDEX idx_trial_events_child_id_target_word ON trial_events(child_id, target_word);`
2. Increase connection pool in prod (25 → 40)
3. Enable query result caching in Redis

### Audio upload failures

**Symptoms:** UploadAudio returns 500 or times out.

**Diagnosis:**
```bash
# Check S3 connectivity
aws s3 ls s3://praxia-audio/

# Check NATS message queue
nats consumer info praxia audio-events audio-processor | grep Pending

# View logs
kubectl logs -n praxia -l app=backend --tail=100 | grep "audio"
```

**Fix:**
1. Verify S3 bucket policy + IAM role
2. Check S3 rate limiting (backoff 429 errors)
3. Increase NATS JetStream retention: `max_bytes: 50GB`

### Cache stampede

**Symptoms:** Spike in database queries after cache expiration, latency spikes.

**Fix:**
1. Use Redis cache warming (pre-populate on pod startup)
2. Extend TTL for child_progress: 4 hours (instead of 1 hour)
3. Stagger cache expiration: add jitter `TTL + random(0–300s)`

---

## Security & Compliance

### Authentication & Authorization

**Client authentication:**
- OIDC tokens (Google, Auth0)
- JWT verification in gRPC interceptor
- Token caching in Redis (5-minute TTL)

**RBAC per endpoint:**
```
Parent: trial:read, audio:read, config:read
Clinician: trial:read, audio:read+write, config:read+write
Admin: all
```

### Encryption

**In transit:**
- TLS 1.2+ for gRPC
- mTLS for backend-to-backend (NATS, database)

**At rest:**
- PostgreSQL: RDS encryption (AES-256, AWS KMS)
- S3: per-tenant encryption keys (KMS)
- Redis: ElastiCache encryption

### Audit Logging

Every action logged to `audit_log`:
```sql
INSERT INTO audit_log (action, user_id, child_id, trial_id, metadata)
VALUES ('portal.audio.download', 'clinician_123', 'child_456', 'trial_789', '{"ip": "..."}');
```

**Exported to:** DataDog Logs (immutable, 7-year retention).

### HIPAA/COPPA Compliance

| Requirement | Implementation |
|---|---|
| Encryption at rest | RDS + S3 KMS encryption ✓ |
| Encryption in transit | TLS 1.2+ ✓ |
| Access logs | audit_log table, DataDog export ✓ |
| Data retention policy | Published schedule, automated cleanup ✓ |
| Breach notification | Automated SNS alert to security team ✓ |
| GDPR deletion | DELETE CASCADE on children → all FK tables ✓ |

### Secrets Management

All secrets stored in AWS Secrets Manager:
- DB password
- API keys
- TLS certificates
- S3 KMS key (auto-rotated)

Rotated automatically every 90 days.

---

## Glossary

| Term | Definition |
|---|---|
| **trial_id** | UUID generated by iOS client, uniquely identifies one practice attempt |
| **session_id** | UUID for a practice session (may contain 10–100 trials) |
| **cue_level** | L0–L5 temporal cueing hierarchy (0=no cue, 5=maximal) |
| **Tier-1 DSP** | On-device signal processing (VAD, latency, SNR) |
| **Tier-2 DSP** | Server-side DTW exemplar matching (sound production accuracy) |
| **TTL** | Time-to-live (cache expiration in Redis, audio retention in S3) |
| **Immutable** | Cannot be modified or deleted after creation (append-only log) |

---

## References

- **Data Model:** docs/04-engineering/data-model-and-events.md
- **Compliance:** docs/05-compliance/privacy-security-regulatory-plan.md
- **Technical Architecture:** docs/04-engineering/technical-architecture.md
- **Protobuf Specs:** backend/protos/*.proto
- **SQL Schema:** backend/migrations/001_initial_schema.sql

---

**Support:** For operational issues, contact backend-oncall@praxia.ai or page on PagerDuty.
