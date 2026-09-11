# Developer Guide — Praxia Implementation

**Last updated:** September 11, 2026

---

## Quick Start

### Prerequisites
- macOS 13+ with Xcode 15+
- Swift 5.9+
- Git

### Build the child client

```bash
cd /home/user/casapraxia/client
swift build

# Run tests
swift test
```

### Run CI checks locally

```bash
cd /home/user/casapraxia

# Audio config checks
grep "\.measurement" client/Sources/PraxiaChild/Audio/AudioCaptureManager.swift
grep "setVoiceProcessingEnabled(false)" client/Sources/PraxiaChild/Audio/AudioCaptureManager.swift

# Safety stop logic
grep "recentSuccessRate < 0.4" client/Sources/PraxiaChild/Trial/TrialEngine.swift

# Run tests
swift test --filter TrialEngineTests
swift test --filter AudioCaptureTests
```

---

## Architecture Overview

### Three-tier design

```
┌─────────────────────────────────────────────┐
│  Child Experience (SwiftUI)                  │
│  - ChildViewController (3 surfaces)          │
│  - AACSurfaceView (Talk)                     │
│  - PlaySurfaceView (Practice)                │
│  - CollectionSurfaceView (Progress)          │
└─────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────┐
│  Trial Engine & Audio Pipeline               │
│  - TrialEngine (state machine)               │
│  - AudioCaptureManager (Tier-1 signals)      │
│  - TrialStore (persistence)                  │
└─────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────┐
│  Local Storage (encrypted)                   │
│  - GRDB + SQLCipher                          │
│  - Append-only event log                     │
│  - No network calls on critical path         │
└─────────────────────────────────────────────┘
```

### Key modules

| Module | File | Responsibility |
|--------|------|-----------------|
| **AudioCaptureManager** | `Audio/AudioCaptureManager.swift` | 16 kHz capture, Tier-1 DSP, VAD, latency |
| **TrialEngine** | `Trial/TrialEngine.swift` | Cue hierarchy state machine, advancement/back-off/safety-stop |
| **TrialStore** | `Storage/TrialStore.swift` | GRDB persistence, append-only log, GDPR deletion |
| **ChildViewController** | `UI/ChildViewController.swift` | Session management, surface navigation, session cap |

---

## Critical Design Decisions

### 1. Audio capture: 16 kHz mono, AEC/AGC disabled

**Why:** Accuracy of formant tracking and spectral measures depends on amplitude and phase preservation.

**Where:** `AudioCaptureManager.configureAudioSession()`

**Test:** CI gate checks for `.measurement` mode and `setVoiceProcessingEnabled(false)`.

```swift
try session.setCategory(.measurement, options: [])
inputNode.setVoiceProcessingEnabled(false)
```

### 2. Trial engine: Three-part advancement rule

| Rule | Implementation | Test |
|------|-----------------|------|
| Advance: 3 consecutive correct | `consecutiveCorrect >= 3` → level+1 | `testAdvancesAfter3ConsecutiveCorrect()` |
| Back-off: 2 consecutive incorrect | `consecutiveIncorrect >= 2` → level-1 (silent) | `testBacksOffAfter2ConsecutiveIncorrect()` |
| Safety stop: <40% over 10 trials | `recentSuccessRate < 0.4 && currentLevel == L0` | `testSafetyStopsBelow40Percent()` |

**Silent back-off is critical:** The child must never see a demotion or hear it. It appears as "we're doing it together again."

```swift
private func backOffLevel(_ target: inout TargetState) -> TrialResult {
    target.currentLevel = CueLevel(rawValue: oldLevel.rawValue - 1) ?? .level0
    target.consecutiveIncorrect = 0
    
    // Log it, but return action: .none to child
    return TrialResult(
        targetID: target.targetID,
        currentLevel: target.currentLevel,
        action: .backedOff,
        message: nil  // Silent
    )
}
```

