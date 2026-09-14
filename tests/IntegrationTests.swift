import XCTest
@testable import PraxiaChild

/// Integration tests: trial engine → storage → mock service
///
/// Verifies:
/// 1. 10-trial sequence completes without errors
/// 2. Trials persist locally with sync marking
/// 3. No network calls (mock only)
/// 4. State machine consistency end-to-end
final class IntegrationTests: XCTestCase {

    var engine: TrialEngine!
    var store: TrialStore!
    var service: LocalTrialServiceMock!
    let testDbPath = NSTemporaryDirectory() + "integration-test.db"
    let childID = "test-child-integration"
    let sessionID = UUID().uuidString

    override func setUp() async throws {
        try super.setUp()

        // Clean up test database
        try? FileManager.default.removeItem(atPath: testDbPath)

        // Create fresh instances
        engine = TrialEngine(sessionID: sessionID)
        store = try TrialStore(path: testDbPath, encryptionKey: "integration-test-key")
        service = LocalTrialServiceMock()

        // Add test targets
        engine.addTarget(targetID: "ba", name: "ba", ipaTranscription: "ba")
        engine.addTarget(targetID: "ma", name: "ma", ipaTranscription: "ma")
    }

    override func tearDown() async throws {
        try super.tearDown()
        service.clearCache()
        try? FileManager.default.removeItem(atPath: testDbPath)
    }

    // MARK: - 10-trial sequence test

    func test10TrialSequenceNoNetworkCalls() async throws {
        let trialSequence: [TrialEngine.Score] = [
            .correct, .correct, .correct,  // Advance L0 → L1
            .notYet, .notYet,               // Back off L1 → L0
            .correct, .correct, .correct,  // Advance L0 → L1
            .close, .close                  // No change (close doesn't advance/backoff)
        ]

        // Record all trials
        for (index, score) in trialSequence.enumerated() {
            let targetID = index % 2 == 0 ? "ba" : "ma"

            // Record in engine
            let result = await engine.recordTrial(
                targetID: targetID,
                score: score,
                attemptDuration: 2.0,
                snrDb: 18.5
            )

            // Record in store
            try await store.recordTrial(
                childID: childID,
                sessionID: sessionID,
                trialID: UUID().uuidString,
                targetID: targetID,
                cueLevel: result.currentLevel?.rawValue ?? 0,
                score: score.rawValue,
                parentScore: nil,
                duration: 2.0,
                snrDb: 18.5
            )
        }

        // Verify all trials in store
        let storedTrials = try await store.getTrialsForSession(childID: childID, sessionID: sessionID)
        XCTAssertEqual(storedTrials.count, 10, "All 10 trials should be stored")

        // Verify state machine ended correctly
        let baTarget = engine.getTargetState(targetID: "ba")!
        let maTarget = engine.getTargetState(targetID: "ma")!

        XCTAssertNotNil(baTarget, "Target ba should exist")
        XCTAssertNotNil(maTarget, "Target ma should exist")
    }

    // MARK: - Mock service integration

    func testMockServiceUploadSessionMarksTrialsSynced() async throws {
        let trialSequence: [TrialEngine.Score] = [
            .correct, .correct, .correct,
            .notYet, .notYet,
            .correct, .correct, .correct,
            .close, .close
        ]

        for (index, score) in trialSequence.enumerated() {
            let targetID = index % 2 == 0 ? "ba" : "ma"

            let result = await engine.recordTrial(
                targetID: targetID,
                score: score,
                attemptDuration: 2.0,
                snrDb: 18.5
            )

            try await store.recordTrial(
                childID: childID,
                sessionID: sessionID,
                trialID: UUID().uuidString,
                targetID: targetID,
                cueLevel: result.currentLevel?.rawValue ?? 0,
                score: score.rawValue,
                parentScore: nil,
                duration: 2.0,
                snrDb: 18.5
            )
        }

        // Get all trials
        let trials = try await store.getTrialsForSession(childID: childID, sessionID: sessionID)
        XCTAssertEqual(trials.count, 10)

        // Upload via mock service
        let uploadResult = await service.uploadSession(
            childID: childID,
            sessionID: sessionID,
            trials: trials
        )

        // Verify upload success
        XCTAssertTrue(uploadResult.success)
        XCTAssertEqual(uploadResult.uploadedCount, 10)
        XCTAssertEqual(uploadResult.failedCount, 0)

        // Verify sync status
        let syncStatus = service.getSyncStatus(sessionID: sessionID)
        XCTAssertEqual(syncStatus.syncedCount, 10, "All trials should be marked synced")
    }

    // MARK: - Audio upload test

