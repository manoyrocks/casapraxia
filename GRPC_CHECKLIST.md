# gRPC Integration Checklist for iOS Developer

This checklist guides the iOS developer through integrating the real gRPC client on macOS.

## Prerequisites ✓

- [ ] macOS machine with Xcode 14+
- [ ] Homebrew installed (`brew --version`)
- [ ] Git repository cloned: `/path/to/casapraxia`

## Step 1: Install Protobuf Compiler (5 minutes)

```bash
# Install protoc
brew install protobuf

# Verify installation
protoc --version
# Expected: libprotoc 3.20.0 or higher
```

- [ ] protoc installed
- [ ] Version is 3.20+

## Step 2: Open Project in Xcode (2 minutes)

```bash
cd /path/to/casapraxia/client
open Package.swift
# Xcode will open with the Package resolved
```

- [ ] Package.swift opens in Xcode
- [ ] Dependencies resolved (GRDB, grpc-swift, swift-protobuf)
- [ ] Build succeeds with Cmd+B (should build successfully with mock client)

## Step 3: Generate Swift Protobuf Code (10 minutes)

**Create output directory:**
```bash
mkdir -p /path/to/casapraxia/client/Sources/PraxiaChild/Generated
```

**Generate Swift code:**
```bash
protoc \
  --swift_out=/path/to/casapraxia/client/Sources/PraxiaChild/Generated \
  --grpc-swift_out=/path/to/casapraxia/client/Sources/PraxiaChild/Generated \
  --swift_opt=Visibility=Public \
  --grpc-swift_opt=Visibility=Public \
  --swift_opt=FileNaming=PathToUnderscores \
  --grpc-swift_opt=FileNaming=PathToUnderscores \
  -I/path/to/casapraxia/backend/protos \
  /path/to/casapraxia/backend/protos/trial.proto \
  /path/to/casapraxia/backend/protos/audio.proto \
  /path/to/casapraxia/backend/protos/config.proto
```

**Verify files created:**
```bash
ls -la client/Sources/PraxiaChild/Generated/praxia/v1/
# Should show: trial.pb.swift, trial.grpc.swift, audio.pb.swift, 
#              audio.grpc.swift, config.pb.swift, config.grpc.swift
```

- [ ] Generated directory created
- [ ] All 6 .swift files present
- [ ] Files are readable

## Step 4: Create TrialServiceGRPCClient (30 minutes)

**File:** `client/Sources/PraxiaChild/Service/TrialServiceGRPCClient.swift`

**Copy from GRPC_INTEGRATION.md Step 2** (the code template provided)

Key points:
- Imports: Foundation, GRPC, NIO, Praxia_V1 (generated)
- Class: `TrialServiceGRPCClient: TrialServiceProtocol`
- Methods:
  - `init(host, port)` - Set up gRPC channel
  - `uploadSession(...)` - Main upload method
  - `getTargets(...)` - Get target config (optional)
  - `getSyncStatus(...)` - Sync tracking (optional)
  - `shutdown()` - Clean up resources
  - `convertToProtoTrialEvent(...)` - Helper for conversion

**Testing:**
```bash
cd /path/to/casapraxia/client
swift build
# Should compile without errors
```

- [ ] File created with all required methods
- [ ] Implements `TrialServiceProtocol`
- [ ] Swift build succeeds
- [ ] No compilation errors

## Step 5: Update App Initialization (5 minutes)

**File:** Your app's main initialization (usually in SceneDelegate or @main app)

**Before (mock):**
```swift
@main
struct PraxiaApp: App {
    let trialService: LocalTrialServiceMock = LocalTrialServiceMock()
    
    var body: some Scene {
        WindowGroup {
            // Your views
        }
    }
}
```

**After (real gRPC):**
```swift
@main
struct PraxiaApp: App {
    let trialService: TrialServiceProtocol
    
    init() {
        do {
            self.trialService = try TrialServiceGRPCClient(
                host: "localhost",
                port: 50051
            )
        } catch {
            // Fallback to mock on error
            print("Warning: gRPC client failed to initialize, using mock")
            self.trialService = LocalTrialServiceMock()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            // Your views
        }
    }
}
```

**In SessionViewController initialization:**
```swift
let sessionVC = SessionViewController(
    trialEngine: engine,
    audioManager: audioManager,
    trialStore: store,
    trialService: trialService  // ← Use the real gRPC client
)
```

- [ ] App initialization updated
- [ ] Uses TrialServiceGRPCClient instead of mock
- [ ] Fallback to mock on errors
- [ ] Project still builds

## Step 6: Start Backend Services (5 minutes)

**In separate terminal:**
```bash
cd /path/to/casapraxia/backend
make docker-up
# Wait for services to start (~30 seconds)

# Verify backend is running
curl localhost:50051
# Should hang or timeout (gRPC, not HTTP)
```

**Check services:**
```bash
docker-compose ps
# Should show: postgres, nats, minio, server (all running)
```

- [ ] Docker Desktop running
- [ ] Backend services started
- [ ] PostgreSQL port 5432 accessible
- [ ] gRPC port 50051 accessible

## Step 7: Build and Run iOS App (10 minutes)

