.PHONY: help build run test migrate fmt lint proto proto-clean proto-regen

help:
	@echo "Praxia Backend - Available targets:"
	@echo "  make build         - Build the server binary"
	@echo "  make run           - Run the server locally"
	@echo "  make dev           - Run the server with hot reload"
	@echo "  make test          - Run all tests"
	@echo "  make test-coverage - Run tests with coverage"
	@echo "  make migrate       - Run database migrations"
	@echo "  make docker-build  - Build Docker image"
	@echo "  make docker-up     - Start all services with docker-compose"
	@echo "  make docker-down   - Stop all services"
	@echo "  make docker-logs   - Show docker-compose logs"
	@echo "  make proto         - Generate protobuf code"
	@echo "  make fmt           - Format code"
	@echo "  make lint          - Run linter"
	@echo "  make clean         - Clean build artifacts"

# Build the binary
build:
	@echo "Building server..."
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o bin/server ./cmd/server

# Run the server
run: build
	@echo "Running server..."
	./bin/server

# Run with hot reload (requires 'air')
dev:
	@which air > /dev/null || (echo "Installing air..." && go install github.com/cosmtrek/air@latest)
	air

# Run tests
test:
	@echo "Running tests..."
	go test -v -race -timeout 30s ./...

# Run tests with coverage
test-coverage:
	@echo "Running tests with coverage..."
	go test -v -race -timeout 30s -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report: coverage.html"

# Database migrations
migrate:
	@echo "Running migrations..."
	go run cmd/migrate/main.go

# Docker build
docker-build:
	@echo "Building Docker image..."
	docker build -f deploy/docker/Dockerfile -t praxia-backend:latest .

# Docker compose
docker-up:
	@echo "Starting services with docker-compose..."
	docker-compose up -d

docker-down:
	@echo "Stopping services..."
	docker-compose down

docker-logs:
	docker-compose logs -f

# Protobuf code generation
proto:
	@echo "Generating protobuf stubs from protos/*.proto..."
	@which protoc > /dev/null || (echo "Error: protoc not found. Install: apt-get install protobuf-compiler" && exit 1)
	@echo "Note: Requires Go >= 1.25 and plugins:"
	@echo "  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest"
	@echo "  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest"
	protoc \
		--go_out=. \
		--go-grpc_out=. \
		--go_opt=paths=source_relative \
		--go-grpc_opt=paths=source_relative \
		protos/*.proto
	@echo "✓ Protobuf stubs generated in pkg/gen/praxia/v1/"

proto-clean:
	@echo "Removing generated .pb.go files..."
	find pkg/gen -name "*.pb.go" -delete
	@echo "✓ Generated files cleaned"

proto-regen: proto-clean proto
	@echo "✓ Protobuf regeneration complete"

# Code formatting
fmt:
	@echo "Formatting code..."
	go fmt ./...

# Linting
lint:
	@echo "Linting code..."
	@which golangci-lint > /dev/null || (echo "Installing golangci-lint..." && go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest)
	golangci-lint run ./...

# Clean
clean:
	@echo "Cleaning build artifacts..."
	rm -rf bin/
	go clean

# Health check
health:
	@echo "Checking service health..."
	@curl -s localhost:8222/connz | jq .
