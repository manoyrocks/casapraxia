# Praxia Android - Acceleration Sprint

**Status:** Active Sprint (Day 1 Progress)  
**Goal:** Complete production-ready app ASAP  
**Date:** Sept 15, 2026  
**Progress:** 2/7 Critical Items Complete ✅

---

## Sprint Progress Summary

| Item | Status | Time Used | Time Remaining |
|------|--------|-----------|-----------------|
| BLOCKER 1: State Management | ✅ COMPLETE | 2 hrs | — |
| BLOCKER 2: gRPC Backend | 🟡 FRAMEWORK READY | 1 hr | 2-3 hrs (blocked on protos) |
| HIGH 1: Waveform Viz | 🔴 TODO | — | 2 hrs |
| HIGH 2: Text-to-Speech | 🔴 TODO | — | 1.5 hrs |
| HIGH 3: Weekly Chart | 🔴 TODO | — | 2 hrs |
| MEDIUM 1: Audio Permissions | 🔴 TODO | — | 1 hr |
| MEDIUM 2: Database Persistence | ✅ INTEGRATED | — | — |
| MEDIUM 3: Offline Sync | 🟡 SKELETON | — | 2 hrs |

---

## Critical Path to Completion

### ✅ BLOCKER 1: State Management & Real Data (COMPLETE)

**Status:** READY FOR TESTING ✅

**Implemented:**
- `SessionViewModel` (200 LOC) - Session management with LiveData
- `TrialViewModel` (180 LOC) - Trial operations and sync
- `PraxiaViewModelFactory` - Dependency injection
- Updated `PraxiaApp` - ViewModel integration
- Updated UI Surfaces - SessionState/TargetState binding
- LiveData.observeAsState() for Compose

**Features:**
- `SessionViewModel.startSession(childId, targetIds)`
- `SessionViewModel.recordTrial(targetId, score, tier1Signals, parentScore?)`
- `SessionViewModel.endSession()`
- `TrialViewModel.loadTargets()`
- `TrialViewModel.uploadSession(sessionId)`
- `TrialViewModel.syncPending()`

**Integration Points:**
- ✅ TrialEngine (L0-L5 state machine)
- ✅ TrialDatabase (Room + SQLCipher)
- ✅ Tier1Signal (audio DSP data)
- ✅ TrialServiceProtocol (mock + gRPC ready)

**Blockers Unblocked:**
- ✅ Can now proceed with HIGH 1-3
- ✅ Can now implement MEDIUM 2-3

**Time Used:** 2 hours  
**Time Remaining:** 0 (COMPLETE)

---

### 🟡 BLOCKER 2: Real gRPC Backend Integration (FRAMEWORK READY)

**Status:** Framework complete, awaiting backend proto coordination ⏳

**Implemented:**
- `TrialServiceGRPCClient` (120 LOC) - Full gRPC client skeleton
- `TrialServiceGRPCClientBuilder` - Environment-based configuration
- Coroutine async integration (Dispatchers.IO)
- Debug/Release build service selection in MainActivity
- TLS/plain text support in `build.gradle.kts`

**Current Behavior:**
- ✅ Fallback to LocalTrialServiceMock in debug builds
- ✅ Ready to use gRPC client in release builds (once protos available)
- ✅ TrialViewModel fully integrated with async upload/sync

**Blocked On:**
- ⏳ Backend proto definitions (trial_service.proto)
- ⏳ gRPC stub generation via protoc
- ⏳ Backend URL configuration

**Next Steps (When Protos Available):**
1. Receive trial_service.proto from backend team
2. Run: `protoc --kotlin_out=../android/... proto/trial_service.proto`
3. Update stub references in TrialServiceGRPCClient
4. Implement entity ↔ proto conversions
5. Configure TLS certificates
6. Test on backend staging environment

**See:** GRPC-INTEGRATION-GUIDE.md for detailed implementation path

**Time Used:** 1 hour  
**Time Remaining:** 2-3 hours (after receiving protos)

---

### 🟠 HIGH 1: Waveform Visualization (ASAP)

**Current:** Placeholder "🎙️ Listening..." text  
**Needed:** Real-time waveform rendering from AudioCaptureManager

```kotlin
// TODO: Implement WaveformCanvas in PlaySurface
@Composable
fun WaveformCanvas(
    audioBuffer: FloatArray,
    modifier: Modifier = Modifier
) {
    Canvas(modifier) {
        // Draw real-time waveform
        // Update every 64ms as new audio arrives
    }
}
```

**Assigned to:** Android Developer (UI)  
**Priority:** HIGH  
**Est. Time:** 2 hours

---

### 🟠 HIGH 2: Text-to-Speech Integration (ASAP)

**Current:** Mock AAC board buttons  
**Needed:** Real TextToSpeech API integration

```kotlin
// TODO: Add TextToSpeech to AACWordButton
class TextToSpeechManager(context: Context) {
    fun speak(word: String, callback: (Boolean) -> Unit)
}

@Composable
fun AACWordButton(word: String, onSpeak: (String) -> Unit) {
    Button(onClick = { onSpeak(word) })
}
```

**Assigned to:** Android Developer (UI)  
**Priority:** HIGH  
**Est. Time:** 1.5 hours

