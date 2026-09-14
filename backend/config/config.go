package config

import (
	"fmt"
	"os"
	"strconv"
)

// Config holds all application configuration
type Config struct {
	// Server
	GRPCPort int
	HTTPPort int

	// Database
	DatabaseURL string

	// AWS S3
	S3Bucket   string
	S3Region   string
	S3Endpoint string // optional, for minio

	// NATS
	NATSUrl string

	// Redis
	RedisURL string

	// Retention
	AudioRetentionDays int // default 90

	// Environment
	Environment string // "dev", "staging", "production"

	// Logging
	LogLevel string

	// TLS
	TLSCertPath string
	TLSKeyPath  string
}

// Load reads configuration from environment variables
func Load() (*Config, error) {
	cfg := &Config{
		GRPCPort:           getEnvInt("GRPC_PORT", 50051),
		HTTPPort:           getEnvInt("HTTP_PORT", 8080),
		DatabaseURL:        getEnvString("DATABASE_URL", "postgres://localhost/praxia"),
		S3Bucket:           getEnvString("S3_BUCKET", "praxia-audio"),
		S3Region:           getEnvString("S3_REGION", "us-east-1"),
		S3Endpoint:         getEnvString("S3_ENDPOINT", ""),
		NATSUrl:            getEnvString("NATS_URL", "nats://localhost:4222"),
		RedisURL:           getEnvString("REDIS_URL", "redis://localhost:6379"),
		AudioRetentionDays: getEnvInt("AUDIO_RETENTION_DAYS", 90),
		Environment:        getEnvString("ENVIRONMENT", "dev"),
		LogLevel:           getEnvString("LOG_LEVEL", "info"),
		TLSCertPath:        getEnvString("TLS_CERT_PATH", ""),
		TLSKeyPath:         getEnvString("TLS_KEY_PATH", ""),
	}

	// Validate required fields
	if cfg.DatabaseURL == "" {
		return nil, fmt.Errorf("DATABASE_URL is required")
	}

	return cfg, nil
}

func getEnvString(key, defaultVal string) string {
	if val, ok := os.LookupEnv(key); ok {
		return val
	}
	return defaultVal
}

func getEnvInt(key string, defaultVal int) int {
	if val, ok := os.LookupEnv(key); ok {
		if intVal, err := strconv.Atoi(val); err == nil {
			return intVal
		}
	}
	return defaultVal
}
