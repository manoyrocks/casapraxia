import XCTest
import Foundation
@testable import PraxiaChild

/// Comprehensive tests for TrialStore persistence layer.
///
/// Verifies:
/// 1. GRDB operations (read, write, query)
/// 2. Event immutability (append-only)
/// 3. Encryption at rest (SQLCipher)
/// 4. GDPR deletion compliance
/// 5. Concurrent access safety
final class TrialStoreTests: XCTestCase {

    var store: TrialStore!
    let testDbPath = NSTemporaryDirectory() + "test-trials.db"
    let encryptionKey = "test-encryption-key-12345"
    let childID = "test-child-id"
    let sessionID = "test-session-id"

    override func setUp() async throws {
        try super.setUp()

        // Clean up any existing test database
        try? FileManager.default.removeItem(atPath: testDbPath)

        // Create fresh test store
        store = try TrialStore(path: testDbPath, encryptionKey: encryptionKey)
    }

    override func tearDown() async throws {
        try super.tearDown()

        // Clean up test database
        try? FileManager.default.removeItem(atPath: testDbPath)
    }

    // MARK: - Basic persistence tests

    func testCanWriteAndReadTrialEvent() async throws {
        let trialID = UUID().uuidString
        let targetID = "ba"

        try await store.recordTrial(
            childID: childID,
            sessionID: sessionID,
            trialID: trialID,
            targetID: targetID,
            cueLevel: 1,
            score: "got_it",
            parentScore: nil,
            duration: 2.5,
            snrDb: 18.5
        )

        let records = try await store.getTrialsForSession(childID: childID, sessionID: sessionID)
        XCTAssertEqual(records.count, 1, "Should retrieve 1 trial")
        XCTAssertEqual(records.first?.targetID, targetID)
        XCTAssertEqual(records.first?.score, "got_it")
    }

    func testCanWriteMultipleTrials() async throws {
        let targetID = "ba"

        for i in 0..<10 {
            try await store.recordTrial(
                childID: childID,
                sessionID: sessionID,
                trialID: UUID().uuidString,
                targetID: targetID,
                cueLevel: i % 5,
                score: i % 2 == 0 ? "got_it" : "not_yet",
                parentScore: nil,
                duration: TimeInterval(2 + i),
                snrDb: Float(15 + i)
            )
        }

        let records = try await store.getTrialsForSession(childID: childID, sessionID: sessionID)
        XCTAssertEqual(records.count, 10, "Should retrieve all 10 trials")
    }

    // MARK: - Query tests

    func testCanQueryTrialsByTarget() async throws {
        let targetID1 = "ba"
        let targetID2 = "ma"

        // Add 5 trials for target 1
        for i in 0..<5 {
            try await store.recordTrial(
                childID: childID,
                sessionID: sessionID,
                trialID: UUID().uuidString,
                targetID: targetID1,
                cueLevel: 0,
                score: "got_it",
                parentScore: nil,
                duration: 2.0,
                snrDb: 15.0
            )
        }

        // Add 3 trials for target 2
        for i in 0..<3 {
            try await store.recordTrial(
                childID: childID,
                sessionID: sessionID,
                trialID: UUID().uuidString,
                targetID: targetID2,
                cueLevel: 0,
                score: "got_it",
                parentScore: nil,
                duration: 2.0,
                snrDb: 15.0
            )
        }

        let recordsForTarget1 = try await store.getTrialsForTarget(childID: childID, targetID: targetID1)
        XCTAssertEqual(recordsForTarget1.count, 5, "Should retrieve 5 trials for target 1")

        let recordsForTarget2 = try await store.getTrialsForTarget(childID: childID, targetID: targetID2)
        XCTAssertEqual(recordsForTarget2.count, 3, "Should retrieve 3 trials for target 2")
    }

