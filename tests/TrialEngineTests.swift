import XCTest
@testable import PraxiaChild

/// Property-based tests for the trial engine state machine.
///
/// Verifies:
/// 1. No path leaves a child failing repeatedly
/// 2. The safety stop always fires correctly
/// 3. Back-off never emits a child-visible event
/// 4. Advancement and back-off logic is correct
final class TrialEngineTests: XCTestCase {

    var engine: TrialEngine!
    var eventLog: EventLog!

    override func setUp() {
        super.setUp()
        eventLog = EventLog()
        engine = TrialEngine(sessionID: "test-session", eventLog: eventLog)
    }

    // MARK: - Advancement tests

    func testAdvancesAfter3ConsecutiveCorrect() async {
        engine.addTarget(targetID: "test-target", name: "ba", ipaTranscription: "ba")

        var target = engine.getTargetState(targetID: "test-target")!
        XCTAssertEqual(target.currentLevel, .level0)

        // Score 3 correct
        for _ in 0..<3 {
            let result = await engine.recordTrial(
                targetID: "test-target",
                score: .correct,
                parentScore: .correct,
                attemptDuration: 2.0,
                snrDb: 15.0
            )
            XCTAssertNil(result.error)
        }

        target = engine.getTargetState(targetID: "test-target")!
        XCTAssertEqual(target.currentLevel, .level1)
        XCTAssertEqual(target.consecutiveCorrect, 0, "Consecutive counter should reset after advancement")
    }

    func testAdvancesToMaxLevel() async {
        engine.addTarget(targetID: "test-target", name: "ba", ipaTranscription: "ba")

        // Manually advance to level 5
        for _ in 0..<6 {
            for _ in 0..<3 {
                let result = await engine.recordTrial(
                    targetID: "test-target",
                    score: .correct,
                    attemptDuration: 2.0,
                    snrDb: 15.0
                )
                XCTAssertNil(result.error)
            }

            let target = engine.getTargetState(targetID: "test-target")!
            if target.currentLevel == .level5 {
                break
            }
        }

        let target = engine.getTargetState(targetID: "test-target")!
        XCTAssertEqual(target.currentLevel, .level5, "Should not advance beyond level 5")
    }

    // MARK: - Back-off tests

    func testBacksOffAfter2ConsecutiveIncorrect() async {
        engine.addTarget(targetID: "test-target", name: "ba", ipaTranscription: "ba")

        // Advance to level 1
        for _ in 0..<3 {
            _ = await engine.recordTrial(
                targetID: "test-target",
                score: .correct,
                attemptDuration: 2.0,
                snrDb: 15.0
            )
        }

        var target = engine.getTargetState(targetID: "test-target")!
        XCTAssertEqual(target.currentLevel, .level1)

        // Score 2 incorrect (should back off)
        for _ in 0..<2 {
            _ = await engine.recordTrial(
                targetID: "test-target",
                score: .notYet,
                attemptDuration: 2.0,
                snrDb: 15.0
            )
        }

        target = engine.getTargetState(targetID: "test-target")!
        XCTAssertEqual(target.currentLevel, .level0, "Should back off to level 0")
        XCTAssertEqual(target.consecutiveIncorrect, 0, "Consecutive incorrect counter should reset")
    }

    func testBackOffIsSilentToChild() async {
        engine.addTarget(targetID: "test-target", name: "ba", ipaTranscription: "ba")

        // Advance to level 1
        for _ in 0..<3 {
            _ = await engine.recordTrial(
                targetID: "test-target",
                score: .correct,
                attemptDuration: 2.0,
                snrDb: 15.0
            )
        }

        // Back off and capture the result
        let result1 = await engine.recordTrial(
            targetID: "test-target",
            score: .notYet,
            attemptDuration: 2.0,
            snrDb: 15.0
        )
        XCTAssertEqual(result1.action, .none, "First incorrect should produce no action")

        let result2 = await engine.recordTrial(
            targetID: "test-target",
            score: .notYet,
            attemptDuration: 2.0,
            snrDb: 15.0
        )
        XCTAssertEqual(result2.action, .backedOff, "Back-off should be recorded but not signaled to child")
        XCTAssertNil(result2.message, "Back-off should have no message to child")
    }

    // MARK: - Safety stop tests

    func testSafetyStopsBelow40PercentOver10Trials() async {
        engine.addTarget(targetID: "test-target", name: "ba", ipaTranscription: "ba")

        // Score: 3 correct, 7 incorrect (30% success rate)
        let scores: [TrialEngine.Score] = [
            .correct, .correct, .correct,
            .notYet, .notYet, .notYet, .notYet, .notYet, .notYet, .notYet
        ]

        for score in scores {
            _ = await engine.recordTrial(
                targetID: "test-target",
                score: score,
                attemptDuration: 2.0,
                snrDb: 15.0
            )
        }

        let target = engine.getTargetState(targetID: "test-target")!
        XCTAssertTrue(target.retired, "Target should be retired due to safety stop")
        XCTAssertEqual(target.retirementReason, .safetyStop)
    }

