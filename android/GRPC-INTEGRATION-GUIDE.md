# gRPC Backend Integration Guide

**Status:** Framework in place, awaiting proto definitions  
**Priority:** CRITICAL BLOCKER 2  
**Estimated Time to Complete:** 2-3 hours (with proto coordination)  

## Overview

The Android app now has a complete gRPC client framework ready for integration with the backend service. The implementation uses:
- **gRPC Kotlin Stub** generated from proto definitions
- **Async/coroutine** support via Dispatchers.IO
- **Environment-based configuration** for host/port
- **Debug/Release build selection** for mock vs. real client

## Current Implementation Status

### ✅ Completed
- `TrialServiceGRPCClient` skeleton with all methods
- `TrialServiceGRPCClientBuilder` for environment-based configuration
- Async coroutine integration in `TrialViewModel`
- Mock service fallback for development (`LocalTrialServiceMock`)
- Build-configuration-based service selection in `MainActivity`

### ⏳ Pending (Blocked on Backend Proto Definitions)
- gRPC stub generation from `trial_service.proto`
- Proto message conversions (TrialEventEntity ↔ Proto)
- TLS certificate configuration
- Backend URL configuration

## Implementation Steps

### Step 1: Coordinate Proto Definitions with Backend Team

The backend team must provide:
1. **`trial_service.proto`** - Main service definition
2. **Message definitions** for:
   - `UploadSessionRequest` (sessionId, childId, trials[])
   - `UploadSessionResponse` (status, message)
   - `UploadAudioRequest` (audioId, audioData)
   - `UploadAudioResponse` (s3Key, status)
   - `GetTargetsRequest` (childId)
   - `GetTargetsResponse` (targets[])
   - `GetSyncStatusRequest` ()
   - `GetSyncStatusResponse` (status)
   - `TrialEventProto` (mapping from TrialEventEntity)
   - `TargetConfigProto` (mapping to TargetEntity)

**Example proto structure:**
```protobuf
syntax = "proto3";

package com.praxia.backend.trial;

service TrialService {
  rpc UploadSession(UploadSessionRequest) returns (UploadSessionResponse);
  rpc UploadAudio(UploadAudioRequest) returns (UploadAudioResponse);
  rpc GetTargets(GetTargetsRequest) returns (GetTargetsResponse);
  rpc GetSyncStatus(GetSyncStatusRequest) returns (GetSyncStatusResponse);
}

message UploadSessionRequest {
  string session_id = 1;
  string child_id = 2;
  repeated TrialEventProto trials = 3;
}

message TrialEventProto {
  string event_id = 1;
  string session_id = 2;
  string trial_id = 3;
  int32 cue_level = 4;
  int64 client_ts = 5;
  bool tier1_vocalization_detected = 6;
  int32 tier1_latency_ms = 7;
  int32 tier1_duration_ms = 8;
  int32 tier1_syllable_count = 9;
  string tier1_pitch_contour = 10;
  float tier1_snr_db = 11;
}
```

### Step 2: Generate gRPC Stubs

Once proto files are available:

```bash
# From backend repository root
protoc \
  --kotlin_out=../android/app/src/main/kotlin \
  --grpc-kotlin_out=../android/app/src/main/kotlin \
  --plugin=protoc-gen-grpc-kotlin=protoc-gen-grpc-kotlin \
  proto/trial_service.proto
```

This generates:
- `TrialServiceGrpc.kt` with service stubs
- Message classes (UploadSessionRequest, etc.)

### Step 3: Implement Stub Integration

Update `TrialServiceGRPCClient.kt`:

```kotlin
private val trialServiceStub: TrialServiceGrpc.TrialServiceStub = 
    TrialServiceGrpc.newStub(channel)

override suspend fun uploadSession(
    sessionId: String,
    childId: String,
    trials: List<TrialEventEntity>
): Result<String> = withContext(Dispatchers.IO) {
    try {
        val request = UploadSessionRequest.newBuilder()
            .setSessionId(sessionId)
            .setChildId(childId)
            .addAllTrials(trials.map { it.toProto() })
            .build()

        val response = trialServiceStub.uploadSession(request)
        Result.success(response.status)
    } catch (e: Exception) {
        Result.failure(e)
    }
}
```

### Step 4: Implement Entity ↔ Proto Conversions

Add extension functions to `TrialEventEntity`:

```kotlin
fun TrialEventEntity.toProto(): TrialEventProto = TrialEventProto.newBuilder()
    .setEventId(eventID)
    .setSessionId(sessionID)
    .setTrialId(trialID)
    .setCueLevel(cueLevel)
    .setClientTs(clientTs)
    .setTier1VocalizationDetected(tier1VocalizationDetected)
    .setTier1LatencyMs(tier1LatencyMs)
    .setTier1DurationMs(tier1DurationMs)
    .setTier1SyllableCount(tier1SyllableCount)
    .setTier1PitchContour(tier1PitchContour)
    .setTier1SnrDb(tier1SnrDb)
    .build()

// Reverse mapping
fun TargetConfigProto.toEntity(): TargetEntity = TargetEntity(
    targetID = targetId,
    sessionID = sessionId,
    childID = childId,
    targetName = targetName,
    ipaTranscription = ipa,
    currentLevel = currentLevel
)
```

