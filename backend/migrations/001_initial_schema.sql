-- Praxia Backend Initial Schema
-- Version: 1
-- Created: 2026-09-14

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- Children: Pseudonymous child records
-- ============================================================================

CREATE TABLE children (
  id TEXT PRIMARY KEY,
  first_name TEXT NOT NULL,
  birth_date DATE,
  organization_id TEXT,
  current_program_id TEXT,
  tenant_mode TEXT NOT NULL DEFAULT 'consumer', -- 'consumer' | 'institutional'
  consent_training BOOLEAN NOT NULL DEFAULT FALSE,
  consent_core_service BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_children_organization_id ON children(organization_id);
CREATE INDEX idx_children_created_at ON children(created_at DESC);

-- ============================================================================
-- Programs & Targets: Therapy program definitions
-- ============================================================================

CREATE TABLE programs (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  version INT NOT NULL DEFAULT 1,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE targets (
  id TEXT PRIMARY KEY,
  program_id TEXT NOT NULL REFERENCES programs(id),
  word TEXT NOT NULL,
  phonetic_features TEXT, -- IPA
  stimulability_score REAL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_targets_program_id ON targets(program_id);

-- ============================================================================
-- Cue Hierarchy: L0-L5 cue definitions per target
-- ============================================================================

CREATE TABLE cue_hierarchies (
  id TEXT PRIMARY KEY,
  target_id TEXT NOT NULL REFERENCES targets(id),
  version INT NOT NULL DEFAULT 1,
  level INT NOT NULL CHECK (level BETWEEN 0 AND 5),
  description TEXT,
  visual_cue TEXT,
  gestural_cue TEXT,
  rhythmic_cue TEXT,
  frame_cue TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(target_id, version, level)
);

CREATE INDEX idx_cue_hierarchies_target_id ON cue_hierarchies(target_id);

-- ============================================================================
-- Sessions: Practice sessions
-- ============================================================================

CREATE TABLE sessions (
  id TEXT PRIMARY KEY,
  child_id TEXT NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ,
  duration_seconds INT,
  device_id TEXT,
  setting TEXT, -- 'home' | 'clinic' | 'tele'
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sessions_child_id ON sessions(child_id);
CREATE INDEX idx_sessions_start_time ON sessions(start_time DESC);

-- ============================================================================
-- Trial Events: Immutable, append-only event log
-- ============================================================================

CREATE TABLE trial_events (
  id SERIAL PRIMARY KEY,
  trial_id TEXT UNIQUE NOT NULL,
  session_id TEXT NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
  child_id TEXT NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  device_id TEXT NOT NULL,
  device_timestamp TIMESTAMPTZ,
  server_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  target_word TEXT NOT NULL,
  cue_level SMALLINT NOT NULL CHECK (cue_level BETWEEN 0 AND 5),
  score TEXT NOT NULL CHECK (score IN ('got_it', 'close', 'not_yet')),

  tier1_vocalization_detected BOOLEAN,
  tier1_latency_ms SMALLINT,
  tier1_snr_db REAL,
  tier1_syllable_estimate SMALLINT,

  audio_path TEXT,
  audio_retention_expires TIMESTAMPTZ,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_trial_events_child_id ON trial_events(child_id);
CREATE INDEX idx_trial_events_session_id ON trial_events(session_id);
CREATE INDEX idx_trial_events_device_timestamp ON trial_events(device_timestamp DESC);
CREATE INDEX idx_trial_events_trial_id ON trial_events(trial_id);

-- ============================================================================
-- Attempt Recordings: Audio blob metadata
-- ============================================================================

CREATE TABLE attempt_recordings (
  id SERIAL PRIMARY KEY,
  trial_id TEXT UNIQUE NOT NULL REFERENCES trial_events(trial_id) ON DELETE CASCADE,
  duration_seconds REAL,
  sample_rate SMALLINT,
  channels SMALLINT,
  bit_depth SMALLINT,
  uploaded_at TIMESTAMPTZ,
  s3_path TEXT NOT NULL UNIQUE,
  content_type TEXT DEFAULT 'audio/opus',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_attempt_recordings_trial_id ON attempt_recordings(trial_id);
CREATE INDEX idx_attempt_recordings_s3_path ON attempt_recordings(s3_path);

-- ============================================================================
-- Scores: Multiple raters per trial
-- ============================================================================

CREATE TABLE scores (
  id SERIAL PRIMARY KEY,
  trial_id TEXT NOT NULL REFERENCES trial_events(trial_id) ON DELETE CASCADE,
  rater TEXT NOT NULL CHECK (rater IN ('parent', 'slp', 'model_tier2', 'model_tier3')),
  score TEXT NOT NULL CHECK (score IN ('got_it', 'close', 'not_yet')),
  confidence REAL CHECK (confidence BETWEEN 0 AND 1),
  ipa_transcription TEXT,
  cue_needed TEXT,
  scored_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (trial_id, rater)
);

CREATE INDEX idx_scores_trial_id ON scores(trial_id);
CREATE INDEX idx_scores_rater ON scores(rater);
CREATE INDEX idx_scores_created_at ON scores(created_at DESC);

-- ============================================================================
-- AAC Board: Augmentative & Alternative Communication config
-- ============================================================================

CREATE TABLE aac_boards (
  id TEXT PRIMARY KEY,
  child_id TEXT NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  version INT NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE aac_cells (
  id SERIAL PRIMARY KEY,
  board_id TEXT NOT NULL REFERENCES aac_boards(id) ON DELETE CASCADE,
  position INT NOT NULL CHECK (position BETWEEN 0 AND 7),
  emoji TEXT,
  text TEXT NOT NULL,
  target_word TEXT,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(board_id, position)
);

CREATE INDEX idx_aac_cells_board_id ON aac_cells(board_id);

-- ============================================================================
-- Audit Log: Access and modification tracking
-- ============================================================================

CREATE TABLE audit_log (
  id SERIAL PRIMARY KEY,
  action TEXT NOT NULL, -- 'portal.session.view', 'portal.audio.download', etc.
  user_id TEXT,
  child_id TEXT,
  trial_id TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_log_created_at ON audit_log(created_at DESC);
CREATE INDEX idx_audit_log_user_id ON audit_log(user_id);
CREATE INDEX idx_audit_log_child_id ON audit_log(child_id);

-- ============================================================================
-- Audio Retention Log: Track deletions
-- ============================================================================

CREATE TABLE audio_retention_log (
  id SERIAL PRIMARY KEY,
  trial_id TEXT,
  s3_path TEXT,
  action TEXT NOT NULL, -- 'expired' | 'manually_deleted' | 'consent_revoked'
  retention_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audio_retention_log_created_at ON audio_retention_log(created_at DESC);
CREATE INDEX idx_audio_retention_log_trial_id ON audio_retention_log(trial_id);

-- ============================================================================
-- Consent Records: Layered, revocable consents
-- ============================================================================

CREATE TABLE consent_records (
  id SERIAL PRIMARY KEY,
  child_id TEXT NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  guardian_id TEXT NOT NULL,
  consent_type TEXT NOT NULL, -- 'core_service' | 'on_device_recording' | 'cloud_storage' | 'clinician_sharing' | 'model_training' | 'research_publication'
  granted BOOLEAN NOT NULL,
  policy_version TEXT,
  verification_method TEXT, -- 'card_auth' | 'signed_form' | 'gov_id' | 'kba' | 'video_call'
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  revoked_at TIMESTAMPTZ,
  UNIQUE(child_id, consent_type)
);

CREATE INDEX idx_consent_records_child_id ON consent_records(child_id);
CREATE INDEX idx_consent_records_granted ON consent_records(granted);

-- ============================================================================
-- Child Progress Cache: Hourly aggregated stats
-- ============================================================================

CREATE TABLE child_progress_cache (
  id SERIAL PRIMARY KEY,
  child_id TEXT NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  time_range TEXT NOT NULL, -- 'this_week' | 'this_month' | 'all_time'
  attempt_count INT DEFAULT 0,
  success_percentage REAL DEFAULT 0,
  average_latency_ms REAL,
  average_snr_db REAL,
  cue_level_distribution JSONB, -- {0: count, 1: count, ...}
  cached_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  UNIQUE(child_id, time_range)
);

CREATE INDEX idx_child_progress_cache_child_id ON child_progress_cache(child_id);
CREATE INDEX idx_child_progress_cache_expires_at ON child_progress_cache(expires_at);

-- ============================================================================
-- Goals: IEP/clinical goals
-- ============================================================================

CREATE TABLE goals (
  id TEXT PRIMARY KEY,
  child_id TEXT NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  skill TEXT NOT NULL,
  baseline REAL,
  criterion REAL,
  target_date DATE,
  iep_linkage TEXT,
  status TEXT NOT NULL DEFAULT 'active', -- 'active' | 'completed' | 'paused' | 'discontinued'
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_goals_child_id ON goals(child_id);
CREATE INDEX idx_goals_status ON goals(status);

-- ============================================================================
-- Organization: Tenant/clinic management
-- ============================================================================

CREATE TABLE organizations (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  tenant_mode TEXT NOT NULL DEFAULT 'consumer', -- 'consumer' | 'institutional'
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add organization_id foreign key constraint retroactively
ALTER TABLE children ADD CONSTRAINT fk_children_organization
  FOREIGN KEY (organization_id) REFERENCES organizations(id);

-- ============================================================================
-- Views for common queries
-- ============================================================================

CREATE VIEW v_trial_details AS
SELECT
  t.trial_id,
  t.session_id,
  t.child_id,
  t.device_id,
  t.device_timestamp,
  t.server_timestamp,
  t.target_word,
  t.cue_level,
  t.score,
  t.tier1_vocalization_detected,
  t.tier1_latency_ms,
  t.tier1_snr_db,
  t.tier1_syllable_estimate,
  ar.s3_path,
  ar.duration_seconds,
  ar.sample_rate,
  t.audio_retention_expires,
  CASE
    WHEN t.audio_retention_expires IS NULL THEN 'unknown'::text
    WHEN t.audio_retention_expires < NOW() THEN 'expired'::text
    WHEN ar.s3_path IS NULL THEN 'not_found'::text
    ELSE 'available'::text
  END AS audio_status
FROM trial_events t
LEFT JOIN attempt_recordings ar ON t.trial_id = ar.trial_id;

-- ============================================================================
-- Permissions: RBAC for gRPC methods
-- ============================================================================

CREATE TABLE role_permissions (
  id SERIAL PRIMARY KEY,
  role TEXT NOT NULL, -- 'parent' | 'clinician' | 'admin'
  resource TEXT NOT NULL, -- 'trial' | 'audio' | 'config'
  action TEXT NOT NULL, -- 'read' | 'write' | 'delete'
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(role, resource, action)
);

INSERT INTO role_permissions (role, resource, action) VALUES
  ('parent', 'trial', 'read'),
  ('parent', 'audio', 'read'),
  ('parent', 'config', 'read'),
  ('clinician', 'trial', 'read'),
  ('clinician', 'audio', 'read'),
  ('clinician', 'audio', 'write'),
  ('clinician', 'config', 'write'),
  ('admin', 'trial', 'write'),
  ('admin', 'audio', 'write'),
  ('admin', 'config', 'write');
