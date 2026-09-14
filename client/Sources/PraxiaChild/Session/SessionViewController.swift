import SwiftUI
import Combine

/// Session lifecycle orchestrator for the child practice app.
///
/// Manages:
/// - Session state machine (started, paused, ended)
/// - Timer loop (10-min cap, ~80 trial cap)
/// - Auto-save every 30 seconds
/// - Resume-on-interrupt capability
/// - Proper cleanup on app background
@MainActor
class SessionViewController: ObservableObject {

    // MARK: - Published state

    @Published var sessionState: SessionState = .idle
    @Published var elapsedTime: TimeInterval = 0
    @Published var trialCount: Int = 0
    @Published var isPaused: Bool = false

    // MARK: - Configuration

    private let trialEngine: TrialEngine
    private let audioManager: AudioCaptureManager
    private let trialStore: TrialStore
    private let sessionID: String

    private var timerSubscription: AnyCancellable?
    private var saveSubscription: AnyCancellable?
    private var startTime: Date?

    // MARK: - Session limits

    private let maxSessionDuration: TimeInterval = 600  // 10 minutes
    private let maxTrialCount: Int = 80

    // MARK: - Initialization

    init(
        trialEngine: TrialEngine,
        audioManager: AudioCaptureManager,
        trialStore: TrialStore
    ) {
        self.trialEngine = trialEngine
        self.audioManager = audioManager
        self.trialStore = trialStore
        self.sessionID = UUID().uuidString
    }

    // MARK: - Public API

    /// Start a new session
    func startSession() {
        guard sessionState == .idle || sessionState == .paused else { return }

        if sessionState == .idle {
            startTime = Date()
            sessionState = .active
        } else {
            // Resume from pause
            sessionState = .active
            startTime = Date().addingTimeInterval(-elapsedTime)
        }

        isPaused = false
        setupTimerLoop()
        setupAutoSave()
    }

    /// Pause the session (can be resumed)
    func pauseSession() {
        guard sessionState == .active else { return }

        sessionState = .paused
        isPaused = true
        timerSubscription?.cancel()

        // Save current state
        saveSessionState()
    }

    /// End the session (cannot be resumed)
    func endSession() {
        sessionState = .ended
        isPaused = true

        timerSubscription?.cancel()
        saveSubscription?.cancel()

        // Final save
        saveSessionState()

        // Cleanup
        cleanupResources()
    }

    /// Record a trial attempt (called by PlaySurfaceView)
    func recordAttempt(
        targetID: String,
        score: TrialEngine.Score,
        parentScore: TrialEngine.Score? = nil,
        attemptDuration: TimeInterval,
        snrDb: Float
    ) async {
        guard sessionState == .active else { return }

        // Record in trial engine
        let result = await trialEngine.recordTrial(
            targetID: targetID,
            score: score,
            parentScore: parentScore,
            attemptDuration: attemptDuration,
            snrDb: snrDb
        )

        // Record in persistent store
        do {
            try await trialStore.recordTrial(
                childID: "placeholder-child-id",  // Will come from auth/config
                sessionID: sessionID,
                trialID: UUID().uuidString,
                targetID: targetID,
                cueLevel: result.currentLevel?.rawValue ?? 0,
                score: score.rawValue,
                parentScore: parentScore?.rawValue,
                duration: attemptDuration,
                snrDb: snrDb
            )
        } catch {
            // Graceful degradation: trial recorded in engine, store failed
            print("⚠️ Failed to persist trial: \(error)")
        }

        // Update trial counter
        trialCount += 1

        // Check session end conditions
        checkSessionEndConditions()
    }

    // MARK: - Private: Timer management

    private func setupTimerLoop() {
        timerSubscription = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateElapsedTime()
            }
    }

    private func updateElapsedTime() {
        guard let start = startTime else { return }

        let now = Date()
        elapsedTime = now.timeIntervalSince(start)

        // Check hard cap
        if elapsedTime >= maxSessionDuration {
            endSession()
        }
    }

    // MARK: - Private: Auto-save

    private func setupAutoSave() {
        saveSubscription = Timer.publish(every: 30.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.saveSessionState()
            }
    }

    private func saveSessionState() {
        // Encode session state to UserDefaults for resume capability
        let sessionData = SessionSnapshot(
            sessionID: sessionID,
            elapsedTime: elapsedTime,
            trialCount: trialCount,
            savedAt: Date()
        )

        do {
            let encoded = try JSONEncoder().encode(sessionData)
            UserDefaults.standard.set(encoded, forKey: "session_snapshot_\(sessionID)")
        } catch {
            print("⚠️ Failed to save session snapshot: \(error)")
        }
    }

    // MARK: - Private: Session end conditions

    private func checkSessionEndConditions() {
        // End on trial cap
        if trialCount >= maxTrialCount {
            endSession()
        }

        // CRITICAL: Never end on failure trial
        // Session ends only on success or time/trial limit
    }

    // MARK: - Private: Cleanup

    private func cleanupResources() {
        // Cleanup audio resources
        Task {
            _ = await audioManager.endAttempt()
        }

        // Cancel timers
        timerSubscription?.cancel()
        saveSubscription?.cancel()

        // Clean up old session snapshots (>7 days)
        let defaults = UserDefaults.standard
        let allKeys = defaults.dictionaryRepresentation().keys
        let sessionKeys = allKeys.filter { $0.hasPrefix("session_snapshot_") }

        for key in sessionKeys {
            if let data = defaults.data(forKey: key),
               let snapshot = try? JSONDecoder().decode(SessionSnapshot.self, from: data) {
                let age = Date().timeIntervalSince(snapshot.savedAt)
                if age > 7 * 24 * 3600 {  // 7 days
                    defaults.removeObject(forKey: key)
                }
            }
        }
    }

    // MARK: - Resume capability

    /// Check if there's a paused session to resume
    static func hasResumableSession() -> Bool {
        let defaults = UserDefaults.standard
        let allKeys = defaults.dictionaryRepresentation().keys
        let sessionKeys = allKeys.filter { $0.hasPrefix("session_snapshot_") }
        return !sessionKeys.isEmpty
    }

    /// Restore a paused session from snapshot
    func restoreFromSnapshot(_ snapshot: SessionSnapshot) {
        self.sessionID = snapshot.sessionID
        self.elapsedTime = snapshot.elapsedTime
        self.trialCount = snapshot.trialCount
        self.startTime = Date().addingTimeInterval(-snapshot.elapsedTime)
    }
}

// MARK: - Session state machine

enum SessionState: String, Codable {
    case idle      // Not started
    case active    // Running
    case paused    // Paused, can resume
    case ended     // Ended, cannot resume
}

// MARK: - Session snapshot (for persistence)

struct SessionSnapshot: Codable {
    let sessionID: String
    let elapsedTime: TimeInterval
    let trialCount: Int
    let savedAt: Date

    enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case elapsedTime = "elapsed_time"
        case trialCount = "trial_count"
        case savedAt = "saved_at"
    }
}
