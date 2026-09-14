import XCTest
@testable import PraxiaChild

/// Tests verifying the TrialServiceProtocol can be implemented by both mock and real clients.
final class TrialServiceProtocolTests: XCTestCase {

    /// Verify that LocalTrialServiceMock implements TrialServiceProtocol
    func testLocalTrialServiceMockImplementsProtocol() {
        // This compiles only if LocalTrialServiceMock implements TrialServiceProtocol
        let mock: LocalTrialServiceMock = LocalTrialServiceMock()
        let service: TrialServiceProtocol = mock

        // Verify protocol conformance
        XCTAssertNotNil(service)
    }

    /// Verify that TrialServiceProtocol methods have correct signatures
    func testTrialServiceProtocolMethodSignatures() async {
        let mock: TrialServiceProtocol = LocalTrialServiceMock()

        // Test uploadSession signature
        let result1 = await mock.uploadSession(
            childID: "test-child",
            sessionID: "test-session",
            trials: []
        )
        XCTAssertTrue(result1.success)

        // Test getTargets signature
        let result2 = await mock.getTargets(childID: "test-child")
        XCTAssertNotNil(result2)

        // Test getSyncStatus signature (sync method)
        let result3 = mock.getSyncStatus(sessionID: "test-session")
        XCTAssertEqual(result3.sessionID, "test-session")
    }

    /// Verify TrialEventRecord can be created and used
    func testTrialEventRecordCreation() {
        let tier1 = Tier1SignalsRecord(
            vocalizationDetected: true,
            latencyMs: 150,
            durationMs: 500,
            syllableCount: 2,
            snrDb: 20.5
        )

        let record = TrialEventRecord(
            eventID: "evt-123",
            sessionID: "sess-456",
            childID: "child-789",
            trialID: "trial-000",
            ordinal: 1,
            targetID: "ba",
            createdAt: Date(),
            tier1Signals: tier1
        )

        XCTAssertEqual(record.eventID, "evt-123")
        XCTAssertEqual(record.targetID, "ba")
        XCTAssertNotNil(record.tier1Signals)
        XCTAssertEqual(record.tier1Signals?.latencyMs, 150)
    }

    /// Verify UploadResult can be created with correct semantics
    func testUploadResultSemantics() {
        let successResult = UploadResult(
            success: true,
            uploadedCount: 10,
            failedCount: 0,
            message: "Success"
        )

        XCTAssertTrue(successResult.success)
        XCTAssertEqual(successResult.uploadedCount, 10)
        XCTAssertEqual(successResult.failedCount, 0)

        let failureResult = UploadResult(
            success: false,
            uploadedCount: 0,
            failedCount: 10,
            message: "Failed"
        )

        XCTAssertFalse(failureResult.success)
        XCTAssertEqual(failureResult.failedCount, 10)
    }
}
