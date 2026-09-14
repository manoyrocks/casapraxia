# Protobuf Compilation Instructions

**Status:** Ready to use  
**Generated:** 2026-09-14

The Praxia system uses gRPC with Protocol Buffers for all iOS↔Backend communication. This document explains how to generate Swift and Go code from the `.proto` definitions.

---

## Proto Files Location

```
backend/protos/
├── trial.proto       (TrialService messages)
├── config.proto      (ConfigService messages)
└── audio.proto       (AudioService messages)
```

All three files are in the `praxia.v1` package. They share enums and message types via imports.

---

## Prerequisites

### Go Backend

```bash
# Install protoc compiler
# macOS
brew install protobuf

# Ubuntu/Debian
sudo apt-get install protobuf-compiler

# Or build from source
# https://github.com/protocolbuffers/protobuf/releases

# Verify installation
protoc --version  # should be >= 3.21.0
```

### Go Code Generation

```bash
# Install Go protoc plugins
go install github.com/grpc/grpc-go/cmd/protoc-gen-go-grpc@latest
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest

# Verify
which protoc-gen-go
which protoc-gen-go-grpc
```

### Swift / iOS Client

```bash
# Install SwiftProtobuf plugin
# Via Homebrew
brew install swift-protobuf

# Or via CocoaPods (for integration into iOS project)
pod install

# Verify
which protoc-gen-swift  # should exist
```

---

## Generate Go Code (Backend)

### Option 1: Using a Makefile (Recommended)

Create `backend/Makefile`:

```makefile
.PHONY: proto

# Generate Go protobuf stubs
proto:
	protoc \
		--go_out=. \
		--go-grpc_out=. \
		--go_opt=paths=source_relative \
		--go-grpc_opt=paths=source_relative \
		protos/*.proto

# Clean generated files
proto-clean:
	find pkg/gen -name "*.pb.go" -delete

# Regenerate (clean + build)
proto-regen: proto-clean proto
```

### Option 2: Shell Script

```bash
#!/bin/bash
# backend/scripts/generate-protos.sh

cd "$(dirname "$0")/../"

protoc \
  --go_out=. \
  --go-grpc_out=. \
  --go_opt=paths=source_relative \
  --go-grpc_opt=paths=source_relative \
  protos/*.proto

echo "✓ Go protobuf stubs generated"
```

### Run It

```bash
cd backend
make proto
# or
bash scripts/generate-protos.sh
```

### Output

Generated files in `backend/`:

```
pkg/gen/praxia/v1/
├── trial.pb.go
├── trial_grpc.pb.go
├── config.pb.go
├── config_grpc.pb.go
├── audio.pb.go
└── audio_grpc.pb.go
```

---

## Generate Swift Code (iOS Client)

### Option 1: Using Swift Package Manager (Recommended)

Edit `client/Package.swift`:

```swift
let package = Package(
    name: "PraxiaChild",
    platforms: [
        .iOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.17.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.25.0"),
    ],
    targets: [
        .target(
            name: "PraxiaChild",
            dependencies: [
                .product(name: "GRPC", package: "grpc-swift"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
            ],
            path: "Sources/PraxiaChild"
        ),
    ]
)
```

### Option 2: Using a Build Script

Create `client/scripts/generate-protos.sh`:

```bash
#!/bin/bash
# client/scripts/generate-protos.sh

set -e

PROTO_DIR="../../backend/protos"
OUTPUT_DIR="Sources/PraxiaChild/Generated"

mkdir -p "$OUTPUT_DIR"

# Generate Swift protobuf code
protoc \
  --swift_out="$OUTPUT_DIR" \
  --swift_opt=Visibility=Public \
  -I"$PROTO_DIR" \
  "$PROTO_DIR"/*.proto

# Generate gRPC Swift code (requires grpc-swift plugin)
# Note: This requires building grpc-swift locally or using pre-built binaries

echo "✓ Swift protobuf stubs generated in $OUTPUT_DIR"
```

### Run It

```bash
cd client
bash scripts/generate-protos.sh

# Or if using CocoaPods
pod install
```

### Output

Generated files in `client/Sources/PraxiaChild/Generated/`:

```
Generated/
├── Praxia_Trial.pb.swift
├── Praxia_Config.pb.swift
├── Praxia_Audio.pb.swift
└── (gRPC client stubs via grpc-swift)
```

---

## gRPC Swift Client Generation (Advanced)

For full gRPC support in Swift, you need the grpc-swift plugin. This is more complex but enables type-safe gRPC calls from iOS.

### Build grpc-swift Locally

```bash
git clone https://github.com/grpc/grpc-swift.git
cd grpc-swift
swift build -c release
cp .build/release/protoc-gen-grpc-swift /usr/local/bin/
```

