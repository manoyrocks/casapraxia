package main

import (
	"context"
	"fmt"
	"net"
	"os"
	"os/signal"
	"syscall"

	"github.com/nats-io/nats.go"
	"github.com/sirupsen/logrus"
	"google.golang.org/grpc"
	"google.golang.org/grpc/health"
	"google.golang.org/grpc/health/grpc_health_v1"

	"github.com/praxia-ai/backend/config"
	"github.com/praxia-ai/backend/internal/db"
	"github.com/praxia-ai/backend/internal/service"
	audiov1 "github.com/praxia-ai/backend/pkg/gen/audio/v1"
	configv1 "github.com/praxia-ai/backend/pkg/gen/config/v1"
	trialv1 "github.com/praxia-ai/backend/pkg/gen/trial/v1"
	s3pkg "github.com/praxia-ai/backend/pkg/s3"
)

func main() {
	// Setup logger
	log := logrus.New()
	log.SetFormatter(&logrus.JSONFormatter{})
	log.SetOutput(os.Stdout)

	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		log.WithError(err).Fatal("failed to load configuration")
	}

	logLevel, err := logrus.ParseLevel(cfg.LogLevel)
	if err != nil {
		logLevel = logrus.InfoLevel
	}
	log.SetLevel(logLevel)

	log.WithField("env", cfg.Environment).Info("praxia backend starting")

	// Connect to database
	database, err := db.New(cfg.DatabaseURL, log)
	if err != nil {
		log.WithError(err).Fatal("failed to connect to database")
	}
	defer database.Close()

	// Run migrations
	migrationsDir := "migrations"
	if _, err := os.Stat(migrationsDir); err == nil {
		if err := database.Migrate(migrationsDir); err != nil {
			log.WithError(err).Fatal("failed to run migrations")
		}
	}

	// Connect to NATS
	natsConn, err := nats.Connect(cfg.NATSUrl)
	if err != nil {
		log.WithError(err).Fatal("failed to connect to NATS")
	}
	defer natsConn.Close()

	// Connect to S3
	s3Client, err := s3pkg.New(cfg.S3Bucket, cfg.S3Region, cfg.S3Endpoint, log)
	if err != nil {
		log.WithError(err).Fatal("failed to connect to S3")
	}

	// Create gRPC server
	grpcServer := grpc.NewServer()

	// Register services
	trialSvc := service.NewTrialService(database, natsConn, log)
	audioSvc := service.NewAudioService(database, s3Client, log)
	configSvc := service.NewConfigService(database, log)

	trialv1.RegisterTrialServiceServer(grpcServer, trialSvc)
	audiov1.RegisterAudioServiceServer(grpcServer, audioSvc)
	configv1.RegisterConfigServiceServer(grpcServer, configSvc)

	// Register health check
	healthSvc := health.NewServer()
	grpc_health_v1.RegisterHealthServer(grpcServer, healthSvc)

	// Listen on port
	listener, err := net.Listen("tcp", fmt.Sprintf(":%d", cfg.GRPCPort))
	if err != nil {
		log.WithError(err).Fatal("failed to listen on port")
	}
	defer listener.Close()

	log.WithField("port", cfg.GRPCPort).Info("gRPC server listening")

	// Start server in a goroutine
	go func() {
		if err := grpcServer.Serve(listener); err != nil {
			log.WithError(err).Error("grpc server error")
		}
	}()

	// Graceful shutdown
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	sig := <-sigChan
	log.WithField("signal", sig).Info("received signal, shutting down")

	grpcServer.GracefulStop()
	natsConn.Close()
	database.Close()

	log.Info("server stopped")
}
