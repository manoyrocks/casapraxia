import Foundation

// MARK: - Trial Service Protocol
// Defines the interface for uploading trials to the backend.
// Can be implemented by LocalTrialServiceMock or a real gRPC client.

protocol TrialServiceProtocol: AnyObject {
    /// Upload a session's trials to the backend
    func uploadSession(
        childID: String,
        sessionID: String,
        trials: [TrialEventRecord]
    ) async -> UploadResult

    /// Upload audio clip for a trial
    func uploadAudio(
        childID: String,
        sessionID: String,
        trialID: String,
        audioData: Data,
        metadata: AudioMetadata
    ) async -> UploadResult

    /// Get targets configuration for a child
    func getTargets(childID: String) async -> TargetConfigResult

    /// Get sync status for a session
    func getSyncStatus(sessionID: String) -> SyncStatus
}

// MARK: - Result Types

struct UploadResult: Codable, Equatable {
    let success: Bool
    let uploadedCount: Int
    let failedCount: Int
    let message: String
}

struct TargetConfig: Codable, Equatable {
    let targetID: String
    let targetName: String
    let ipaTranscription: String
    let cueLevel: Int
    let syllableShape: String

    enum CodingKeys: String, CodingKey {
        case targetID = "target_id"
        case targetName = "target_name"
        case ipaTranscription = "ipa_transcription"
        case cueLevel = "cue_level"
        case syllableShape = "syllable_shape"
    }
}

struct TargetConfigResult: Codable, Equatable {
    let success: Bool
    let targets: [TargetConfig]
    let message: String
}

struct SyncStatus: Codable, Equatable {
    let sessionID: String
    let syncedCount: Int
    let lastSyncAt: Date

    enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case syncedCount = "synced_count"
        case lastSyncAt = "last_sync_at"
    }
}

struct AudioMetadata: Codable, Equatable {
    let trialID: String
    let duration: TimeInterval
    let sampleRate: Int
    let snrDb: Float

    enum CodingKeys: String, CodingKey {
        case trialID = "trial_id"
        case duration
        case sampleRate = "sample_rate"
        case snrDb = "snr_db"
    }
}

// MARK: - Trial Event Record (from local storage)

struct TrialEventRecord: Codable, Equatable {
    let eventID: String
    let sessionID: String
    let childID: String
    let trialID: String
    let ordinal: Int
    let targetID: String
    let createdAt: Date
    let tier1Signals: Tier1SignalsRecord?

    enum CodingKeys: String, CodingKey {
        case eventID = "event_id"
        case sessionID = "session_id"
        case childID = "child_id"
        case trialID = "trial_id"
        case ordinal
        case targetID = "target_id"
        case createdAt = "created_at"
        case tier1Signals = "tier1_signals"
    }
}

struct Tier1SignalsRecord: Codable, Equatable {
    let vocalizationDetected: Bool
    let latencyMs: Int
    let durationMs: Int
    let syllableCount: Int
    let snrDb: Float

    enum CodingKeys: String, CodingKey {
        case vocalizationDetected = "vocalization_detected"
        case latencyMs = "latency_ms"
        case durationMs = "duration_ms"
        case syllableCount = "syllable_count"
        case snrDb = "snr_db"
    }
}

// MARK: - gRPC Client Integration Guide
/*
 INTEGRATION GUIDE FOR REAL gRPC CLIENT:

 This file defines the TrialServiceProtocol interface and data types.
 LocalTrialServiceMock currently implements this protocol for offline testing.

 To integrate the real gRPC backend (localhost:50051), follow these steps:

 1. ON macOS (where you build iOS app):
    a. Install protoc if not already installed:
       brew install protobuf

    b. Install Swift Protobuf compiler plugin:
       cd /path/to/client
       swift package resolve
       swift build

    c. Generate Swift code from backend protos:
       protoc \
         --swift_out=client/Sources/PraxiaChild/Generated \
         --grpc-swift_out=client/Sources/PraxiaChild/Generated \
         --swift_opt=Visibility=Public \
         --grpc-swift_opt=Visibility=Public \
         -I/path/to/backend/protos \
         /path/to/backend/protos/trial.proto \
         /path/to/backend/protos/audio.proto \
         /path/to/backend/protos/config.proto

 2. Create TrialServiceGRPCClient.swift implementing TrialServiceProtocol:
    - Import the generated protobuf code
    - Wrap gRPC client stubs
    - Convert TrialEventRecord to proto messages
    - Handle channel creation/cleanup

 3. Update SessionViewController:
    - Inject trialService: TrialServiceProtocol
    - Call trialService.uploadSession() in endSession()

 4. Update Package.swift dependencies (already done):
    - grpc-swift
    - swift-protobuf

 5. Run tests:
    - Backend must be running on localhost:50051
    - Run IntegrationTests to verify end-to-end
    - Verify trials appear in PostgreSQL

 PROTO MESSAGE MAPPINGS:

 Protobuf Message: Praxia.V1.TrialEvent
 Maps to: TrialEventRecord + conversion to proto

 Protobuf Message: Praxia.V1.UploadSessionRequest
 Contains: device_id, session_id, child_id, trial_events, audio_refs, parent_scores

 Protobuf Message: Praxia.V1.UploadSessionResponse
 Contains: accepted_count, error_count, retry_after_ms, error_messages
 Maps to: UploadResult

 GRPC CHANNEL SETUP:

 let channel = try GRPCChannelPool.with(
     target: .host("localhost", port: 50051),
     transportSecurity: .plaintext,  // for dev; use .tls() for production
     eventLoopGroup: MultiThreadedEventLoopGroup(numberOfThreads: 1)
 )

 BACKEND PROTO FILES:
 - backend/protos/trial.proto
 - backend/protos/audio.proto
 - backend/protos/config.proto

 Generated Go code is at:
 - backend/pkg/gen/praxia/v1/*.pb.go
 - backend/pkg/gen/praxia/v1/*_grpc.pb.go
 */