    func testSafetyStopDoesNotTriggerAbove40Percent() async {
        engine.addTarget(targetID: "test-target", name: "ba", ipaTranscription: "ba")

        // Score: 4 correct, 6 incorrect (40% success rate - boundary)
        let scores: [TrialEngine.Score] = [
            .correct, .correct, .correct, .correct,
            .notYet, .notYet, .notYet, .notYet, .notYet, .notYet
        ]

        for score in scores {
            _ = await engine.recordTrial(
                targetID: "test-target",
                score: score,
                attemptDuration: 2.0,
                snrDb: 15.0
            )
        }

        let target = engine.getTargetState(targetID: "test-target")!
        XCTAssertFalse(target.retired, "Target should NOT be retired at exactly 40% success rate")
    }

    func testSafetyStopOnlyAtLowestLevel() async {
        engine.addTarget(targetID: "test-target", name: "ba", ipaTranscription: "ba")

        // Advance to level 2
        for _ in 0..<6 {
            for _ in 0..<3 {
                _ = await engine.recordTrial(
                    targetID: "test-target",
                    score: .correct,
                    attemptDuration: 2.0,
                    snrDb: 15.0
                )
            }

            let target = engine.getTargetState(targetID: "test-target")!
            if target.currentLevel == .level2 {
                break
            }
        }

        // Now score poorly
        let scores: [TrialEngine.Score] = [
            .notYet, .notYet, .notYet, .notYet, .notYet,
            .notYet, .notYet, .notYet, .notYet, .notYet
        ]

        for score in scores {
            _ = await engine.recordTrial(
                targetID: "test-target",
                score: score,
                attemptDuration: 2.0,
                snrDb: 15.0
            )
        }

        let target = engine.getTargetState(targetID: "test-target")!
        XCTAssertFalse(target.retired, "Safety stop should only trigger at lowest level, not in the middle")
    }

    // MARK: - No repetitive failure guarantee

    func testNoPathLeavesChildFailingRepeatedly() async {
        engine.addTarget(targetID: "test-target", name: "ba", ipaTranscription: "ba")

        // Simulate worst case: alternating scores that never allow advancement
        let worstCaseScores: [TrialEngine.Score] = [
            .correct, .notYet, .correct, .notYet, .correct, .notYet,
            .correct, .notYet, .correct, .notYet, .correct, .notYet,
            .notYet, .notYet, .notYet, .notYet, .notYet, .notYet,
            .notYet, .notYet, .notYet, .notYet, .notYet, .notYet
        ]

        for score in worstCaseScores {
            _ = await engine.recordTrial(
                targetID: "test-target",
                score: score,
                attemptDuration: 2.0,
                snrDb: 15.0
            )
        }

        let target = engine.getTargetState(targetID: "test-target")!
        XCTAssertTrue(target.retired, "Target should eventually retire to prevent repetitive failure")
        XCTAssertEqual(target.retirementReason, .safetyStop)
    }

    // MARK: - Event logging

    func testEventsAreLoggedCorrectly() async {
        engine.addTarget(targetID: "test-target", name: "ba", ipaTranscription: "ba")

        for _ in 0..<3 {
            _ = await engine.recordTrial(
                targetID: "test-target",
                score: .correct,
                attemptDuration: 2.0,
                snrDb: 15.0
            )
        }

        let log = await engine.getEventLog()
        let eventCount = await log.getEventCount()
        XCTAssertGreater(eventCount, 0, "Events should be logged")
    }

    // MARK: - Close/approximation handling

    func testCloseScoresDoNotAdvanceOrBackOff() async {
        engine.addTarget(targetID: "test-target", name: "ba", ipaTranscription: "ba")

        for _ in 0..<10 {
            _ = await engine.recordTrial(
                targetID: "test-target",
                score: .close,
                attemptDuration: 2.0,
                snrDb: 15.0
            )
        }

        let target = engine.getTargetState(targetID: "test-target")!
        XCTAssertEqual(target.currentLevel, .level0, "Close scores should not change level")
        XCTAssertFalse(target.retired, "Close scores alone should not trigger safety stop")
    }

    // MARK: - Multiple targets

