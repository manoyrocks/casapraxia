import Foundation

/// Trial engine implementing the cue hierarchy state machine.
///
/// Implements the specification from docs/02-product/clinical-program-spec.md
/// - L0–L5 temporal levels
/// - Four orthogonal cue dimensions: visual, gestural, rhythmic, frame
/// - Advancement: 3 consecutive correct → advance
/// - Back-off: 2 consecutive incorrect → back off immediately and silently
/// - Safety stop: <40% success over 10 trials at lowest level → auto-retire
actor TrialEngine {

    // MARK: - Scoring model

    enum Score: String, Codable {
        case correct = "got_it"
        case close = "close"
        case notYet = "not_yet"
    }

    // MARK: - Cue levels

    enum CueLevel: Int, Codable, Comparable {
        case level0 = 0  // Vocal play / elicit-only
        case level1 = 1  // Simultaneous, slowed
        case level2 = 2  // Simultaneous, normal rate
        case level3 = 3  // Immediate imitation
        case level4 = 4  // Delayed imitation (1–3 s)
        case level5 = 5  // Spontaneous (no model)

        static func < (lhs: CueLevel, rhs: CueLevel) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }

        /// Minimum available cue level (the "lowest support")
        static let minimum = Self.level0
        static let maximum = Self.level5

        /// Display name for clinician/parent
        var displayName: String {
            switch self {
            case .level0: return "Vocal play"
            case .level1: return "Together (slow)"
            case .level2: return "Together (normal)"
            case .level3: return "Repeat after me"
            case .level4: return "Try in a moment"
            case .level5: return "Say it yourself"
            }
        }
    }

    // MARK: - Orthogonal cue dimensions

    struct CueDimensions: Codable {
        enum Visual: Int, Codable {
            case closeUpVideo = 0
            case staticImage = 1
            case none = 2
        }

        enum Gestural: Int, Codable {
            case parentCue = 0
            case none = 1
        }

        enum Rhythmic: Int, Codable {
            case tapped = 0
            case sung = 1
            case none = 2
        }

        enum Frame: Int, Codable {
            case withFrame = 0
            case reduced = 1
            case none = 2
        }

        var visual: Visual = .closeUpVideo
        var gestural: Gestural = .parentCue
        var rhythmic: Rhythmic = .tapped
        var frame: Frame = .withFrame
    }

    // MARK: - Target state

    struct TargetState: Codable {
        let targetID: String
        let targetName: String
        let ipaTranscription: String

        /// Current temporal cue level
        var currentLevel: CueLevel = .level0

        /// Current orthogonal cue dimensions
        var dimensions: CueDimensions = CueDimensions()

        /// Consecutive correct trials at current level
        var consecutiveCorrect: Int = 0

        /// Consecutive incorrect trials at current level
        var consecutiveIncorrect: Int = 0

        /// Rolling window of last 10 trials (for safety stop)
        var recentTrials: [Score] = []

        /// Is this target retired?
        var retired: Bool = false

        /// Reason for retirement
        var retirementReason: RetirementReason?

        /// Session count at current level
        var sessionCount: Int = 0

        /// Total trial count
        var totalTrials: Int = 0

        enum RetirementReason: String, Codable {
            case mastered
            case safetyStop
            case clinicianRequest
        }

        /// Percentage of successes in recent trials
        var recentSuccessRate: Float {
            guard !recentTrials.isEmpty else { return 0 }
            let correct = recentTrials.filter { $0 == .correct }
            return Float(correct.count) / Float(recentTrials.count)
        }

        /// Check if safety stop should trigger
        var shouldTriggerSafetyStop: Bool {
            guard recentTrials.count >= 10 && currentLevel == .level0 else { return false }
            return recentSuccessRate < 0.4
        }
    }

    // MARK: - State

    private var targets: [String: TargetState] = [:]
    private var sessionID: String
    private let eventLog: EventLog

    // MARK: - Initialization

    init(sessionID: String, eventLog: EventLog = EventLog()) {
        self.sessionID = sessionID
        self.eventLog = eventLog
    }

    // MARK: - Public API

    /// Add a target to the current session
    func addTarget(
        targetID: String,
        name: String,
        ipaTranscription: String
    ) {
        let target = TargetState(
            targetID: targetID,
            targetName: name,
            ipaTranscription: ipaTranscription
        )
        targets[targetID] = target

        eventLog.record(event: .targetAdded(targetID: targetID, name: name, ipa: ipaTranscription))
    }

    /// Record a trial attempt
    /// Returns the cue level for the next trial (which may have advanced or backed off)
    func recordTrial(
        targetID: String,
        score: Score,
        parentScore: Score? = nil,
        attemptDuration: TimeInterval,
        snrDb: Float
    ) -> TrialResult {
        guard var target = targets[targetID] else {
            return TrialResult(error: "Target not found")
        }

        guard !target.retired else {
            return TrialResult(error: "Target is retired")
        }

        let currentLevel = target.currentLevel
        let dimensions = target.dimensions

        // Record the trial event
        let trialID = UUID().uuidString
        eventLog.record(event: .trialAttempted(
            trialID: trialID,
            targetID: targetID,
            cueLevel: currentLevel,
            dimensions: dimensions,
            score: score,
            parentScore: parentScore,
            duration: attemptDuration,
            snrDb: snrDb
        ))

        target.totalTrials += 1

        // Maintain rolling window of last 10 trials
        target.recentTrials.append(score)
        if target.recentTrials.count > 10 {
            target.recentTrials.removeFirst()
        }

        // Update consecutive counters
        if score == .correct {
            target.consecutiveCorrect += 1
            target.consecutiveIncorrect = 0

            // Check for advancement
            if target.consecutiveCorrect >= 3 {
                let result = advanceLevel(&target)
                targets[targetID] = target
                return result
            }
        } else {
            target.consecutiveIncorrect += 1
            target.consecutiveCorrect = 0

            // Check for back-off
            if target.consecutiveIncorrect >= 2 {
                let result = backOffLevel(&target)
                targets[targetID] = target
                return result
            }
        }

        // Check for safety stop
        if target.shouldTriggerSafetyStop {
            let result = safetyStop(&target)
            targets[targetID] = target
            return result
        }

        targets[targetID] = target
        return TrialResult(
            targetID: targetID,
            currentLevel: currentLevel,
            action: .none,
            message: nil
        )
    }

    /// Get the current state of a target
    func getTargetState(targetID: String) -> TargetState? {
        return targets[targetID]
    }

    /// Get all targets
    func getAllTargets() -> [TargetState] {
        return Array(targets.values)
    }

    /// Retire a target (clinician action)
    func retireTarget(targetID: String, reason: TargetState.RetirementReason) {
        guard var target = targets[targetID] else { return }

        target.retired = true
        target.retirementReason = reason

        eventLog.record(event: .targetRetired(
            targetID: targetID,
            reason: reason.rawValue
        ))

        targets[targetID] = target
    }

    // MARK: - Private: Advancement

    private func advanceLevel(_ target: inout TargetState) -> TrialResult {
        guard target.currentLevel < .level5 else {
            // Already at maximum
            return TrialResult(
                targetID: target.targetID,
                currentLevel: target.currentLevel,
                action: .none,
                message: nil
            )
        }

        let oldLevel = target.currentLevel
        target.currentLevel = CueLevel(rawValue: oldLevel.rawValue + 1) ?? .level5
        target.consecutiveCorrect = 0
        target.sessionCount += 1

        // Log advancement (but don't signal it to the child)
        eventLog.record(event: .cueAdvanced(
            targetID: target.targetID,
            from: oldLevel,
            to: target.currentLevel
        ))

        return TrialResult(
            targetID: target.targetID,
            currentLevel: target.currentLevel,
            action: .advanced,
            message: nil  // Silent to child
        )
    }

    // MARK: - Private: Back-off

    private func backOffLevel(_ target: inout TargetState) -> TrialResult {
        guard target.currentLevel > .level0 else {
            // Already at minimum
            return TrialResult(
                targetID: target.targetID,
                currentLevel: target.currentLevel,
                action: .none,
                message: nil
            )
        }

        let oldLevel = target.currentLevel
        target.currentLevel = CueLevel(rawValue: oldLevel.rawValue - 1) ?? .level0
        target.consecutiveIncorrect = 0

        // Log back-off (but don't signal it to the child)
        eventLog.record(event: .cueBackedOff(
            targetID: target.targetID,
            from: oldLevel,
            to: target.currentLevel
        ))

        return TrialResult(
            targetID: target.targetID,
            currentLevel: target.currentLevel,
            action: .backedOff,
            message: nil  // Silent to child
        )
    }

    // MARK: - Private: Safety stop

    private func safetyStop(_ target: inout TargetState) -> TrialResult {
        target.retired = true
        target.retirementReason = .safetyStop
        target.consecutiveCorrect = 0
        target.consecutiveIncorrect = 0

        eventLog.record(event: .targetRetiredSafety(
            targetID: target.targetID,
            recentSuccessRate: target.recentSuccessRate
        ))

        return TrialResult(
            targetID: target.targetID,
            currentLevel: target.currentLevel,
            action: .safetyStop,
            message: nil  // Parent sees this only in the review surface
        )
    }

    // MARK: - Event log

    func getEventLog() -> EventLog {
        return eventLog
    }
}

