package worker

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"time"

	"github.com/nats-io/nats.go"
	"github.com/sirupsen/logrus"

	"github.com/praxia-ai/backend/internal/db"
	s3pkg "github.com/praxia-ai/backend/pkg/s3"
)

// AudioWorker processes audio uploads asynchronously
type AudioWorker struct {
	db   *db.DB
	s3   *s3pkg.Client
	nats *nats.Conn
	log  *logrus.Logger
}

// NewAudioWorker creates a new audio worker
func NewAudioWorker(db *db.DB, s3 *s3pkg.Client, nats *nats.Conn, log *logrus.Logger) *AudioWorker {
	return &AudioWorker{
		db:   db,
		s3:   s3,
		nats: nats,
		log:  log,
	}
}

// Start begins listening for audio events
func (w *AudioWorker) Start(ctx context.Context) error {
	w.log.Info("starting audio worker")

	// Create durable consumer for audio.uploaded
	sub, err := w.nats.Subscribe("audio.uploaded", w.handleAudioUpload)
	if err != nil {
		return fmt.Errorf("failed to subscribe to audio.uploaded: %w", err)
	}

	w.log.WithField("subscription", "audio.uploaded").Info("subscribed to audio events")

	// Keep running until context is cancelled
	<-ctx.Done()
	sub.Unsubscribe()

	return nil
}

// AudioUploadedMessage represents an audio upload event
type AudioUploadedMessage struct {
	TrialID            string `json:"trial_id"`
	AudioPath          string `json:"audio_path"`
	RetentionExpires   int64  `json:"retention_expires"`
}

// handleAudioUpload processes an audio upload event
func (w *AudioWorker) handleAudioUpload(msg *nats.Msg) {
	var audioMsg AudioUploadedMessage
	if err := json.Unmarshal(msg.Data, &audioMsg); err != nil {
		w.log.WithError(err).Error("failed to unmarshal audio message")
		return
	}

	w.log.WithField("trial_id", audioMsg.TrialID).Debug("processing audio upload")

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Verify audio file exists in S3
	exists, err := w.s3.Exists(audioMsg.AudioPath)
	if err != nil {
		w.log.WithError(err).WithField("s3_path", audioMsg.AudioPath).Error("failed to check S3 existence")
		return
	}

	if !exists {
		w.log.WithField("s3_path", audioMsg.AudioPath).Warn("audio file not found in S3")
		// Log to audit trail
		_ = w.logAuditEvent(ctx, "audio.missing", audioMsg.TrialID, "Audio file not found in S3")
		return
	}

	// In production, you would:
	// 1. Download audio from S3
	// 2. Run Tier-2 DSP (DTW exemplar matching)
	// 3. Calculate confidence score
	// 4. Publish result to scores.tier2 topic
	// 5. Update database with results

	w.log.WithField("trial_id", audioMsg.TrialID).Info("audio upload processed")
}

// RetentionWorker handles audio retention and cleanup
type RetentionWorker struct {
	db  *db.DB
	s3  *s3pkg.Client
	log *logrus.Logger
}

// NewRetentionWorker creates a new retention worker
func NewRetentionWorker(db *db.DB, s3 *s3pkg.Client, log *logrus.Logger) *RetentionWorker {
	return &RetentionWorker{
		db:  db,
		s3:  s3,
		log: log,
	}
}

// Start begins the retention cleanup job
func (w *RetentionWorker) Start(ctx context.Context, checkInterval time.Duration) error {
	w.log.Info("starting audio retention worker")

	ticker := time.NewTicker(checkInterval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ticker.C:
			if err := w.cleanupExpiredAudio(ctx); err != nil {
				w.log.WithError(err).Error("failed to cleanup expired audio")
			}
		}
	}
}

// cleanupExpiredAudio removes audio files that have exceeded retention period
func (w *RetentionWorker) cleanupExpiredAudio(ctx context.Context) error {
	w.log.Debug("checking for expired audio files")

	rows, err := w.db.Conn().QueryContext(ctx,
		`SELECT trial_id, audio_path, audio_retention_expires
		 FROM trial_events
		 WHERE audio_path IS NOT NULL
		   AND audio_retention_expires IS NOT NULL
		   AND audio_retention_expires < NOW()
		 LIMIT 100`,
	)
	if err != nil {
		return fmt.Errorf("failed to query expired audio: %w", err)
	}
	defer rows.Close()

	deletedCount := 0
	failedCount := 0

	for rows.Next() {
		var trialID string
		var audioPath string
		var retentionExpires time.Time

		if err := rows.Scan(&trialID, &audioPath, &retentionExpires); err != nil {
			w.log.WithError(err).Error("failed to scan audio record")
			failedCount++
			continue
		}

		// Delete from S3
		if err := w.s3.DeleteAudio(audioPath); err != nil {
			w.log.WithError(err).WithField("s3_path", audioPath).Error("failed to delete audio from S3")
			failedCount++
			continue
		}

		// Clear audio_path from database
		_, err := w.db.Conn().ExecContext(ctx,
			"UPDATE trial_events SET audio_path = NULL WHERE trial_id = $1",
			trialID,
		)
		if err != nil {
			w.log.WithError(err).WithField("trial_id", trialID).Error("failed to update trial event")
			failedCount++
			continue
		}

		// Log retention action
		if err := w.logRetentionAction(ctx, trialID, audioPath, "expired"); err != nil {
			w.log.WithError(err).Error("failed to log retention action")
		}

		deletedCount++
		w.log.WithField("trial_id", trialID).Debug("deleted expired audio")
	}

	if err = rows.Err(); err != nil {
		return fmt.Errorf("error iterating audio records: %w", err)
	}

	if deletedCount > 0 || failedCount > 0 {
		w.log.WithField("deleted", deletedCount).WithField("failed", failedCount).Info("audio cleanup complete")
	}

	return nil
}

// logRetentionAction logs an audio retention action
func (w *RetentionWorker) logRetentionAction(ctx context.Context, trialID, s3Path, action string) error {
	_, err := w.db.Conn().ExecContext(ctx,
		`INSERT INTO audio_retention_log (trial_id, s3_path, action, created_at)
		 VALUES ($1, $2, $3, NOW())`,
		trialID, s3Path, action,
	)
	return err
}

// logAuditEvent logs an audit event
func (w *AudioWorker) logAuditEvent(ctx context.Context, action, trialID, metadata string) error {
	_, err := w.db.Conn().ExecContext(ctx,
		`INSERT INTO audit_log (action, trial_id, metadata, created_at)
		 VALUES ($1, $2, $3, NOW())`,
		action, trialID, metadata,
	)
	return err
}