### Generate Stubs

```bash
protoc \
  --swift_out="$OUTPUT_DIR" \
  --grpc-swift_out="$OUTPUT_DIR" \
  --swift_opt=Visibility=Public \
  --grpc-swift_opt=Visibility=Public \
  -I"$PROTO_DIR" \
  "$PROTO_DIR"/*.proto
```

---

## CI/CD Integration

### GitHub Actions (Backend)

Add to `.github/workflows/build.yml`:

```yaml
name: Build & Test

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install protobuf
        run: sudo apt-get install -y protobuf-compiler
      
      - name: Install Go plugins
        run: |
          go install github.com/grpc/grpc-go/cmd/protoc-gen-go-grpc@latest
          go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
      
      - name: Generate protos
        run: cd backend && make proto
      
      - name: Build
        run: cd backend && go build -o ./bin/server ./cmd/server
      
      - name: Test
        run: cd backend && go test ./...
```

### GitHub Actions (iOS)

Add to `.github/workflows/ios-build.yml`:

```yaml
name: iOS Build

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install protobuf
        run: brew install protobuf swift-protobuf
      
      - name: Generate protos
        run: cd client && bash scripts/generate-protos.sh
      
      - name: Build iOS
        run: cd client && swift build -c debug
```

---

## Regenerating After Proto Changes

Whenever you modify a `.proto` file:

1. **Go backend:**
   ```bash
   cd backend
   make proto-regen
   git add -A
   git commit -m "chore: regenerate protobuf stubs"
   ```

2. **iOS client:**
   ```bash
   cd client
   bash scripts/generate-protos.sh
   git add -A
   git commit -m "chore: regenerate protobuf stubs"
   ```

Both backends should regenerate and commit the `.pb.go` and `.pb.swift` files so that CI/CD and other developers have up-to-date stubs.

---

## Troubleshooting

### Error: `protoc-gen-go: program not found`

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
```

### Error: `protoc-gen-go-grpc: program not found`

```bash
go install github.com/grpc/grpc-go/cmd/protoc-gen-go-grpc@latest
```

### Error: `protoc-gen-swift: program not found` (Swift)

```bash
brew install swift-protobuf
```

### Go build fails after generating protos

Run `go mod tidy` to sync dependencies:

```bash
cd backend
go mod tidy
go build ./...
```

### Swift package resolution issues

Clear build cache:

```bash
cd client
rm -rf .build
swift build --clean
swift build
```

---

## Validating Generated Code

### Go

```bash
cd backend
go build ./pkg/gen/...
go test ./pkg/gen/...  # should pass (no-op tests)
```

### Swift

```bash
cd client
swift build
```

---

## Using Generated Stubs in Code

### Go Server (Backend)

```go
// cmd/server/main.go
package main

import (
    pb "github.com/praxia-ai/backend/pkg/gen/praxia/v1"
    "github.com/praxia-ai/backend/pkg/trialsvc"
)

func main() {
    trialSvc := trialsvc.NewService(db, nats, s3)
    
    grpcServer := grpc.NewServer()
    pb.RegisterTrialServiceServer(grpcServer, trialSvc)
    // ...
    grpcServer.Serve(lis)
}
```

### Swift Client (iOS)

```swift
// iOS App
import GRPC
import SwiftProtobuf

let channel = ClientConnection(host: "api.praxia.local", port: 50051)
let client = Praxia_TrialServiceClient(channel: channel)

let request = Praxia_UploadSessionRequest.with {
    $0.deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
    $0.sessionID = session.id
    $0.childID = child.id
}

do {
    let response = try await client.uploadSession(request)
    print("Uploaded \(response.acceptedCount) trials")
} catch {
    print("Upload failed: \(error)")
}
```

---

## Proto File Best Practices

1. **Keep packages consistent:** All three proto files use `package praxia.v1`.
2. **Version your API:** Use `v1` now; `v2` only for breaking changes.
3. **Add documentation:** Comment all RPC methods and message fields.
4. **Never delete fields:** Remove by deprecating; add new fields with higher numbers.
5. **Use proper types:** `int32` for cue levels (0-5), `string` for IDs, `google.protobuf.Timestamp` for times.

---

## Reference

- [Protocol Buffers Documentation](https://developers.google.com/protocol-buffers)
- [gRPC Swift Documentation](https://grpc.io/docs/languages/swift/)
- [gRPC Go Documentation](https://grpc.io/docs/languages/go/)

---

**Next:** iOS Dev and Backend Engineer should run these commands and commit the generated stubs to the repository. Then they can start implementing services against the generated interfaces.