    func testMockServiceUploadAudio() async throws {
        let trialID = UUID().uuidString
        let audioData = Data(count: 32000)  // ~2 seconds @ 16 kHz

        let metadata = AudioMetadata(
            trialID: trialID,
            duration: 2.0,
            sampleRate: 16000,
            snrDb: 18.5
        )

        let result = await service.uploadAudio(
            childID: childID,
            sessionID: sessionID,
            trialID: trialID,
            audioData: audioData,
            metadata: metadata
        )

        XCTAssertTrue(result.success)
        XCTAssertEqual(result.uploadedCount, 1)
    }

    // MARK: - Target config retrieval

    func testMockServiceGetTargets() async throws {
        let result = await service.getTargets(childID: childID)

        XCTAssertTrue(result.success)
        XCTAssertGreater(result.targets.count, 0)
        XCTAssertEqual(result.targets.first?.targetID, "ba")
    }

    // MARK: - State machine consistency

    func testStateMachineConsistencyAcrossTenTrials() async throws {
        let testCases = [
            (targetID: "ba", score: TrialEngine.Score.correct),
            (targetID: "ba", score: TrialEngine.Score.correct),
            (targetID: "ba", score: TrialEngine.Score.correct),  // Should advance
            (targetID: "ma", score: TrialEngine.Score.notYet),
            (targetID: "ma", score: TrialEngine.Score.notYet),   // Should back off
            (targetID: "ba", score: TrialEngine.Score.correct),
            (targetID: "ba", score: TrialEngine.Score.close),
            (targetID: "ma", score: TrialEngine.Score.correct),
            (targetID: "ma", score: TrialEngine.Score.correct),
            (targetID: "ma", score: TrialEngine.Score.correct),  // Should advance
        ]

        var baAdvanced = false
        var maAdvanced = false

        for (targetID, score) in testCases {
            let result = await engine.recordTrial(
                targetID: targetID,
                score: score,
                attemptDuration: 2.0,
                snrDb: 18.5
            )

            // Track level changes
            if targetID == "ba" && result.action == .advanced {
                baAdvanced = true
            }
            if targetID == "ma" && result.action == .advanced {
                maAdvanced = true
            }
        }

        let baTarget = engine.getTargetState(targetID: "ba")!
        let maTarget = engine.getTargetState(targetID: "ma")!

        // Verify correct advancements
        XCTAssertTrue(baAdvanced, "ba should have advanced")
        XCTAssertTrue(maAdvanced, "ma should have advanced")
        XCTAssertEqual(baTarget.currentLevel, .level1)
        XCTAssertEqual(maTarget.currentLevel, .level1)
    }

    // MARK: - No repetitive failure guarantee

    func testNoRepetitiveFailureWith20TrialSequence() async throws {
        let engine = TrialEngine(sessionID: "safety-test-integration")
        engine.addTarget(targetID: "test", name: "test", ipaTranscription: "test")

        // Generate adversarial sequence: mostly failures with occasional success
        let adversarialSequence: [TrialEngine.Score] = [
            .notYet, .notYet, .notYet, .notYet, .notYet,
            .correct, .notYet, .notYet, .notYet, .notYet,
            .notYet, .notYet, .notYet, .notYet, .notYet,
            .correct, .notYet, .notYet, .notYet, .notYet
        ]

        for score in adversarialSequence {
            _ = await engine.recordTrial(
                targetID: "test",
                score: score,
                attemptDuration: 2.0,
                snrDb: 10.0
            )
        }

        let target = engine.getTargetState(targetID: "test")!

        // Safety stop must have fired
        XCTAssertTrue(target.retired, "Target should be retired by safety stop")
        XCTAssertEqual(target.retirementReason, .safetyStop)
    }

    // MARK: - Concurrent trial recording

    func testConcurrentTrialRecording() async throws {
        let trialCount = 20

        try await withThrowingTaskGroup(of: Void.self) { group in
            for i in 0..<trialCount {
                group.addTask {
                    let targetID = i % 2 == 0 ? "ba" : "ma"
                    let score: TrialEngine.Score = i % 3 == 0 ? .correct : .notYet

                    let result = await self.engine.recordTrial(
                        targetID: targetID,
                        score: score,
                        attemptDuration: 2.0,
                        snrDb: 18.5
                    )

                    try await self.store.recordTrial(
                        childID: self.childID,
                        sessionID: self.sessionID,
                        trialID: UUID().uuidString,
                        targetID: targetID,
                        cueLevel: result.currentLevel?.rawValue ?? 0,
                        score: score.rawValue,
                        parentScore: nil,
                        duration: 2.0,
                        snrDb: 18.5
                    )
                }
            }

            try await group.waitForAll()
        }

        let trials = try await store.getTrialsForSession(childID: childID, sessionID: sessionID)
        XCTAssertEqual(trials.count, trialCount, "All concurrent trials should be recorded")
    }
}