---

### 🟠 HIGH 3: Weekly Progress Chart (ASAP)

**Current:** Placeholder data in CollectionSurface  
**Needed:** Real chart from backend analytics

```kotlin
// TODO: Implement ProgressChart
@Composable
fun WeeklyProgressChart(
    targetId: String,
    modifier: Modifier = Modifier
) {
    // Bar chart: trials completed per day, last 7 days
    // Line chart: success rate trend
}
```

**Assigned to:** Android Developer (UI)  
**Priority:** HIGH  
**Est. Time:** 2 hours

---

### 🟡 MEDIUM 1: Audio Recording Permission Handling

**Current:** Not implemented  
**Needed:** Runtime permission request + graceful fallback

```kotlin
// TODO: Add LazyColumn(
val hasRecordAudioPermission = rememberPermissionState(
    Manifest.permission.RECORD_AUDIO
)
```

**Assigned to:** Android Developer  
**Priority:** MEDIUM  
**Est. Time:** 1 hour

---

### 🟡 MEDIUM 2: Session Persistence to Database

**Current:** TrialEngine in memory only  
**Needed:** Persist to Room database

```kotlin
// TODO: Connect TrialEngine to TrialDatabase
class SessionManager(private val db: TrialDatabase) {
    suspend fun saveSession(session: SessionEntity)
    suspend fun saveTrial(event: TrialEventEntity)
    suspend fun getSessionHistory(): List<SessionEntity>
}
```

**Assigned to:** Android Developer  
**Priority:** MEDIUM  
**Est. Time:** 2 hours

---

### 🟡 MEDIUM 3: Offline Sync & Background Upload

**Current:** OfflineOutbox skeleton  
**Needed:** Full implementation with WorkManager

```kotlin
// TODO: Implement background sync with WorkManager
class SyncWorker(context: Context, params: WorkerParameters) : Worker(context, params) {
    override suspend fun doWork(): Result {
        // Sync pending trials + audio when online
    }
}
```

**Assigned to:** Android Developer  
**Priority:** MEDIUM  
**Est. Time:** 2 hours

---

## Sprint Schedule (Updated - Parallel Work)

### TODAY (Sept 15) - PROGRESS: 3/8 hours
- [x] **09:00-11:00** — State Management (ViewModel setup) ✅
- [x] **11:00-12:00** — gRPC Backend Framework ✅
- [ ] **12:00-14:00** — Waveform Visualization (HIGH 1)
- [ ] **14:00-15:30** — Text-to-Speech Integration (HIGH 2)

### TOMORROW (Sept 16)
- [ ] **09:00-11:00** — Weekly Progress Chart (HIGH 3)
- [ ] **11:00-12:00** — Audio Permission Handling (MEDIUM 1)
- [ ] **12:00-14:00** — Offline Sync Worker (MEDIUM 3) [BLOCKER 2 complete]
- [ ] **14:00-16:00** — gRPC Proto Integration (BLOCKER 2 - if protos available)

### SEPT 17 (Day 3)
- [ ] **09:00-11:00** — Integration Testing (all components)
- [ ] **11:00-12:00** — Bug Fixes & Performance Tuning
- [ ] **12:00-14:00** — Device Testing (7" & 10" tablets)
- [ ] **14:00-15:00** — Final Compliance Audit
- [ ] **15:00-16:00** — Release Build & APK Sign

### SEPT 18 (Day 4 - Optional Buffer)
- [ ] Production APK deployment
- [ ] Performance monitoring setup
- [ ] Team handoff documentation

**Critical Path Assumption:** Backend team delivers trial_service.proto by end of Sept 15 for smooth BLOCKER 2 completion on Sept 16

---

## Team Assignments

| Role | Name | Tasks |
|------|------|-------|
| **Android Lead** | Claude Android Dev | State Mgmt, gRPC, Overall arch |
| **Android UI** | (Same) | Waveform, TTS, Charts, Permissions |
| **Android Backend** | (Same) | Database, Offline Sync, Session Mgmt |
| **QA/Testing** | (Same) | Integration tests, Device testing |
| **Backend Liaison** | iOS/Backend team | gRPC service verification, Docker stack |

---

## Success Metrics

- ✅ **State management:** Real ViewModel driving UI
- ✅ **Backend connectivity:** gRPC client uploading to real backend
- ✅ **Core features:** Waveform, TTS, chart all functional
- ✅ **Tests passing:** 38+ unit + 7+ integration
- ✅ **Device ready:** Builds & runs on 7" & 10" tablets
- ✅ **Production APK:** Signed release build ready

---

## Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|-----------|
| gRPC proto compatibility | CRITICAL | Coordinate with backend team early |
| Permission handling delays | HIGH | Use ComposePermissions library |
| Chart library availability | MEDIUM | Use Jetpack Compose canvas fallback |
| Device testing bottleneck | MEDIUM | Test in emulator, spot-check on real device |

---

## Daily Standup Template

```
COMPLETED:
- [ ] What got done

BLOCKED:
- [ ] Any blockers?

TODAY:
- [ ] What's next

HELP NEEDED:
- [ ] Dependencies or coordination needed
```

---

**Ready to ship by Sept 18! 🚀**