### Step 5: Configure TLS for Production

In `TrialServiceGRPCClient`:

```kotlin
private val channel: ManagedChannel = if (BuildConfig.DEBUG) {
    // Insecure for local development
    ManagedChannelBuilder.forAddress(host, port).usePlaintext().build()
} else {
    // TLS for production
    val certificateInputStream = context.getResources()
        .openRawResource(R.raw.ca_cert)
    val sslContext = SSLContext.getInstance("TLS").apply {
        // Initialize with CA certificate
    }
    ManagedChannelBuilder.forAddress(host, port)
        .useTransportSecurity()
        .sslSocketFactory(sslContext.socketFactory)
        .build()
}
```

### Step 6: Configure Backend URL

Via environment variables or manifest:

```xml
<!-- AndroidManifest.xml -->
<meta-data
    android:name="trial_service_host"
    android:value="api.praxia.example.com" />

<meta-data
    android:name="trial_service_port"
    android:value="443" />
```

Or use environment variables:
```bash
TRIAL_SERVICE_HOST=api.praxia.example.com
TRIAL_SERVICE_PORT=443
```

### Step 7: Add gRPC Dependencies

Already present in `build.gradle.kts`:
```kotlin
implementation("io.grpc:grpc-kotlin-stub:1.50.0")
implementation("io.grpc:grpc-protobuf-lite:1.50.0")
implementation("com.google.protobuf:protobuf-kotlin-lite:3.22.0")
```

May need to add for TLS:
```kotlin
implementation("io.grpc:grpc-netty-shaded:1.50.0")
```

## Testing the gRPC Integration

### Unit Tests
```kotlin
class TrialServiceGRPCClientTest {
    @Test
    fun uploadSessionSucceeds() {
        val client = TrialServiceGRPCClient("localhost", 9090)
        val trials = listOf(mockTrialEvent())
        val result = client.uploadSession("session-001", "child-001", trials)
        
        assertTrue(result.isSuccess)
        assertEquals("session-001", result.getOrNull())
    }
}
```

### Integration Tests with Mock Server
```kotlin
class TrialServiceIntegrationTest {
    private lateinit var grpcServer: Server
    
    @Before
    fun setUp() {
        grpcServer = ServerBuilder.forPort(9090)
            .addService(MockTrialServiceImpl())
            .build()
            .start()
    }
    
    @Test
    fun endToEndSessionUpload() {
        val client = TrialServiceGRPCClient("localhost", 9090)
        val result = client.uploadSession(...)
        assertTrue(result.isSuccess)
    }
}
```

## Monitoring & Logging

Add gRPC interceptors for debugging:

```kotlin
private val loggingInterceptor = ClientInterceptors.intercept(
    channel,
    LoggingClientInterceptor()
)

class LoggingClientInterceptor : ClientInterceptor {
    override fun <ReqT : Any?, RespT : Any?> interceptCall(
        method: MethodDescriptor<ReqT, RespT>,
        callOptions: CallOptions,
        next: Channel
    ): ClientCall<ReqT, RespT> {
        Log.d("gRPC", "Calling ${method.fullMethodName}")
        return next.newCall(method, callOptions)
    }
}
```

## Deployment Checklist

- [ ] Proto files received from backend team
- [ ] Stubs generated successfully
- [ ] Entity ↔ Proto conversions implemented
- [ ] TLS certificates configured
- [ ] Backend URL configured (prod/staging/dev)
- [ ] Unit tests passing
- [ ] Integration tests with mock server passing
- [ ] End-to-end test on staging backend
- [ ] Release build tested with production endpoint
- [ ] Monitoring/logging verified

## Fallback & Error Handling

If backend is unavailable:
1. `LocalTrialServiceMock` continues to work in debug builds
2. Retry logic with exponential backoff (TODO: implement)
3. Offline sync queue persists pending uploads (TODO: complete implementation)
4. User sees error toast with retry button

## Related Files

- `app/src/main/kotlin/com/praxia/child/service/TrialServiceGRPCClient.kt` - Main implementation
- `app/src/main/kotlin/com/praxia/child/service/TrialServiceProtocol.kt` - Interface definition
- `app/src/main/kotlin/com/praxia/child/ui/viewmodel/TrialViewModel.kt` - Service consumption
- `build.gradle.kts` - gRPC dependencies
- `AndroidManifest.xml` - Backend URL configuration (TODO)

## Next Steps

1. **Coordinate with backend team** on proto definitions (HIGH PRIORITY)
2. **Generate gRPC stubs** from proto files
3. **Implement proto conversions**
4. **Configure TLS and URLs**
5. **Complete end-to-end testing**

---

**Status:** Framework ready, awaiting backend proto coordination  
**Est. Completion:** 2-3 hours after receiving proto definitions  