// MARK: - Trial Result

struct TrialResult {
    let targetID: String?
    let currentLevel: TrialEngine.CueLevel?
    let action: Action
    let message: String?
    let error: String?

    enum Action {
        case none
        case advanced
        case backedOff
        case safetyStop
    }

    init(
        targetID: String,
        currentLevel: TrialEngine.CueLevel,
        action: Action,
        message: String?
    ) {
        self.targetID = targetID
        self.currentLevel = currentLevel
        self.action = action
        self.message = message
        self.error = nil
    }

    init(error: String) {
        self.targetID = nil
        self.currentLevel = nil
        self.action = .none
        self.message = nil
        self.error = error
    }
}

// MARK: - Event log

enum TrialEvent: Codable {
    case targetAdded(targetID: String, name: String, ipa: String)
    case trialAttempted(
        trialID: String,
        targetID: String,
        cueLevel: TrialEngine.CueLevel,
        dimensions: TrialEngine.CueDimensions,
        score: TrialEngine.Score,
        parentScore: TrialEngine.Score?,
        duration: TimeInterval,
        snrDb: Float
    )
    case cueAdvanced(targetID: String, from: TrialEngine.CueLevel, to: TrialEngine.CueLevel)
    case cueBackedOff(targetID: String, from: TrialEngine.CueLevel, to: TrialEngine.CueLevel)
    case targetRetired(targetID: String, reason: String)
    case targetRetiredSafety(targetID: String, recentSuccessRate: Float)
    case reinforcementDelivered(trialID: String, latency: TimeInterval)