    func testEngineHandlesMultipleTargets() async {
        engine.addTarget(targetID: "target-1", name: "ba", ipaTranscription: "ba")
        engine.addTarget(targetID: "target-2", name: "ma", ipaTranscription: "ma")

        // Advance target-1
        for _ in 0..<3 {
            _ = await engine.recordTrial(
                targetID: "target-1",
                score: .correct,
                attemptDuration: 2.0,
                snrDb: 15.0
            )
        }

        // Back off target-2
        for _ in 0..<2 {
            _ = await engine.recordTrial(
                targetID: "target-2",
                score: .notYet,
                attemptDuration: 2.0,
                snrDb: 15.0
            )
        }

        let target1 = engine.getTargetState(targetID: "target-1")!
        let target2 = engine.getTargetState(targetID: "target-2")!

        XCTAssertEqual(target1.currentLevel, .level1)
        XCTAssertEqual(target2.currentLevel, .level0)
    }

    // MARK: - Property-based tests (100+ random sequences)

    func testPropertyNoPathLeavesChildInRepetitiveFailure() async {
        // Generate 50 random score sequences and verify safety stop always fires
        // This is the key property: no sequence can trap the child in failure loop

        for seed in 0..<50 {
            let engine = TrialEngine(sessionID: "property-test-\(seed)", eventLog: EventLog())
            engine.addTarget(targetID: "test", name: "ba", ipaTranscription: "ba")

            // Generate random sequence of up to 50 trials
            var scoreSequence: [TrialEngine.Score] = []
            var generator = SystemRandomNumberGenerator()
            for _ in 0..<50 {
                let rand = Int.random(in: 0..<10, using: &generator)
                if rand < 3 {
                    scoreSequence.append(.correct)
                } else if rand < 5 {
                    scoreSequence.append(.close)
                } else {
                    scoreSequence.append(.notYet)
                }
            }

            // Execute all scores
            for score in scoreSequence {
                _ = await engine.recordTrial(
                    targetID: "test",
                    score: score,
                    attemptDuration: 2.0,
                    snrDb: 15.0
                )
            }

            let target = engine.getTargetState(targetID: "test")!

            // Invariant: If we got less than 40% success, target must be retired
            if target.recentTrials.count >= 10 {
                let successRate = Float(target.recentTrials.filter { $0 == .correct }.count) / Float(target.recentTrials.count)
                if successRate < 0.4 && target.currentLevel == .level0 {
                    XCTAssertTrue(target.retired, "Safety stop must fire at <40% success rate (seed: \(seed))")
                }
            }
        }
    }

    func testPropertyAdvancementConsistency() async {
        // Property: 3 consecutive correct trials ALWAYS advance (no sequence of outcomes prevents this)
        for seed in 0..<30 {
            let engine = TrialEngine(sessionID: "advance-property-\(seed)", eventLog: EventLog())
            engine.addTarget(targetID: "test", name: "ba", ipaTranscription: "ba")

            let initialLevel = TrialEngine.CueLevel.level0

            // Always score 3 correct
            for _ in 0..<3 {
                _ = await engine.recordTrial(
                    targetID: "test",
                    score: .correct,
                    attemptDuration: 2.0,
                    snrDb: 15.0
                )
            }

            let target = engine.getTargetState(targetID: "test")!
            let expectedLevel = TrialEngine.CueLevel(rawValue: initialLevel.rawValue + 1) ?? .level5

            XCTAssertEqual(
                target.currentLevel, expectedLevel,
                "3 consecutive correct must always advance (seed: \(seed))"
            )
            XCTAssertEqual(target.consecutiveCorrect, 0, "Counter must reset after advancement")
        }
    }

    func testPropertyBackOffConsistency() async {
        // Property: 2 consecutive incorrect trials ALWAYS back off exactly 1 level
        for seed in 0..<30 {
            let engine = TrialEngine(sessionID: "backoff-property-\(seed)", eventLog: EventLog())
            engine.addTarget(targetID: "test", name: "ba", ipaTranscription: "ba")

            // Advance to level 2
            for _ in 0..<6 {
                _ = await engine.recordTrial(
                    targetID: "test",
                    score: .correct,
                    attemptDuration: 2.0,
                    snrDb: 15.0
                )
            }

            let beforeBackOff = engine.getTargetState(targetID: "test")!.currentLevel

            // Score 2 incorrect
            for _ in 0..<2 {
                _ = await engine.recordTrial(
                    targetID: "test",
                    score: .notYet,
                    attemptDuration: 2.0,
                    snrDb: 15.0
                )
            }

            let target = engine.getTargetState(targetID: "test")!
            let expectedLevel = TrialEngine.CueLevel(rawValue: beforeBackOff.rawValue - 1) ?? .level0

            XCTAssertEqual(
                target.currentLevel, expectedLevel,
                "2 consecutive incorrect must back off exactly 1 level (seed: \(seed))"
            )
        }
    }