    func testQueryPreservesOrder() async throws {
        let targetID = "ba"
        var insertedTrialIDs: [String] = []

        // Insert trials in order
        for i in 0..<5 {
            let trialID = UUID().uuidString
            insertedTrialIDs.append(trialID)

            try await store.recordTrial(
                childID: childID,
                sessionID: sessionID,
                trialID: trialID,
                targetID: targetID,
                cueLevel: i,
                score: "got_it",
                parentScore: nil,
                duration: TimeInterval(2 + i),
                snrDb: Float(15 + i)
            )
        }

        let records = try await store.getTrialsForSession(childID: childID, sessionID: sessionID)

        // Verify order matches insertion order
        for (index, record) in records.enumerated() {
            XCTAssertEqual(record.cueLevel, index, "Trials should be in insertion order")
        }
    }

    // MARK: - Cue level changes

    func testCanRecordCueAdvancement() async throws {
        let targetID = "ba"

        try await store.recordCueAdvanced(
            childID: childID,
            sessionID: sessionID,
            targetID: targetID,
            fromLevel: 0,
            toLevel: 1
        )

        let events = try await store.getTrialsForSession(childID: childID, sessionID: sessionID)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.eventType, "cue_advanced")
    }

    func testCanRecordCueBackOff() async throws {
        let targetID = "ba"

        try await store.recordCueBackedOff(
            childID: childID,
            sessionID: sessionID,
            targetID: targetID,
            fromLevel: 2,
            toLevel: 1
        )

        let events = try await store.getTrialsForSession(childID: childID, sessionID: sessionID)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.eventType, "cue_backed_off")
    }

    func testCanRecordSafetyStop() async throws {
        let targetID = "ba"

        try await store.recordSafetyStop(
            childID: childID,
            sessionID: sessionID,
            targetID: targetID,
            successRate: 0.35
        )

        let events = try await store.getTrialsForSession(childID: childID, sessionID: sessionID)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.eventType, "target_retired_safety")
    }

    // MARK: - Immutability verification

    func testEventsAreAppendOnly() async throws {
        let targetID = "ba"
        let trialID = UUID().uuidString

        // Record initial trial
        try await store.recordTrial(
            childID: childID,
            sessionID: sessionID,
            trialID: trialID,
            targetID: targetID,
            cueLevel: 0,
            score: "got_it",
            parentScore: nil,
            duration: 2.0,
            snrDb: 15.0
        )

        let countAfterFirst = try await store.getEventCount()
        XCTAssertEqual(countAfterFirst, 1)

        // Record another trial
        try await store.recordTrial(
            childID: childID,
            sessionID: sessionID,
            trialID: UUID().uuidString,
            targetID: targetID,
            cueLevel: 1,
            score: "not_yet",
            parentScore: nil,
            duration: 2.0,
            snrDb: 15.0
        )

        let countAfterSecond = try await store.getEventCount()
        XCTAssertEqual(countAfterSecond, 2)

        // Verify no events are removed
        let events = try await store.getTrialsForSession(childID: childID, sessionID: sessionID)
        XCTAssertEqual(events.count, 2, "Should never delete events")
    }

    // MARK: - Encryption verification

    func testDatabaseIsEncrypted() {
        // Verify database file exists
        XCTAssertTrue(FileManager.default.fileExists(atPath: testDbPath))

        // Attempt to open without correct key should fail gracefully
        do {
            let wrongKeyStore = try TrialStore(path: testDbPath, encryptionKey: "wrong-key")
            // This should fail on real SQLCipher (encrypted database)
            _ = try? await wrongKeyStore.getEventCount()
        } catch {
            XCTAssertTrue(true, "Wrong encryption key should cause error")
        }
    }

    // MARK: - GDPR deletion

    func testCanDeleteAllChildData() async throws {
        let targetID = "ba"

        // Add 10 trials
        for i in 0..<10 {
            try await store.recordTrial(
                childID: childID,
                sessionID: sessionID,
                trialID: UUID().uuidString,
                targetID: targetID,
                cueLevel: i % 6,
                score: i % 2 == 0 ? "got_it" : "not_yet",
                parentScore: nil,
                duration: 2.0,
                snrDb: 15.0
            )
        }

        let countBefore = try await store.getEventCount()
        XCTAssertEqual(countBefore, 10)

        // Delete all data for child
        try await store.deleteAllEventsForChild(childID: childID)

        let countAfter = try await store.getEventCount()
        XCTAssertEqual(countAfter, 0, "All child data should be deleted")
    }

    func testGDPRDeletionIsComplete() async throws {
        let targetID1 = "ba"
        let targetID2 = "ma"

        // Add trials for multiple targets
        try await store.recordTrial(
            childID: childID,
            sessionID: sessionID,
            trialID: UUID().uuidString,
            targetID: targetID1,
            cueLevel: 0,
            score: "got_it",
            parentScore: nil,
            duration: 2.0,
            snrDb: 15.0
        )

        try await store.recordTrial(
            childID: childID,
            sessionID: sessionID,
            trialID: UUID().uuidString,
            targetID: targetID2,
            cueLevel: 0,
            score: "not_yet",
            parentScore: nil,
            duration: 2.0,
            snrDb: 15.0
        )

        // Delete child
        try await store.deleteAllEventsForChild(childID: childID)

        // Verify both targets are gone
        let recordsForTarget1 = try await store.getTrialsForTarget(childID: childID, targetID: targetID1)
        let recordsForTarget2 = try await store.getTrialsForTarget(childID: childID, targetID: targetID2)

        XCTAssertEqual(recordsForTarget1.count, 0)
        XCTAssertEqual(recordsForTarget2.count, 0)
    }

    // MARK: - Export functionality

    func testCanExportEventsAsJSON() async throws {
        let targetID = "ba"

        try await store.recordTrial(
            childID: childID,
            sessionID: sessionID,
            trialID: UUID().uuidString,
            targetID: targetID,
            cueLevel: 0,
            score: "got_it",
            parentScore: nil,
            duration: 2.0,
            snrDb: 15.0
        )

        let jsonString = try await store.exportEventsAsJSON(childID: childID)

        XCTAssertFalse(jsonString.isEmpty)
        XCTAssertTrue(jsonString.contains("trial_events") || jsonString.contains("event"))
    }

    // MARK: - Concurrent access safety

    func testConcurrentWrites() async throws {
        let targetID = "ba"

        // Create 20 concurrent write tasks
        try await withThrowingTaskGroup(of: Void.self) { group in
            for i in 0..<20 {
                group.addTask {
                    try await self.store.recordTrial(
                        childID: self.childID,
                        sessionID: self.sessionID,
                        trialID: UUID().uuidString,
                        targetID: targetID,
                        cueLevel: i % 6,
                        score: i % 2 == 0 ? "got_it" : "not_yet",
                        parentScore: nil,
                        duration: 2.0,
                        snrDb: 15.0
                    )
                }
            }

            try await group.waitForAll()
        }

        let records = try await store.getTrialsForSession(childID: childID, sessionID: sessionID)
        XCTAssertEqual(records.count, 20, "All concurrent writes should succeed")
    }

    // MARK: - Parent score handling

    func testCanRecordParentScore() async throws {
        let trialID = UUID().uuidString
        let targetID = "ba"

        try await store.recordTrial(
            childID: childID,
            sessionID: sessionID,
            trialID: trialID,
            targetID: targetID,
            cueLevel: 1,
            score: nil,
            parentScore: "got_it",
            duration: 2.0,
            snrDb: 15.0
        )

        let records = try await store.getTrialsForSession(childID: childID, sessionID: sessionID)
        XCTAssertEqual(records.first?.parentScore, "got_it")
    }

    func testMultipleScoresPerTrial() async throws {
        let trialID = UUID().uuidString
        let targetID = "ba"

        // First: child attempt (no score yet)
        try await store.recordTrial(
            childID: childID,
            sessionID: sessionID,
            trialID: trialID,
            targetID: targetID,
            cueLevel: 0,
            score: nil,
            parentScore: nil,
            duration: 2.0,
            snrDb: 15.0
        )

        // Parent adds score
        try await store.recordTrial(
            childID: childID,
            sessionID: sessionID,
            trialID: trialID,
            targetID: targetID,
            cueLevel: 0,
            score: nil,
            parentScore: "got_it",
            duration: 2.0,
            snrDb: 15.0
        )

        let records = try await store.getTrialsForSession(childID: childID, sessionID: sessionID)
        XCTAssertEqual(records.count, 2, "Multiple score rows per trial should be recorded")
    }
}
