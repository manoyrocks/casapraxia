# Praxia Backend

Production-grade speech therapy data platform built in Go with gRPC.

## Quick Start (Local Development)

### Prerequisites

- Docker & docker-compose
- Go 1.21+ (for local dev)
- Make

### Run Full Stack (5 minutes)

```bash
cd backend

# Start all services: PostgreSQL, Redis, NATS, MinIO, backend
make docker-up

# View logs
make docker-logs

# Check health
curl http://localhost:8080/health
```

### Services Running

- **Backend (gRPC):** localhost:50051
- **PostgreSQL:** localhost:5432
- **Redis:** localhost:6379
- **NATS:** localhost:4222, UI at http://localhost:8222
- **MinIO (S3):** http://localhost:9000

### What Just Happened

1. PostgreSQL created `praxia` database + schema
2. Backend server listening on :50051 (gRPC)
3. NATS JetStream ready for event processing
4. MinIO bucket `praxia-audio` created for audio storage

## Project Structure

```
backend/
├── cmd/
│   └── server/           # Entry point
├── internal/
│   ├── service/          # gRPC service implementations
│   │   ├── trial_service.go
│   │   ├── audio_service.go
│   │   └── config_service.go
│   ├── db/               # Database connection & migrations
│   ├── model/            # Data structures
│   └── worker/           # Background workers (NATS)
├── pkg/
│   ├── gen/              # Generated protobuf code
│   └── s3/               # S3 client
├── protos/               # Protobuf definitions
├── migrations/           # SQL migrations
├── config/               # Configuration
├── deploy/
│   ├── docker/           # Dockerfile
│   └── k8s/              # Helm charts
├── go.mod / go.sum
├── Makefile
├── docker-compose.yml
├── BACKEND.md            # Full architecture & operations guide
└── README.md             # This file
```

## Development

### Generate Protobuf Code

```bash
make proto

# Or manually:
protoc --go_out=. --go-grpc_out=. protos/*.proto
```

### Run Tests

```bash
make test              # Run all tests
make test-coverage     # With coverage report
```

### Code Quality

```bash
make fmt               # Format code
make lint              # Lint with golangci-lint
```

### Hot Reload (Local)

```bash
make dev               # Uses 'air' for hot reload
```

## API Documentation

### TrialService

**UploadSession** — Accept batch of trials from iOS

```protobuf
UploadSession(UploadSessionRequest) → UploadSessionResponse
```

- Validates trial_id uniqueness (UNIQUE constraint)
- Persists atomically to trial_events table (one transaction)
- Publishes NATS message for audio processing
- Returns synced + duplicate counts
- SLA: < 100 ms for 50 trials

**GetSessionTrials** — Retrieve trials for a session

```protobuf
GetSessionTrials(GetSessionTrialsRequest) → GetSessionTrialsResponse
```

- Ordered by device_timestamp
- SLA: < 200 ms

**GetChildProgress** — Aggregated metrics (cached hourly)

```protobuf
GetChildProgress(GetChildProgressRequest) → GetChildProgressResponse
```

- Success percentage, cue level distribution, latency/SNR stats
- Cached in Redis (TTL 1 hour)
- SLA: < 50 ms (cache hit), ~300 ms (miss)

**QueryTrials** — Filtered paginated query

```protobuf
QueryTrials(QueryTrialsRequest) → QueryTrialsResponse
```

- Filters: date range, target_word, cue_level
- Pagination: limit + offset
- SLA: < 500 ms

### AudioService

**UploadAudio** — Store audio blob and metadata

- Uploads to S3 (SSE-S3 encrypted)
- Publishes audio.uploaded to NATS (Tier-2 processing)
- Returns S3 path + upload timestamp
- SLA: < 50 ms

**GetAudioStatus** — Check audio availability

- Returns: AVAILABLE | EXPIRED | DELETED | NOT_FOUND
- Checks S3 existence + retention expiry

### ConfigService

**GetProgram** — Child's active therapy program

**GetTargets** — Active target words for program

**GetCueHierarchy** — L0–L5 cue definitions

**GetAAC** — 8-cell augmentative communication board

All cached in Redis (TTL 24 hours).

## Data Model

### trial_events (Immutable, Append-Only)

```sql
CREATE TABLE trial_events (
  trial_id TEXT UNIQUE NOT NULL,
  session_id TEXT NOT NULL,
  child_id TEXT NOT NULL,
  device_id TEXT NOT NULL,
  device_timestamp TIMESTAMPTZ,
  server_timestamp TIMESTAMPTZ DEFAULT NOW(),
  target_word TEXT NOT NULL,
  cue_level SMALLINT NOT NULL,           -- 0–5
  score TEXT NOT NULL,                   -- 'got_it' | 'close' | 'not_yet'
  tier1_vocalization_detected BOOLEAN,   -- On-device VAD
  tier1_latency_ms SMALLINT,
  tier1_snr_db REAL,
  tier1_syllable_estimate SMALLINT,
  audio_path TEXT,                       -- S3 key
  audio_retention_expires TIMESTAMPTZ,   -- 90-day default
  ...
);
```

### attempt_recordings

