/**
 * Praxia Web PWA - Shared Type Definitions
 * Aligned with iOS implementation and backend Protobuf contracts
 */

// ============================================================================
// ENUMS (matching backend praxia.v1 protos)
// ============================================================================

export enum CueLevel {
  UNSPECIFIED = 0,
  L0 = 1, // Independent production
  L1 = 2, // Visual cue
  L2 = 3, // Visual + tactile
  L3 = 4, // Verbal model
  L4 = 5, // Verbal model + tactile
  L5 = 6, // Maximal cueing
}

export enum ScoreValue {
  SCORE_UNSPECIFIED = 0,
  GOT_IT = 1,      // Correct production
  CLOSE = 2,       // Approximation
  NOT_YET = 3,     // Incorrect
  ABSTAIN = 4,     // Cannot score
}

export enum PitchContour {
  PITCH_UNSPECIFIED = 0,
  RISING = 1,
  FALLING = 2,
  LEVEL = 3,
  COMPLEX = 4,
}

// ============================================================================
// TIER-1 SIGNALS (deterministic, <100ms on web)
// ============================================================================

export interface Tier1Signals {
  vocalizationDetected: boolean;
  latencyMs: number;
  durationMs: number;
  syllableCount: number;
  pitchContour: PitchContour;
  snrDb: number; // Signal-to-noise ratio
  confidenceScore: number; // 0-1, confidence in detection
  timestamp: number; // Client timestamp (ms since epoch)
}

// ============================================================================
// TRIAL DOMAIN MODEL
// ============================================================================

export interface Trial {
  trialId: string; // UUID
  sessionId: string;
  childId: string;
  targetId: string;
  cueLevel: CueLevel;

  // Client-side metadata
  clientTimestamp: number;
  deviceId: string;
  platformId: string; // "web"

  // Audio capture
  audioData?: ArrayBuffer; // PCM data
  audioSha256?: string;

  // Tier-1 signal capture
  tier1Signals?: Tier1Signals;

  // Parent scoring
  score?: ScoreValue;
  scoreVersion: number; // Immutable trial log support (C9)
}

export interface TrialEvent {
  trialId: string;
  sessionId: string;
  childId: string;
  targetId: string;
  cueLevel: CueLevel;
  clientTs: number;

  // Tier-1 capture
  tier1Vocalization: boolean;
  tier1LatencyMs: number;
  tier1DurationMs: number;
  tier1SyllableCount: number;
  tier1PitchContour: PitchContour;
  tier1SnrDb: number;

  // Parent scoring
  score: ScoreValue;
  scoreVersion: number;

  // Upload tracking
  uploadedAt?: number;
  syncStatus: 'pending' | 'uploaded' | 'failed';
}

export interface Session {
  sessionId: string;
  childId: string;
  programId: string;
  startTime: number;
  endTime?: number;
  trialCount: number;
  completedTrialCount: number;
  status: 'active' | 'paused' | 'ended';
  autoSavedAt?: number;
}

// ============================================================================
// TRIAL ENGINE STATE MACHINE
// ============================================================================

export interface TargetState {
  targetId: string;
  word: string;
  currentLevel: CueLevel;
  successCount: number; // 3-up/2-down tracking
  failureCount: number;
  consecutiveCorrect: number;
  mastered: boolean;
  safetyStopTriggered: boolean;
  lastTrialAt?: number;
}

export interface TrialResult {
  targetState: TargetState;
  advancedLevel: boolean;
  backoffLevel: boolean;
  safetyStopTriggered: boolean;
  action: 'advance' | 'maintain' | 'backoff' | 'stop' | 'none';
}

// ============================================================================
// BACKEND INTEGRATION
// ============================================================================

export interface UploadSessionRequest {
  sessionId: string;
  childId: string;
  programId: string;
  trials: TrialEvent[];
  timestamp: number;
}

export interface UploadSessionResponse {
  sessionId: string;
  trialCount: number;
  uploadedAt: number;
  success: boolean;
}

export interface GetTargetsRequest {
  programId: string;
}

export interface Target {
  targetId: string;
  programId: string;
  word: string;
  ipa: string;
  category: string;
  difficultyScore: number;
  startingLevel: CueLevel;
  masteryTarget: number;
}

export interface GetTargetsResponse {
  targets: Target[];
}

// ============================================================================
// CONFIGURATION
// ============================================================================

export interface Program {
  programId: string;
  name: string;
  tenantMode: 'CONSUMER' | 'INSTITUTIONAL';
  trialsPerDay: number;
  maxSessionLenSec: number;
  safetyStopPct: number;
}

// ============================================================================
// STORAGE SCHEMAS (IndexedDB)
// ============================================================================

export interface StoredSession extends Session {
  // Extends with storage metadata
  encryptedAt?: number;
  lastSyncedAt?: number;
}

export interface StoredTrial extends TrialEvent {
  // Extends with storage metadata
  encryptedAt?: number;
  audioBlob?: Blob;
  audioSha256?: string;
}

export interface AudioBlob {
  audioBlobId: string;
  trialId: string;
  blob: Blob;
  sha256: string;
  sizeBytes: number;
  uploadedAt?: number;
  syncStatus: 'pending' | 'uploaded' | 'failed';
}

export interface ConfigCache {
  key: string;
  value: string;
  cachedAt: number;
  expiresAt: number;
}

// ============================================================================
// UI COMPONENT PROPS
// ============================================================================

export interface PlaySurfaceProps {
  session: Session;
  currentTarget: Target;
  tier1Signals?: Tier1Signals;
  onScoreSubmit: (score: ScoreValue) => void;
  isRecording?: boolean;
}

export interface TalkSurfaceProps {
  words: string[];
  onWordSelect: (word: string) => void;
}

export interface CollectionSurfaceProps {
  session: Session;
  targets: TargetState[];
  trials: TrialEvent[];
}

export interface ParentPanelProps {
  session: Session;
  tier1Signals?: Tier1Signals;
  targetState?: TargetState;
  isVisible: boolean;
  onClose?: () => void;
}

// ============================================================================
// CONSTRAINT COMPLIANCE TYPES (19 inviolable)
// ============================================================================

export interface ComplianceAudit {
  c1_NoMachineVerdictToChild: boolean;
  c2_NoFailureStates: boolean;
  c3_SilentBackOff: boolean;
  c4_SafetyStopUnder40Pct: boolean;
  c5_LatencyUnder150Ms: boolean;
  c6_AudioConfigNoAecAgc: boolean;
  c7_NoAutoSpeechRecognition: boolean;
  c8_ImmutableTrials: boolean;
  c9_MultipleScoreRows: boolean;
  c10_PerChildEncryption: boolean;
  c11_OfflineFirstSync: boolean;
  c12_GdprDeletion: boolean;
  c13_NoThirdPartyAnalytics: boolean;
  c14_CoppaConsent: boolean;
  c15_FerpaSchoolOfficial: boolean;
  c16_AudioRetention90d: boolean;
  c17_NoChildVisibleNetworkErrors: boolean;
  c18_TouchTargets64px: boolean;
  c19_DeterministicTier1Signals: boolean;
}