### 3. Session cap: 10 minutes or 80 trials

**Why:** Fatigue + aversion prevention. Session ends itself; parent has no decision to make.

**Where:** `ChildViewController.startSession()`

```swift
// Hard cap: session ends at 10 minutes
if elapsedTime >= 600 {
    sessionActive = false
}

// Or at ~80 trials
if trialCount >= 80 {
    endSession()
}
```

### 4. Append-only event log with no deletes

**Why:** Research reproducibility, audit trail, regulatory compliance.

**Where:** `TrialStore` schema (no UPDATE/DELETE on trial_events table).

```sql
CREATE TABLE trial_events (
    event_id TEXT PRIMARY KEY,
    child_id TEXT NOT NULL,
    -- Never deleted, only logically archived --
    client_ts TEXT NOT NULL,
    server_ts TEXT NOT NULL,
    ...
)
```

**Exception:** GDPR/CCPA right to erasure (DELETE full child record, with receipt).

---

## How to Add a New Feature

### 1. Red-flag screening

**Requirements:**
- Hard interrupt at onboarding
- No soft warnings; blocks forward progress
- Routes to referral guidance (not in-app)

**Implementation steps:**
1. Create `Onboarding/ScreeningModule.swift`
2. Add screening questions (dysphagia, regression, hearing, seizures, etc.)
3. In ChildViewController, block surface entry if any flag positive
4. Return referral links (not error messages)

**Example:**
```swift
struct ScreeningModule {
    var dysphagia: Bool = false
    var regression: Bool = false
    var hearingUnconfirmed: Bool = false
    var seizures: Bool = false
    
    var isBlocked: Bool {
        return dysphagia || regression || hearingUnconfirmed || seizures
    }
}
```

### 2. Tier-2 signals (DTW, syllable segmentation)

**Requirements:**
- Runs on-device (not on server)
- Falls back to Tier-1 if unavailable
- ≤200 ms latency (not on critical path)

**Implementation steps:**
1. Create `Audio/Tier2Processor.swift`
2. Implement DTW vs. child's exemplar bank (k-NN)
3. Add to `AudioCaptureManager.processTap()` as async task
4. Route results to parent review UI (not child)

**Example:**
```swift
actor Tier2Processor {
    func computeDTW(attempt: [Float], exemplars: [[Float]]) -> (distance: Float, confidence: Float) {
        // k-NN over child's best prior productions
        let distances = exemplars.map { exemplar in
            dtw(attempt, exemplar)
        }
        return (distances.min() ?? .infinity, /* k-NN confidence */)
    }
}
```

### 3. Parent scoring UI (3-tap overlay)

**Requirements:**
- Appears after child's attempt
- ≤1 second per trial
- Optional (silence = unscored)
- Positioned for non-dominant hand (bottom-right)

**Implementation steps:**
1. Add to `PlaySurfaceView`
2. Show after reinforcement animation (not during)
3. Dim automatically after 3 seconds (no forced interaction)
4. Route score to `TrialEngine.recordTrial(score: parentScore)`

**Example:**
```swift
struct ParentScoringOverlay: View {
    let onScore: (TrialEngine.Score) -> Void
    
    var body: some View {
        VStack {
            Button(action: { onScore(.correct) }) {
                Text("✓").font(.title)
            }
            Button(action: { onScore(.close) }) {
                Text("~").font(.title)
            }
            Button(action: { onScore(.notYet) }) {
                Text("✗").font(.title)
            }
        }
        .frame(width: 60, height: 180)
        .position(x: UIScreen.main.bounds.width - 40, y: UIScreen.main.bounds.height - 200)
    }
}
```

### 4. Clinician target selection backend

**Requirements:**
- Inventory-driven (only offer shapes child can do + 1)
- Inventory snapshot auto-updated from trials
- Clinician picks from allowed set

