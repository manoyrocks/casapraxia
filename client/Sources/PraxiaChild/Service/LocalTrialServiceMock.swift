import Foundation

/// Mock trial service for local development and testing.
/// Implements immediate success responses without network calls.
///
/// Usage: Before Architect publishes gRPC stubs, use this for integration testing.
/// Seamless swap: Replace with gRPC client when proto stubs available.
@MainActor
class LocalTrialServiceMock {

    /// Upload a session's trials to local cache (marked as synced)
    func uploadSession(
        childID: String,
        sessionID: String,
        trials: [TrialEventRecord]
    ) async -> UploadResult {
        // Simulate network latency (100ms)
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Mark trials as synced in UserDefaults
        let syncedKey = "synced_trials_\(sessionID)"
        var syncedTrialIDs = UserDefaults.standard.stringArray(forKey: syncedKey) ?? []

        for trial in trials {
            syncedTrialIDs.append(trial.eventID)
        }

        UserDefaults.standard.set(syncedTrialIDs, forKey: syncedKey)

        print("✅ Mock: Uploaded \(trials.count) trials for session \(sessionID)")

        return UploadResult(
            success: true,
            uploadedCount: trials.count,
            failedCount: 0,
            message: "Mock upload successful"
        )
    }

    /// Upload audio clip (trimmed, encrypted)
    func uploadAudio(
        childID: String,
        sessionID: String,
        trialID: String,
        audioData: Data,
        metadata: AudioMetadata
    ) async -> UploadResult {
        // Simulate longer network latency (500ms for audio)
        try? await Task.sleep(nanoseconds: 500_000_000)

        // Cache audio metadata
        let audioKey = "audio_\(trialID)"
        do {
            let encoded = try JSONEncoder().encode(metadata)
            UserDefaults.standard.set(encoded, forKey: audioKey)
        } catch {
            print("⚠️ Failed to cache audio metadata: \(error)")
            return UploadResult(
                success: false,
                uploadedCount: 0,
                failedCount: 1,
                message: "Failed to cache audio"
            )
        }

        print("✅ Mock: Uploaded audio for trial \(trialID) (\(audioData.count) bytes)")

        return UploadResult(
            success: true,
            uploadedCount: 1,
            failedCount: 0,
            message: "Mock audio upload successful"
        )
    }

    /// Get clinician's target configuration for child
    func getTargets(childID: String) async -> TargetConfigResult {
        // Simulate network latency
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Return mock target list
        let mockTargets = [
            TargetConfig(
                targetID: "ba",
                targetName: "ba",
                ipaTranscription: "ba",
                cueLevel: 0,
                syllableShape: "CV"
            ),
            TargetConfig(
                targetID: "ma",
                targetName: "ma",
                ipaTranscription: "ma",
                cueLevel: 0,
                syllableShape: "CV"
            ),
            TargetConfig(
                targetID: "ga",
                targetName: "ga",
                ipaTranscription: "ɡa",
                cueLevel: 1,
                syllableShape: "CV"
            ),
        ]

        print("✅ Mock: Retrieved \(mockTargets.count) targets for child \(childID)")

        return TargetConfigResult(
            success: true,
            targets: mockTargets,
            message: "Mock target config loaded"
        )
    }

    /// Check sync status for a session
    func getSyncStatus(sessionID: String) -> SyncStatus {
        let syncedKey = "synced_trials_\(sessionID)"
        let syncedTrialIDs = UserDefaults.standard.stringArray(forKey: syncedKey) ?? []

        return SyncStatus(
            sessionID: sessionID,
            syncedCount: syncedTrialIDs.count,
            lastSyncAt: Date()
        )
    }

    /// Clear mock cache (for testing)
    func clearCache() {
        let defaults = UserDefaults.standard
        let keys = defaults.dictionaryRepresentation().keys
        for key in keys {
            if key.hasPrefix("synced_trials_") || key.hasPrefix("audio_") {
                defaults.removeObject(forKey: key)
            }
        }
        print("🧹 Mock cache cleared")
    }
}

// MARK: - Data models

struct UploadResult: Codable {
    let success: Bool
    let uploadedCount: Int
    let failedCount: Int
    let message: String
}

struct TargetConfig: Codable {
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

struct TargetConfigResult: Codable {
    let success: Bool
    let targets: [TargetConfig]
    let message: String
}

struct AudioMetadata: Codable {
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

struct SyncStatus: Codable {
    let sessionID: String
    let syncedCount: Int
    let lastSyncAt: Date

    enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case syncedCount = "synced_count"
        case lastSyncAt = "last_sync_at"
    }
}