    enum CodingKeys: String, CodingKey {
        case eventType
        case payload
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .targetAdded(let tid, let name, let ipa):
            try container.encode("targetAdded", forKey: .eventType)
            try container.encode(["targetID": tid, "name": name, "ipa": ipa], forKey: .payload)
        case .trialAttempted(let tid, let targetID, let level, let dims, let score, let parentScore, let duration, let snr):
            try container.encode("trialAttempted", forKey: .eventType)
            var payload: [String: Any] = [
                "trialID": tid,
                "targetID": targetID,
                "cueLevel": level.rawValue,
                "score": score.rawValue,
                "duration": duration,
                "snrDb": snr
            ]
            if let ps = parentScore {
                payload["parentScore"] = ps.rawValue
            }
            try container.encode(payload, forKey: .payload)
        case .cueAdvanced(let targetID, let from, let to):
            try container.encode("cueAdvanced", forKey: .eventType)
            try container.encode(["targetID": targetID, "from": from.rawValue, "to": to.rawValue], forKey: .payload)
        case .cueBackedOff(let targetID, let from, let to):
            try container.encode("cueBackedOff", forKey: .eventType)
            try container.encode(["targetID": targetID, "from": from.rawValue, "to": to.rawValue], forKey: .payload)
        case .targetRetired(let targetID, let reason):
            try container.encode("targetRetired", forKey: .eventType)
            try container.encode(["targetID": targetID, "reason": reason], forKey: .payload)
        case .targetRetiredSafety(let targetID, let rate):
            try container.encode("targetRetiredSafety", forKey: .eventType)
            try container.encode(["targetID": targetID, "successRate": rate], forKey: .payload)
        case .reinforcementDelivered(let trialID, let latency):
            try container.encode("reinforcementDelivered", forKey: .eventType)
            try container.encode(["trialID": trialID, "latency": latency], forKey: .payload)
        }
    }

    init(from decoder: Decoder) throws {
        fatalError("Decoding not implemented for TrialEvent")
    }
}

actor EventLog {
    private var events: [TrialEvent] = []
    private let lock = NSLock()

    func record(event: TrialEvent) {
        lock.lock()
        defer { lock.unlock() }
        events.append(event)
    }

    func getAllEvents() -> [TrialEvent] {
        lock.lock()
        defer { lock.unlock() }
        return events
    }

    func getEventCount() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return events.count
    }
}