**Implementation steps:**
1. Add to backend: `POST /targets/create` (clinician only)
2. Validate against child's syllable-shape inventory
3. Return 400 if invalid
4. Push to child app at sync time

**Example (OpenAPI):**
```yaml
POST /targets/create:
  requestBody:
    properties:
      childID:
        type: string
      targetID:
        type: string
      syllableShape:
        type: string
        enum: [V, CV, VC, CVCV_reduplicated, CVCV_varied, CVC, CVCVC]
  responses:
    '201': Created
    '400': "Syllable shape not in child's inventory"
```

---

## Testing Best Practices

### Property-based tests for state machine

Use property tests to verify invariants **hold for all paths**.

```swift
func testNoPathLeavesChildFailingRepeatedly() async {
    // Generate 100 random score sequences
    for _ in 0..<100 {
        let randomScores = (0..<30).map { _ in
            [TrialEngine.Score.correct, .close, .notYet].randomElement()!
        }
        
        for score in randomScores {
            _ = await engine.recordTrial(targetID: "test", score: score, ...)
        }
        
        let target = engine.getTargetState(targetID: "test")!
        
        // Invariant: target must eventually retire (safety stop fires)
        XCTAssertTrue(target.retired, "Safety stop must guarantee retirement")
    }
}
```

### Fixture regression for audio

Pre-record samples and replay through DSP to verify bit-exact consistency.

```swift
func testFixtureAudioProcessing() throws {
    let fixture = try loadFixture("ba_attempt_1.wav")
    let signals = computeTier1Signals(fixture.pcmData, ...)
    
    // Expected baseline (from known-good run)
    XCTAssertEqual(signals.syllableEstimate, 1)
    XCTAssertEqual(signals.pitchTrend, .flat, accuracy: 1)
}
```

### Latency verification

Measure wall-clock time to ensure Tier-1 stays under budget.

```swift
func testTier1ComputationDoesNotExceedBudget() {
    let start = Date()
    let signals = computeTier1Signals(...)
    let elapsed = Date().timeIntervalSince(start)
    
    XCTAssertLess(elapsed, 0.050, "Must complete in <50ms (target: 30ms)")
}
```

---

## Constraints You Cannot Violate

### §3 Inviolable Constraints

These are **non-negotiable**. Any PR touching these requires explicit review and justification.

1. **No machine verdict reaches child** — Tier-1 signals only, no accuracy judgment
2. **No failure states** — No red UI, error messages, buzzers, health bars
3. **Support fades silently** — Back-off: no animation or sound
4. **Safety stop is mandatory** — <40% over 10 trials at L0 → retire
5. **Session ends itself** — 10 min or 80 trials, never on failure
6. **Cue level is first-class** — Recorded on every trial
7. **No ASR as arbiter** — No Whisper/OpenAI models for scoring accuracy
8. **AAC is free & ungated** — Never earn, never remove, never gate
9. **Offline-first** — All critical path local
10. **Latency budgets** — Vocalization→reinforcement ≤150ms, offset→feedback ≤300ms

**If a requirement forces a violation**, stop and escalate. Do not silently resolve it.

---

## Code Review Checklist

### Audio capture changes
- [ ] AVAudioSession is `.measurement` mode
- [ ] Voice processing explicitly disabled
- [ ] Sample rate verified as 16 kHz
- [ ] No third-party audio SDKs

### Trial engine changes
- [ ] Advancement rule: 3 consecutive correct
- [ ] Back-off rule: 2 consecutive incorrect (silent)
- [ ] Safety stop: <40% over 10 trials at L0
- [ ] Cue level recorded on every trial
- [ ] Event log append-only (no DELETE statements on trial_events)

### UI changes
- [ ] No red/error/failed keywords in child surface
- [ ] No timer visible to child
- [ ] No scoring UI that implies machine verdict
- [ ] All parent-only info dim/greyed out

