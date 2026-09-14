# Android Developer Brief: Praxia Child Speech Therapy App

**Project:** Praxia — Clinical speech therapy platform for non-verbal children with Childhood Apraxia of Speech (CAS)  
**Platform:** Android (Kotlin)  
**Duration:** 3-4 weeks (target Oct 15, 2026)  
**Responsive Design:** 7-inch (600px), 10-inch (800px), plus phones (320-480px) and large tablets (1024px+)

---

## Executive Summary

**Reuse:** Rust DSP core + gRPC backend (already production-ready)  
**Build:** Kotlin/Android UI + Audio APIs + gRPC client  
**Feature Parity:** 95% with iOS (same three surfaces: Play, Talk, Collection)  
**Latency Target:** <50-100ms (Android audio slightly higher than iOS native, but acceptable)  
**Constraint Compliance:** All 19 inviolable constraints must be verified

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│ Android Child App (Kotlin + Jetpack Compose)       │
├─────────────────────────────────────────────────────┤
│ ┌─ Audio Capture (MediaRecorder / AudioRecord)    │
│ ├─ Tier-1 DSP Ring Buffer (Rust FFI via JNI)      │
│ ├─ Local SQLite DB (encrypted, EncryptedSharedPreferences) │
│ ├─ Trial Engine (state machine, cue hierarchy)    │
│ ├─ gRPC Client (grpc-kotlin)                       │
│ └─ UI Layer (Jetpack Compose, responsive layout)  │
└─────────────────────────────────────────────────────┘
                          │
                    gRPC (50051)
                          │
                ┌─────────▼──────────┐
                │ Backend (Go)       │
                │ PostgreSQL + NATS  │
                └────────────────────┘
```

---

## Detailed Requirements

### 1. Responsive Design (CRITICAL)

**Screen Sizes:**
- **Phone (5-6"):** 320px - 480px width
- **Phablet (5.5-6.5"):** 480px - 600px width
- **Tablet 7":** 600px - 800px width (≥600dp)
- **Tablet 10":** 800px - 1024px width (≥720dp)
- **Large Tablet:** 1024px+ width

**Layout Rules:**
- Mobile: Single column, full-width buttons (≥64dp)
- 7" Tablet: Two-column grid where applicable
- 10" Tablet: Three-column grid + sidebar navigation
- Touch targets: Minimum 48-64dp (match iOS)
- Orientation: Portrait + Landscape support

**Jetpack Compose Responsive:**
```kotlin
@Composable
fun ResponsiveLayout() {
    val windowSizeClass = calculateWindowSizeClass(activity = this)
    
    when (windowSizeClass.widthSizeClass) {
        WindowWidthSizeClass.Compact -> MobileLayout()      // <600dp
        WindowWidthSizeClass.Medium -> TabletLayout()       // 600-840dp
        WindowWidthSizeClass.Expanded -> LargeTabletLayout() // >840dp
    }
}
```

### 2. Audio Capture & Tier-1 DSP

**Requirement:** Tier-1 signals identical to iOS

**Implementation:**
1. **AudioRecord (Android native):**
   - Sample rate: 16 kHz
   - Channels: Mono
   - Format: PCM 16-bit
   - Buffer: 1024 samples (64ms blocks)

2. **Rust DSP Core (via JNI):**
   - Reuse iOS Rust core, expose JNI bindings
   - Functions:
     - `compute_tier1_signals(audio_buffer: &[i16]) -> Tier1Signals`
     - `ring_buffer_push(sample: i16) -> Option<Tier1Signals>`
   - Latency: <50ms (ring buffer + DSP)

3. **Tier-1 Signals:**
   - Vocalization detected (bool)
   - Latency (ms)
   - Duration (ms)
   - Syllable count (int)
   - Pitch contour (enum)
   - SNR (dB, float)
   - Abstention reason (if SNR <18dB)

**JNI Binding:**
```kotlin
object TierOneDSP {
    external fun computeTier1(audioBuffer: ShortArray): Tier1SignalsNative
    external fun ringBufferPush(sample: Short): Tier1SignalsNative?
    