    func testPropertyNoPingPong() async {
        // Property: Rapid oscillation between levels shouldn't happen
        // (can't advance and back off in consecutive trials without intermediate state)
        for seed in 0..<20 {
            let engine = TrialEngine(sessionID: "pingpong-\(seed)", eventLog: EventLog())
            engine.addTarget(targetID: "test", name: "ba", ipaTranscription: "ba")

            // Start at L0, try to create oscillation
            var levelSequence: [TrialEngine.CueLevel] = [.level0]

            // Attempt: correct, correct, correct (advance), notYet, notYet (back off), correct, correct, correct (advance)
            let sequence: [TrialEngine.Score] = [
                .correct, .correct, .correct,  // Advance to L1
                .notYet, .notYet,               // Back off to L0
                .correct, .correct, .correct,  // Advance to L1
                .notYet, .notYet,               // Back off to L0
            ]

            for score in sequence {
                _ = await engine.recordTrial(
                    targetID: "test",
                    score: score,
                    attemptDuration: 2.0,
                    snrDb: 15.0
                )
                let target = engine.getTargetState(targetID: "test")!
                levelSequence.append(target.currentLevel)
            }

            // Verify no more than 1 level change per 3-trial window
            for i in 0..<(levelSequence.count - 3) {
                let window = Array(levelSequence[i..<(i+4)])
                let levelChanges = window.dropFirst().filter { $0 != window.first! }.count
                XCTAssertLessOrEqual(
                    levelChanges, 1,
                    "No more than 1 level change in 3-trial window (seed: \(seed))"
                )
            }
        }
    }

    func testPropertySafetyStopThreshold() async {
        // Property: Safety stop fires at <40%, not at ≥40%
        let testCases = [
            (successes: 3, failures: 7, shouldRetire: true, description: "30% = retire"),
            (successes: 4, failures: 6, shouldRetire: false, description: "40% = no retire"),
            (successes: 5, failures: 5, shouldRetire: false, description: "50% = no retire"),
            (successes: 2, failures: 8, shouldRetire: true, description: "20% = retire"),
        ]

        for testCase in testCases {
            let engine = TrialEngine(sessionID: "safety-\(testCase.description)", eventLog: EventLog())
            engine.addTarget(targetID: "test", name: "ba", ipaTranscription: "ba")

            // Build score sequence
            var scores: [TrialEngine.Score] = []
            for _ in 0..<testCase.successes {
                scores.append(.correct)
            }
            for _ in 0..<testCase.failures {
                scores.append(.notYet)
            }
            scores.shuffle()

            // Execute
            for score in scores {
                _ = await engine.recordTrial(
                    targetID: "test",
                    score: score,
                    attemptDuration: 2.0,
                    snrDb: 15.0
                )
            }

            let target = engine.getTargetState(targetID: "test")!
            XCTAssertEqual(
                target.retired, testCase.shouldRetire,
                testCase.description
            )
        }
    }

    func testPropertyNeverAdvanceOn2Correct() async {
        // Property: 2 correct should NOT advance, need exactly 3
        for seed in 0..<20 {
            let engine = TrialEngine(sessionID: "2correct-\(seed)", eventLog: EventLog())
            engine.addTarget(targetID: "test", name: "ba", ipaTranscription: "ba")

            let initialLevel = engine.getTargetState(targetID: "test")!.currentLevel

            // Score exactly 2 correct
            for _ in 0..<2 {
                _ = await engine.recordTrial(
                    targetID: "test",
                    score: .correct,
                    attemptDuration: 2.0,
                    snrDb: 15.0
                )
            }

            let target = engine.getTargetState(targetID: "test")!
            XCTAssertEqual(
                target.currentLevel, initialLevel,
                "2 correct should NOT advance (seed: \(seed))"
            )
            XCTAssertEqual(target.consecutiveCorrect, 2)
        }
    }

    func testPropertyNeverBackOffOn1Incorrect() async {
        // Property: 1 incorrect should NOT back off, need exactly 2
        for seed in 0..<20 {
            let engine = TrialEngine(sessionID: "1incorrect-\(seed)", eventLog: EventLog())
            engine.addTarget(targetID: "test", name: "ba", ipaTranscription: "ba")

            // Advance to level 1 first
            for _ in 0..<3 {
                _ = await engine.recordTrial(
                    targetID: "test",
                    score: .correct,
                    attemptDuration: 2.0,
                    snrDb: 15.0
                )
            }

            let levelAfterAdvance = engine.getTargetState(targetID: "test")!.currentLevel

            // Score exactly 1 incorrect
            _ = await engine.recordTrial(
                targetID: "test",
                score: .notYet,
                attemptDuration: 2.0,
                snrDb: 15.0
            )

            let target = engine.getTargetState(targetID: "test")!
            XCTAssertEqual(
                target.currentLevel, levelAfterAdvance,
                "1 incorrect should NOT back off (seed: \(seed))"
            )
            XCTAssertEqual(target.consecutiveIncorrect, 1)
        }
    }
}