### New modules
- [ ] Tests included (property-based or fixture regression)
- [ ] Async-safe (using actor/DispatchQueue where needed)
- [ ] Off critical path (no blocking network calls)
- [ ] Offline-compatible

---

## Debugging Tips

### Audio not capturing

```swift
// Check AVAudioSession config
let session = AVAudioSession.sharedInstance()
print("Category:", session.category)
print("Mode:", session.mode)
print("Options:", session.categoryOptions)

// Check engine state
let engine = AVAudioEngine()
print("Engine running:", engine.isRunning)
print("Input node available:", engine.inputNode.engine != nil)
```

### Trial engine stuck at level 0

```swift
let target = engine.getTargetState(targetID: "test-target")!
print("Level:", target.currentLevel)
print("Consecutive correct:", target.consecutiveCorrect)
print("Consecutive incorrect:", target.consecutiveIncorrect)
print("Recent trials:", target.recentTrials)
print("Retired:", target.retired, "Reason:", target.retirementReason ?? "N/A")
```

### Storage not persisting

```swift
// Verify database is unlocked
let store = try TrialStore(path: "...", encryptionKey: "...")
let count = try store.getEventCount()
print("Events in database:", count)

// Manually query
let records = try store.getTrialsForSession(childID: "...", sessionID: "...")
print("Retrieved records:", records.count)
```

---

## Performance Profiling

### Audio processing latency

Use Xcode's Time Profiler to verify Tier-1 stays under 30 ms:

```bash
Product → Profile → Time Profiler
Record for 30 seconds during a practice session
Filter for: AudioCaptureManager, processTap
Inspect: self_ms (should be <30ms per frame)
```

### Memory usage

Practice session should not exceed 50 MB peak:

```swift
var totalMemory = 0
Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
    let stats = Darwin.malloc_statistics_t()
    Darwin.malloc_stats_print(...)
    print("Memory: \(stats.size_in_use / 1_000_000) MB")
}
```

---

## Next Phase: What to Build

See `IMPLEMENTATION.md` section "What's Next" for prioritized list.

**Immediate (next 2 weeks):**
1. Parent dashboard scaffolding (Next.js)
2. Clinician portal backend (NestJS)
3. Consent/revocation module
4. Onboarding red-flag screening

**After that:**
1. Tier-2 signals (DTW)
2. AAC integration (mirror mode)
3. Maintenance probes
4. SLP labelling workflow

---

## Asking for Help

### Bug report template

```markdown
## Title
[Brief description]

## Reproduction
1. [Step 1]
2. [Step 2]
3. [Observe issue]

## Expected behavior
[What should happen]

## Actual behavior
[What does happen]

## Environment
- iOS/iPadOS version
- Device model (esp. microphone type)
- App version
- Date/time of occurrence

## Relevant code
[Paste TrialEngine state, AudioCaptureManager config, etc.]

## Is this a constraint violation?
- [ ] §3 constraint
- [ ] Latency budget
- [ ] Offline capability
- [ ] Other safety issue
```

### Design review template

```markdown
## Feature proposal
[What's being added]

## Why it matters
[Clinical or product justification]

## Impact on constraints
- Safety stop logic? [Yes/No/How]
- Cue hierarchy? [Yes/No/How]
- Audio quality? [Yes/No/How]
- Latency budgets? [Yes/No/How]

## Proposed implementation
[Code sketch or pseudocode]

## Risks
[What could go wrong]
```

---

## References

- **UNIFIED-BUILD-PROMPT:** `docs/08-prompts/UNIFIED-BUILD-PROMPT.md`
- **Clinical spec:** `docs/02-product/clinical-program-spec.md`
- **Architecture:** `docs/04-engineering/technical-architecture.md`
- **Data model:** `docs/04-engineering/data-model-and-events.md`
- **Speech signal spec:** `docs/04-engineering/speech-signal-spec.md`
- **Implementation status:** `IMPLEMENTATION.md`
