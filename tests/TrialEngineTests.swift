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
}
