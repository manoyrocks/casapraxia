# gRPC Client Integration Guide

This document provides step-by-step instructions for integrating the real gRPC client with the Praxia iOS app.

## Current Status

- **Local Development**: Uses `LocalTrialServiceMock` for offline testing
- **Backend Ready**: gRPC server running on `localhost:50051` with PostgreSQL
- **Protocol**: Protocol-based architecture via `TrialServiceProtocol`
- **Next Step**: Generate Swift Protobuf stubs and implement real gRPC client

## Architecture

The app uses a protocol-based design for backend abstraction:

```swift
protocol TrialServiceProtocol {
    func uploadSession(...) async -> UploadResult
    func getTargets(...) async -> TargetConfigResult
    func getSyncStatus(...) -> SyncStatus
}
```

Both `LocalTrialServiceMock` and future `TrialServiceGRPCClient` implement this protocol.

## Prerequisites

**On macOS (where you build the iOS app):**

```bash
# Install Xcode Command Line Tools (if not already installed)
xcode-select --install

# Install protobuf compiler
brew install protobuf

# Verify installation
protoc --version  # Should be >= 3.20
```

## Step 1: Generate Swift Protobuf Code

On your Mac, generate Swift source files from the backend's `.proto` files:

```bash
cd /path/to/casapraxia

# Create output directory
mkdir -p client/Sources/PraxiaChild/Generated

# Generate Swift protobuf code from all proto files
protoc \
  --swift_out=client/Sources/PraxiaChild/Generated \
  --grpc-swift_out=client/Sources/PraxiaChild/Generated \
  --swift_opt=Visibility=Public \
  --grpc-swift_opt=Visibility=Public \
  --swift_opt=FileNaming=PathToUnderscores \
  --grpc-swift_opt=FileNaming=PathToUnderscores \
  -I/path/to/casapraxia/backend/protos \
  /path/to/casapraxia/backend/protos/trial.proto \
  /path/to/casapraxia/backend/protos/audio.proto \
  /path/to/casapraxia/backend/protos/config.proto
```

This creates:
- `client/Sources/PraxiaChild/Generated/praxia/v1/trial.pb.swift`
- `client/Sources/PraxiaChild/Generated/praxia/v1/trial.grpc.swift`
- `client/Sources/PraxiaChild/Generated/praxia/v1/audio.pb.swift`
- `client/Sources/PraxiaChild/Generated/praxia/v1/audio.grpc.swift`
- `client/Sources/PraxiaChild/Generated/praxia/v1/config.pb.swift`
- `client/Sources/PraxiaChild/Generated/praxia/v1/config.grpc.swift`

## Step 2: Create TrialServiceGRPCClient

Create a new file: `client/Sources/PraxiaChild/Service/TrialServiceGRPCClient.swift`

```swift
import Foundation
import GRPC
import NIO
import Praxia_V1  // Generated protobuf module

/// Production gRPC client for TrialService
/// Implements TrialServiceProtocol for real backend communication
@MainActor
class TrialServiceGRPCClient: TrialServiceProtocol {
    
    private var channel: GRPCChannel?
    private var client: Praxia_V1_TrialServiceClient?
    private let eventLoopGroup: EventLoopGroup
    
    private let host: String
    private let port: Int
    
    // MARK: - Initialization
    
    init(host: String = "localhost", port: Int = 50051) throws {
        self.host = host
        self.port = port
        
        // Create event loop group
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        // Create gRPC channel with plaintext (dev) or TLS (prod)
        let builder = ClientConnection.Configuration
            .default(
                target: .hostAndPort(host, port),
                eventLoopGroup: eventLoopGroup
            )
        
        self.channel = ClientConnection(configuration: builder)
        self.client = Praxia_V1_TrialServiceClient(channel: self.channel!)
    }
    
    // MARK: - TrialServiceProtocol Implementation
    
    func uploadSession(
        childID: String,
        sessionID: String,
        trials: [TrialEventRecord]
    ) async -> UploadResult {
        guard let client = client else {
            return UploadResult(
                success: false,
                uploadedCount: 0,
                failedCount: trials.count,
                message: "gRPC client not initialized"
            )
        }
        
        do {
            // Build proto request
            var request = Praxia_V1_UploadSessionRequest()
            request.deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
            request.sessionID = sessionID
            request.childID = childID
            
            // Convert TrialEventRecord to proto TrialEvent
            request.trialEvents = trials.map { record in
                convertToProtoTrialEvent(record)
            }
            
            // Call gRPC service with timeout
            let call = client.uploadSession(
                request,
                callOptions: CallOptions(
                    timeLimit: .timeout(.milliseconds(30000))
                )
            )
            
            let response = try await call.response
            
            return UploadResult(
                success: true,
                uploadedCount: Int(response.acceptedCount),
                failedCount: Int(response.errorCount),
                message: "Upload successful"
            )
            
        } catch let error as GRPCStatus {
            print("❌ gRPC error: \(error.message ?? "Unknown") (code: \(error.code))")
            return UploadResult(
                success: false,
                uploadedCount: 0,
                failedCount: trials.count,
                message: "gRPC error: \(error.message ?? "Unknown")"
            )
        } catch {
            print("❌ Upload error: \(error)")
            return UploadResult(
                success: false,
                uploadedCount: 0,
                failedCount: trials.count,
                message: error.localizedDescription
            )
        }
    }
    
    func getTargets(childID: String) async -> TargetConfigResult {
        // TODO: Implement GetTargets RPC call
        return TargetConfigResult(
            success: false,
            targets: [],
            message: "Not yet implemented"
        )
    }
    
    func getSyncStatus(sessionID: String) -> SyncStatus {
        // TODO: Implement sync status query
        return SyncStatus(
            sessionID: sessionID,
            syncedCount: 0,
            lastSyncAt: Date()
        )
    }
    
    // MARK: - Helper Methods
    
    private func convertToProtoTrialEvent(_ record: TrialEventRecord) -> Praxia_V1_TrialEvent {
        var event = Praxia_V1_TrialEvent()
        
        event.eventID = record.eventID
        event.sessionID = record.sessionID
        event.childID = record.childID
        event.trialID = record.trialID
        event.ordinal = Int32(record.ordinal)
        event.targetID = record.targetID
        event.deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        event.appVersion = Bundle.main.appVersion
        event.protocolVersion = "1.0"
        event.schemaVersion = "1.0"
        
        // Set client timestamp
        var timestamp = Google_Protobuf_Timestamp()
        timestamp.seconds = Int64(record.createdAt.timeIntervalSince1970)
        event.clientTs = timestamp
        
        // Set Tier-1 signals if available
        if let tier1 = record.tier1Signals {
            event.tier1Signals.vocalizationDetected = tier1.vocalizationDetected
            event.tier1Signals.latencyMs = Int32(tier1.latencyMs)
            event.tier1Signals.durationMs = Int32(tier1.durationMs)
            event.tier1Signals.syllableCount = Int32(tier1.syllableCount)
            event.tier1Signals.snrDb = tier1.snrDb
        }
        
        return event
    }
    
    // MARK: - Cleanup
    
    func shutdown() async throws {
        try await channel?.close()
        try await eventLoopGroup.shutdownGracefully()
    }
    
    deinit {
        // Note: Should call shutdown() before dealloc in production
        try? channel?.close()
    }
}

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}
```