    companion object {
        init {
            System.loadLibrary("tier1_dsp") // libtier1_dsp.so
        }
    }
}
```

### 3. Local Data Persistence

**SQLite + Android Security:**
- Database: SQLite (Room ORM)
- Encryption: SQLCipher + EncryptedSharedPreferences
- Retention: 90-day audio policy
- Immutability: Append-only trial_events table (no UPDATE/DELETE)

**Room Entity:**
```kotlin
@Entity(tableName = "trial_events")
data class TrialEvent(
    @PrimaryKey val trialId: String,
    val sessionId: String,
    val childId: String,
    val targetId: String,
    val cueLevel: Int,
    val clientTs: Long,
    val tier1Vocalization: Boolean,
    val tier1LatencyMs: Int,
    val tier1SnrDb: Float,
    // ... more fields
)
```

### 4. Trial Engine (Port from iOS)

**Reuse Logic from TrialEngine.swift:**
- L0-L5 cue hierarchy
- 3-up/2-down advancement rule
- Safety stop <40% success rate
- Silent back-off (no child-visible signal)
- Aversion detection thresholds

**Kotlin Implementation:**
```kotlin
class TrialEngine(val db: TrialDatabase) {
    fun recordTrial(trial: Trial, score: Score): TrialResult
    fun getTargetState(targetId: String): TargetState
    fun backOffLevel(targetId: String): Boolean
    fun advanceLevel(targetId: String): Boolean
}
```

### 5. gRPC Client Integration

**Dependencies:**
```gradle
implementation("io.grpc:grpc-kotlin-stub:1.50.0")
implementation("io.grpc:grpc-protobuf-lite:1.50.0")
implementation("com.google.protobuf:protobuf-kotlin-lite:3.22.0")
```

**Generated Protobuf Stubs:**
- Use existing Go `trial.pb.go`, `audio.pb.go`, `config.pb.go`
- Generate Kotlin stubs: `protoc --kotlin_out=...`
- Services:
  - `TrialService.UploadSession()`
  - `AudioService.PresignAudioUpload()`
  - `ConfigService.GetTargets()`

**Kotlin gRPC Client:**
```kotlin
class TrialServiceClient(host: String, port: Int) {
    private val channel = ManagedChannelBuilder
        .forAddress(host, port)
        .usePlaintext()
        .build()
    
    private val stub = TrialServiceGrpcKt.TrialServiceCoroutineStub(channel)
    
    suspend fun uploadSession(request: UploadSessionRequest): UploadSessionResponse {
        return stub.uploadSession(request)
    }
}
```

### 6. UI Layer (Jetpack Compose)

**Three Surfaces (responsive):**

#### Play Surface
- Waveform visualization (Canvas, responsive)
- Parent scoring overlay (3 buttons, ≥64dp)
- Target word display (large, readable)
- Session timer + trial counter
- Responsive: Mobile (full-width), Tablet (side-by-side)

#### Talk Surface
- AAC board (text-to-speech)
- Word grid: 2x3 (phone), 3x4 (7"), 4x5 (10")
- Touch targets: 48-64dp based on screen size
- Voice output: TextToSpeech API

#### Collection Surface
- Target word list + progress
- Cue level badges (L0-L5)
- Session history (scrollable)
- Weekly chart (Charts library or custom Canvas)

**Parent Panel (Responsive Toggle):**
- Desktop (>600dp): Permanent sidebar
- Mobile (<600dp): Toggle button → overlay
- Displays: Tier-1 signals, cue tracking, coaching

### 7. Constraint Compliance (19 Inviolable)

**Verify All in Code:**
- C1: No machine verdict to child
- C2: No failure states (no red UI)
- C3: Silent back-off
- C4: Safety stop <40%
- C5: ≤50ms latency (Android acceptable range)
- C6: Audio API configuration (no AEC/AGC)
- C7: No ASR
- C8: Immutable trials
- C9: Multiple score rows
- C10-C19: Encryption, GDPR, COPPA, offline-first, etc.

**Compliance Audit Checklist:**
```kotlin
object ConstraintAudit {
    fun c1_NoMachineVerdictToChild(): Boolean = 
        // Trial.score is parent-entered only, never machine
    
    fun c2_NoFailureStates(): Boolean = 
        // PlaySurfaceView never shows red, error, or negative language
    
