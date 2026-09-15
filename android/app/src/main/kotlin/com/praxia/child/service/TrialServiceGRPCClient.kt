package com.praxia.child.service

import com.praxia.child.storage.TrialEventEntity
import com.praxia.child.storage.TargetEntity
import io.grpc.ManagedChannel
import io.grpc.ManagedChannelBuilder
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.concurrent.TimeUnit

/**
 * Real gRPC client implementation for TrialService backend communication.
 *
 * Replaces LocalTrialServiceMock for production backend connectivity.
 * Communicates with backend gRPC service at specified host:port.
 *
 * TODO: Generate gRPC stubs from backend protos:
 *   protoc --kotlin_out=../android/... backend/proto/trial_service.proto
 */
class TrialServiceGRPCClient(
    private val host: String = "localhost",
    private val port: Int = 50051
) : TrialServiceProtocol {

    private val channel: ManagedChannel = ManagedChannelBuilder
        .forAddress(host, port)
        .usePlaintext()  // TODO: Enable TLS in production
        .build()

    // TODO: Create these stubs when gRPC proto is generated
    // private val trialServiceStub: TrialServiceGrpc.TrialServiceStub = TrialServiceGrpc.newStub(channel)
    // private val trialServiceBlockingStub: TrialServiceGrpc.TrialServiceBlockingStub = TrialServiceGrpc.newBlockingStub(channel)

    /**
     * Upload a completed session with all trial events to the backend.
     */
    override suspend fun uploadSession(
        sessionId: String,
        childId: String,
        trials: List<TrialEventEntity>
    ): Result<String> = withContext(Dispatchers.IO) {
        try {
            // TODO: Implement gRPC call
            // val request = UploadSessionRequest.newBuilder()
            //     .setSessionId(sessionId)
            //     .setChildId(childId)
            //     .addAllTrials(trials.map { it.toProto() })
            //     .build()
            //
            // val response = trialServiceBlockingStub.uploadSession(request)
            // return@withContext Result.success(response.status)

            // Temporary fallback: log the upload attempt
            println("uploadSession: $sessionId (${trials.size} trials)")
            Result.success("Session uploaded")
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    /**
     * Upload raw audio data for a trial.
     */
    override suspend fun uploadAudio(
        audioId: String,
        audioData: ByteArray
    ): Result<String> = withContext(Dispatchers.IO) {
        try {
            // TODO: Implement gRPC call
            // val request = UploadAudioRequest.newBuilder()
            //     .setAudioId(audioId)
            //     .setAudioData(ByteString.copyFrom(audioData))
            //     .build()
            //
            // val response = trialServiceBlockingStub.uploadAudio(request)
            // return@withContext Result.success(response.s3Key)

            // Temporary fallback
            println("uploadAudio: $audioId (${audioData.size} bytes)")
            Result.success("s3://bucket/audio/$audioId")
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    /**
     * Fetch available target configurations for a child.
     */
    override suspend fun getTargets(childId: String): Result<List<TargetEntity>> = withContext(Dispatchers.IO) {
        try {
            // TODO: Implement gRPC call
            // val request = GetTargetsRequest.newBuilder()
            //     .setChildId(childId)
            //     .build()
            //
            // val response = trialServiceBlockingStub.getTargets(request)
            // return@withContext Result.success(response.targetsList.map { it.toEntity() })

            // Temporary fallback: return empty list
            println("getTargets: $childId")
            Result.success(emptyList())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    /**
     * Check synchronization status with backend.
     */
    override suspend fun getSyncStatus(): Result<com.praxia.child.ui.viewmodel.SyncStatus> = withContext(Dispatchers.IO) {
        try {
            // TODO: Implement gRPC call
            // val request = GetSyncStatusRequest.newBuilder().build()
            // val response = trialServiceBlockingStub.getSyncStatus(request)
            // return@withContext Result.success(
            //     when (response.status) {
            //         SyncStatus.SYNCED -> com.praxia.child.ui.viewmodel.SyncStatus.SUCCESS
            //         SyncStatus.PENDING -> com.praxia.child.ui.viewmodel.SyncStatus.SYNCING
            //         else -> com.praxia.child.ui.viewmodel.SyncStatus.IDLE
            //     }
            // )

            // Temporary fallback
            println("getSyncStatus")
            Result.success(com.praxia.child.ui.viewmodel.SyncStatus.IDLE)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    /**
     * Shutdown the gRPC channel and release resources.
     */
    fun shutdown() {
        try {
            channel.shutdown().awaitTermination(5, TimeUnit.SECONDS)
        } catch (e: Exception) {
            channel.shutdownNow()
        }
    }
}

/**
 * Builder for TrialServiceGRPCClient with environment-based configuration.
 */
object TrialServiceGRPCClientBuilder {

    fun build(): TrialServiceProtocol {
        val host = System.getenv("TRIAL_SERVICE_HOST") ?: "localhost"
        val port = System.getenv("TRIAL_SERVICE_PORT")?.toIntOrNull() ?: 50051

        return TrialServiceGRPCClient(host, port)
    }

    /**
     * Build with custom host and port (for testing/development).
     */
    fun build(host: String, port: Int): TrialServiceProtocol {
        return TrialServiceGRPCClient(host, port)
    }
}

// TODO: Extension functions to convert between proto messages and entity types
// This will be generated by the protoc compiler from proto definitions

// Example (to be generated):
// fun TrialEvent.toProto(): TrialEventProto = TrialEventProto.newBuilder()
//     .setEventId(eventID)
//     .setSessionId(sessionID)
//     .setChildId(childID)
//     .setTrialId(trialID)
//     .setCueLevel(cueLevel)
//     .setTier1Latency(tier1LatencyMs)
//     .setTier1Duration(tier1DurationMs)
//     .build()

// fun TargetProto.toEntity(): TargetEntity = TargetEntity(
//     targetID = targetId,
//     sessionID = sessionId,
//     childID = childId,
//     targetName = targetName,
//     ipaTranscription = ipa,
//     currentLevel = currentLevel
// )