## Step 3: Update SessionViewController Dependency Injection

Modify the app's initialization to use the real gRPC client instead of mock:

**Before (mock):**
```swift
let trialService: TrialServiceProtocol = LocalTrialServiceMock()
let sessionVC = SessionViewController(
    trialEngine: engine,
    audioManager: audioManager,
    trialStore: store,
    trialService: trialService  // Uses mock
)
```

**After (real gRPC):**
```swift
let trialService: TrialServiceProtocol = try TrialServiceGRPCClient(
    host: "localhost",  // Change to backend host in production
    port: 50051
)
let sessionVC = SessionViewController(
    trialEngine: engine,
    audioManager: audioManager,
    trialStore: store,
    trialService: trialService  // Uses real gRPC client
)
```

## Step 4: Verify Integration

### Local Testing

1. **Start backend services:**
```bash
cd /path/to/casapraxia/backend
make docker-up
```

2. **Build iOS app in Xcode:**
```bash
xcode-select --install  # if needed
open client/Package.swift  # Opens in Xcode
# Select Product -> Build
```

3. **Run iOS simulator:**
```bash
xcode-select -s /Applications/Xcode.app/Contents/Developer
# In Xcode: Product -> Run (or Cmd+R)
```

4. **Run integration tests:**
```bash
# In Xcode: Product -> Test (or Cmd+U)
```

### Backend Verification

After running a test session on iOS, verify the data was uploaded:

```bash
# Connect to backend database
docker-compose exec postgres psql -U praxia -d praxia_dev

# Query uploaded trials
SELECT COUNT(*) FROM trials;
SELECT * FROM trials ORDER BY created_at DESC LIMIT 5;
```

## Troubleshooting

### "Channel error" or "Connection refused"

- Verify backend is running: `curl localhost:50051` (should not timeout)
- Check firewall: `lsof -i :50051`
- Ensure iOS simulator can reach host: Change `localhost` to machine IP if needed

### "gRPC version mismatch"

- Ensure grpc-swift version matches backend: `grep grpc-swift Package.swift`
- Regenerate Swift code if backend proto version changed

### "Permission denied" errors

- Verify file permissions: `chmod +x client/Sources/PraxiaChild/Generated/*`
- Check SQLCipher encryption key in TrialStore

## Migration from Mock to Real gRPC

The protocol-based design makes this seamless:

1. ✅ `LocalTrialServiceMock` implements `TrialServiceProtocol`
2. ✅ `TrialServiceGRPCClient` also implements `TrialServiceProtocol`
3. ✅ `SessionViewController` accepts any `TrialServiceProtocol`
4. ✅ No changes needed to view controllers or business logic
5. ✅ Switch client by changing one line in app initialization

## Performance Targets

- Upload latency: < 5 seconds for typical session
- Per-trial overhead: < 50ms gRPC encoding/transmission
- Retry logic: Exponential backoff (100ms, 200ms, 400ms)

## Security Considerations

**Development (localhost, plaintext):**
```swift
let channel = ClientConnection.Configuration.default(
    target: .hostAndPort("localhost", 50051),
    eventLoopGroup: eventLoopGroup
)
```

**Production (remote host, TLS):**
```swift
let tlsConfig = ClientConnection.Configuration.TLSConfiguration(
    certificateChain: [.pem(cert)],
    privateKey: .pem(key),
    trustRoots: .custom([.pem(caChain)])
)
let channel = ClientConnection.Configuration.default(
    target: .hostAndPort("api.praxia.example.com", 443),
    eventLoopGroup: eventLoopGroup,
    tls: tlsConfig
)
```

## References

- Backend gRPC: `/backend/protos/*.proto`
- Generated Swift: `/client/Sources/PraxiaChild/Generated/`
- Protocol definition: `/client/Sources/PraxiaChild/Service/TrialServiceClient.swift`
- LocalTrialServiceMock: `/client/Sources/PraxiaChild/Service/LocalTrialServiceMock.swift`
- grpc-swift docs: https://github.com/grpc/grpc-swift
- Swift Protobuf: https://github.com/apple/swift-protobuf