    // ... 17 more compliance checks
}
```

### 8. Testing Requirements

**Unit Tests (30+):**
- TrialEngine: L0-L5 hierarchy, 3-up/2-down, safety stop
- AudioCapture: Latency benchmarking, vocalization detection
- LocalDatabase: Persistence, encryption, GDPR deletion
- gRPC Client: Offline retry, batch upload

**Integration Tests (7+):**
- End-to-end 10-trial session (mock backend)
- Audio capture → Tier-1 → Trial storage → Upload
- Configuration load → Target selection → Session start

**Test Fixture Audio (reuse iOS fixtures):**
- Clear vocalizations
- Weak vocalizations
- Background noise (false positive prevention)
- CAS-specific patterns

### 9. Deliverables (By Oct 15)

- [ ] `android/` directory with full Gradle project
- [ ] `AudioCaptureManager.kt` (300 LOC) + Rust JNI bindings
- [ ] `TrialEngine.kt` (350 LOC, ported from iOS)
- [ ] `PlaySurfaceView.kt`, `TalkSurfaceView.kt`, `CollectionSurfaceView.kt` (responsive Compose)
- [ ] `ParentPanel.kt` (responsive, desktop sidebar / mobile overlay)
- [ ] `TrialServiceClient.kt` (gRPC client, session upload)
- [ ] `TrialDatabase.kt` (Room ORM, SQLCipher encrypted)
- [ ] `AndroidManifest.xml` (permissions: RECORD_AUDIO, INTERNET, READ_EXTERNAL_STORAGE)
- [ ] 30+ unit tests + 7 integration tests
- [ ] `ANDROID.md` (150 LOC: build instructions, testing, deployment)
- [ ] `COMPLIANCE-AUDIT-ANDROID.md` (constraint verification)
- [ ] `APK` binary (signed, debuggable)

### 10. Build & Deployment

**Local Build:**
```bash
cd android
./gradlew build                      # Unit tests
./gradlew connectedAndroidTest       # Device/emulator tests
./gradlew assembleDebug              # APK generation
```

**Device Testing:**
```bash
adb install -r app/build/outputs/apk/debug/app-debug.apk
adb shell am start -n com.praxia/.MainActivity
```

**Docker Compose (Android Emulator):**
```bash
cd backend && make docker-up
# In Android Studio emulator:
# Connect to gRPC server on 10.0.2.2:50051 (emulator special host)
```

---

## Key Decisions

✅ **Kotlin + Jetpack Compose** — Modern, expressive, responsive by design  
✅ **Rust FFI for DSP** — Reuse iOS core, ensure identical Tier-1 signals  
✅ **gRPC client** — Same backend API as iOS, zero divergence  
✅ **Room ORM** — Type-safe database access, encryption built-in  
✅ **Offline-first** — SQLite local outbox, deferred gRPC upload  
✅ **Responsive Compose** — Window size classes handle all screen sizes

---

## Success Criteria

- ✅ All 19 constraints verified in code
- ✅ Latency <50ms Tier-1 DSP (Android audio subsystem acceptable)
- ✅ 30+ unit tests passing
- ✅ 7+ integration tests passing (mock backend)
- ✅ Responsive design verified: 5", 7", 10" tablets
- ✅ Offline session recording + background upload
- ✅ gRPC integration with production backend
- ✅ No machine verdict shown to child
- ✅ No failure states in UI
- ✅ COMPLIANCE-AUDIT-ANDROID.md signed off

---

## Timeline

| Week | Milestone | Deliverables |
|------|-----------|--------------|
| Week 1 | Audio + DSP | AudioCaptureManager, JNI bindings, latency benchmarks |
| Week 2 | UI + Trial Engine | PlaySurface, TalkSurface, Collection, TrialEngine port |
| Week 3 | Integration | gRPC client, session upload, mock backend tests |
| Week 4 | Hardening | Compliance audit, 30+ tests, APK build, documentation |

---

## Next Steps

1. Set up Android Studio project with Gradle
2. Clone/import Rust DSP core, create JNI bindings
3. Define Jetpack Compose responsive layouts (mobile + 7" + 10")
4. Port TrialEngine logic from iOS Swift
5. Implement gRPC client for session upload
6. Run local integration tests against Docker backend
7. Final compliance audit (19/19 constraints)

---

**Ready to build. Responsive design priority: 7-inch and 10-inch tablets + phone support.**