**In Xcode:**
```bash
# Product → Build (Cmd+B)
# Should build successfully

# Product → Run (Cmd+R) or select iOS Simulator
```

**Verify in iOS Simulator:**
1. Open Praxia app
2. Play a practice session (10 trials)
3. End session
4. Check console logs for:
   - "✅ gRPC client connected to localhost:50051"
   - "✅ Session [ID] uploaded successfully"

- [ ] App builds without errors
- [ ] App runs in iOS Simulator
- [ ] Logs show gRPC connection successful
- [ ] Logs show session upload successful

## Step 8: Verify Data in Database (5 minutes)

**Connect to PostgreSQL:**
```bash
docker-compose exec postgres psql -U praxia -d praxia_dev
```

**Check uploaded trials:**
```sql
-- Should show trials from your session
SELECT COUNT(*) FROM trials;
SELECT * FROM trials ORDER BY created_at DESC LIMIT 5;

-- Should show trial events
SELECT COUNT(*) FROM trial_events;
SELECT * FROM trial_events ORDER BY client_ts DESC LIMIT 5;

-- Exit
\q
```

- [ ] PostgreSQL query successful
- [ ] Trials appear in database
- [ ] Trial event records created
- [ ] Data looks correct

## Step 9: Run Tests (10 minutes)

**In Xcode:**
```bash
# Product → Test (Cmd+U)
# Or run specific test suite:
```

**Should pass:**
- TrialServiceProtocolTests (protocol conformance)
- IntegrationTests (10-trial sequence)
- TrialEngineTests (state machine)
- AudioCaptureTests (audio signals)
- TrialStoreTests (persistence)

```bash
# From command line
swift test
```

- [ ] All tests pass
- [ ] No failures or warnings
- [ ] Protocol conformance verified
- [ ] Integration tests use real gRPC

## Step 10: Troubleshooting (if needed)

**Issue: "Connection refused on localhost:50051"**
- ✓ Check: `docker-compose ps` (is server running?)
- ✓ Fix: `cd backend && make docker-up`

**Issue: "Cannot find module 'Praxia_V1'"**
- ✓ Check: Did Step 3 complete successfully?
- ✓ Fix: Re-run protoc command, check file paths

**Issue: "Cannot import GRPC"**
- ✓ Check: `swift build` (does dependency resolution work?)
- ✓ Fix: `swift package resolve` then `swift build`

**Issue: "gRPC timeout or hangs"**
- ✓ Check: Is backend really listening? `curl -v localhost:50051`
- ✓ Fix: Restart backend: `make docker-down && make docker-up`

**Issue: "Build fails with compile errors in generated code"**
- ✓ Check: Is protoc version 3.20+? (`protoc --version`)
- ✓ Fix: `brew upgrade protobuf`

**Issue: "Tests fail with gRPC errors"**
- ✓ Check: Are you using mock or real client in tests?
- ✓ Fix: For local tests, use LocalTrialServiceMock

## Step 11: Documentation

**Document what you did:**
- [ ] Note protoc version used
- [ ] Note gRPC-swift version from Package.swift
- [ ] Note backend host/port for this environment
- [ ] Add any custom changes to GRPC_INTEGRATION.md

## Step 12: Production Preparation (future)

**For staging/production backends:**

1. **Update host/port in app initialization:**
```swift
let trialService = try TrialServiceGRPCClient(
    host: "api.staging.praxia.example.com",  // Change for staging
    port: 443
)
```

2. **Enable TLS in TrialServiceGRPCClient:**
```swift
let tlsConfig = ClientConnection.Configuration.TLSConfiguration(
    certificateChain: [...],
    privateKey: [...],
    trustRoots: [...]
)
```

3. **Update timeout:**
```swift
CallOptions(timeLimit: .timeout(.milliseconds(60000)))  // 60s for production
```

4. **Add exponential backoff:**
```swift
// Implement retry logic for transient errors
// See GRPC_INTEGRATION.md for details
```

- [ ] TLS configured for production
- [ ] Certificate pinning implemented
- [ ] Timeout appropriate for network
- [ ] Retry logic implemented

## Success Criteria

✅ **All of the following must be true:**
1. App builds with `swift build`
2. App runs in iOS Simulator without crashes
3. gRPC client connects to localhost:50051
4. Session upload completes without errors
5. Trials appear in PostgreSQL database
6. All tests pass (`swift test`)
7. No console warnings or errors
8. Mock client still works as fallback

## Support

**If stuck, refer to:**
- `/GRPC_INTEGRATION.md` — Full integration guide
- `/INTEGRATION_SUMMARY.md` — Architecture overview
- `/IMPLEMENTATION.md` — Phase 4B status
- Backend logs: `make docker-logs`
- Database: `docker-compose exec postgres psql -U praxia -d praxia_dev`

**Questions?**
- Check gRPC documentation: https://github.com/grpc/grpc-swift
- Check Protobuf documentation: https://github.com/apple/swift-protobuf
- Check backend implementation: `/backend/cmd/server/main.go`

---

**Estimated total time:** 1.5 - 2 hours  
**Status:** Ready to proceed on macOS with Xcode