```sql
CREATE TABLE attempt_recordings (
  trial_id TEXT UNIQUE NOT NULL,  -- FK → trial_events
  s3_path TEXT NOT NULL UNIQUE,   -- Exact S3 location
  duration_seconds REAL,
  sample_rate SMALLINT,           -- 16000 Hz typical
  channels SMALLINT,              -- 1 (mono)
  bit_depth SMALLINT,             -- 16-bit
  uploaded_at TIMESTAMPTZ,
  ...
);
```

### scores (Multiple Raters)

```sql
CREATE TABLE scores (
  trial_id TEXT NOT NULL,
  rater TEXT NOT NULL,              -- 'parent' | 'slp' | 'model_tier2'
  score TEXT NOT NULL,              -- 'got_it' | 'close' | 'not_yet'
  confidence REAL,                  -- 0–1 (machine only)
  scored_at TIMESTAMPTZ NOT NULL,
  UNIQUE (trial_id, rater),
  ...
);
```

Full schema: `migrations/001_initial_schema.sql`

## NATS Event Processing

### Streams

- **audio-events** (audio.uploaded) → Tier-2 DSP worker
- **score-events** (scores.tier2, scores.tier3) → Persistence
- **audit-events** (audit.>) → 90-day retention

### Workers

**AudioWorker:**
- Listens to `audio.uploaded`
- Verifies audio in S3
- Publishes `scores.tier2` when processing completes
- (Production: runs Tier-2 DTW exemplar matching)

**RetentionWorker:**
- Daily cleanup job (02:00 UTC)
- Deletes audio from S3 when audio_retention_expires < NOW()
- Logs to audio_retention_log

## Deployment

### Docker Build

```bash
docker build -f deploy/docker/Dockerfile -t praxia-backend:latest .
```

### Kubernetes (Production)

See `deploy/k8s/helm/` for Helm chart. Quick deploy:

```bash
helm install praxia ./deploy/k8s/helm \
  --namespace praxia \
  --values values-prod.yaml
```

Includes:
- StatefulSet with 2–20 replicas (HPA)
- ConfigMap (environment variables)
- Secret (database password, API keys)
- Service + NetworkPolicy
- Health checks + readiness probes

## Monitoring & Alerting

### Prometheus Metrics

- `trial_upload_total{status}`
- `audio_upload_total{status}`
- `grpc_server_handling_seconds{grpc_method,grpc_status}`
- `pg_query_duration_seconds{query}`
- `redis_cache_hits_total`, `redis_cache_misses_total`

### PagerDuty Alerts

- 5xx errors > 1% (5-minute window)
- Audio uploads failing > 5%
- Database latency p95 > 1s
- Pod crashes (restart count > 3)

### Logs (DataDog)

Structured JSON logs exported automatically. Query:

```
service:praxia-backend level:error
service:praxia-backend tag:prod
```

## Compliance & Security

- **HIPAA:** Encryption at rest (RDS/S3) + transit (TLS)
- **COPPA:** Layered consent, biometric handling (voice)
- **FERPA:** Institutional mode (no model training without explicit consent)
- **Audit logging:** Every action logged to audit_log + DataDog
- **Retention:** Published 90-day schedule for audio, indefinite for trial events
- **GDPR/BIPA:** On-device-first architecture, cascading delete on child removal

Full compliance plan: `docs/05-compliance/privacy-security-regulatory-plan.md`

## Troubleshooting

### Backend won't start

```bash
# Check logs
docker-compose logs backend

# Common issues:
# - PostgreSQL not ready: wait 10s, retry
# - Port 50051 already in use: kill other process or change port
# - Database URL invalid: check DATABASE_URL env var
```

### Queries are slow

```bash
# Check indexes
docker exec praxia-postgres psql -U praxia_user -d praxia \
  -c "SELECT * FROM pg_stat_user_indexes WHERE idx_scan = 0;"

# Add missing index if needed
docker exec praxia-postgres psql -U praxia_user -d praxia \
  -c "CREATE INDEX idx_name ON table_name(col);"
```

### NATS queue stuck

```bash
# Check consumer lag
docker exec praxia-nats nats consumer info praxia audio-events audio-processor

# Replay messages
docker exec praxia-nats nats consumer create praxia audio-events \
  --deliver-policy all --max-deliver 5
```

## Testing with gRPC Client

### Using grpcurl (easy)

```bash
# Install: https://github.com/fullstorydev/grpcurl

# Call TrialService.UploadSession
grpcurl -plaintext \
  -d '{
    "session_id": "sess_123",
    "child_id": "child_123",
    "device_id": "device_123",
    "trials": [{
      "trial_id": "trial_1",
      "target_word": "ball",
      "cue_level": 1,
      "score": "GOT_IT"
    }]
  }' \
  localhost:50051 \
  praxia.trial.v1.TrialService/UploadSession
```

### Using Go test client

See `internal/service/*_test.go` for examples.

## Contributing

1. Branch: `git checkout -b feature/xxx`
2. Code: `make fmt && make lint`
3. Test: `make test`
4. Commit: Include issue number
5. Push: Create PR

## Support

- **Docs:** `BACKEND.md` (architecture, deployment, operations)
- **Issues:** GitHub Issues
- **On-call:** backend-oncall@praxia.ai or PagerDuty

---

**Built with Go, gRPC, PostgreSQL, NATS, S3.**
