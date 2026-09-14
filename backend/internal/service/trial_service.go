package service

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/nats-io/nats.go"
	"github.com/sirupsen/logrus"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/praxia-ai/backend/internal/db"
	"github.com/praxia-ai/backend/internal/model"
	pb "github.com/praxia-ai/backend/pkg/gen/trial/v1"
)

// TrialService implements the trial service
type TrialService struct {
	db     *db.DB
	nats   *nats.Conn
	log    *logrus.Logger
	pb.UnimplementedTrialServiceServer
}

// NewTrialService creates a new trial service
func NewTrialService(db *db.DB, nats *nats.Conn, log *logrus.Logger) *TrialService {
	return &TrialService{
		db:   db,
		nats: nats,
		log:  log,
	}
}

// UploadSession processes a batch of trials from iOS
func (s *TrialService) UploadSession(ctx context.Context, req *pb.UploadSessionRequest) (*pb.UploadSessionResponse, error) {
	s.log.WithField("session_id", req.SessionId).WithField("trial_count", len(req.Trials)).Info("processing trial upload")

	if req.SessionId == "" || req.ChildId == "" || req.DeviceId == "" {
		return nil, fmt.Errorf("session_id, child_id, and device_id are required")
	}

	var syncedTrialIDs []string
	var duplicateTrialIDs []string
	var errorCount int32

	tx, err := s.db.Conn().BeginTx(ctx, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback()

	// Ensure session exists
	sessionExists := false
	err = tx.QueryRowContext(ctx, "SELECT id FROM sessions WHERE id = $1", req.SessionId).Scan(&sessionExists)
	if err != nil && err != sql.ErrNoRows {
		return nil, fmt.Errorf("failed to check session: %w", err)
	}

	if !sessionExists {
		// Create session if it doesn't exist
		_, err = tx.ExecContext(ctx,
			"INSERT INTO sessions (id, child_id, start_time) VALUES ($1, $2, $3)",
			req.SessionId, req.ChildId, time.Now().UTC(),
		)
		if err != nil {
			return nil, fmt.Errorf("failed to create session: %w", err)
		}
	}

	// Process each trial
	for _, trial := range req.Trials {
		if trial.TrialId == "" || trial.TargetWord == "" {
			s.log.WithField("trial_id", trial.TrialId).Warn("skipping invalid trial")
			errorCount++
			continue
		}

		// Check for duplicate
		var existingID string
		err := tx.QueryRowContext(ctx, "SELECT trial_id FROM trial_events WHERE trial_id = $1", trial.TrialId).Scan(&existingID)
		if err == nil {
			// Trial already exists
			duplicateTrialIDs = append(duplicateTrialIDs, trial.TrialId)
			s.log.WithField("trial_id", trial.TrialId).Debug("trial already exists")
			continue
		} else if err != sql.ErrNoRows {
			s.log.WithError(err).WithField("trial_id", trial.TrialId).Error("error checking for duplicate")
			errorCount++
			continue
		}

		// Insert trial
		deviceTs := time.Now().UTC()
		if trial.DeviceTimestamp != nil {
			deviceTs = trial.DeviceTimestamp.AsTime()
		}

		scoreStr := scoreToString(trial.Score)
		if scoreStr == "" {
			s.log.WithField("trial_id", trial.TrialId).Warn("invalid score value")
			errorCount++
			continue
		}

		_, err = tx.ExecContext(ctx,
			`INSERT INTO trial_events
				(trial_id, session_id, child_id, device_id, device_timestamp, server_timestamp,
				 target_word, cue_level, score, tier1_vocalization_detected, tier1_latency_ms,
				 tier1_snr_db, tier1_syllable_estimate)
			 VALUES ($1, $2, $3, $4, $5, NOW(), $6, $7, $8, $9, $10, $11, $12)`,
			trial.TrialId, req.SessionId, req.ChildId, req.DeviceId, deviceTs,
			trial.TargetWord, trial.CueLevel, scoreStr,
			trial.Tier1VocalizationDetected, trial.Tier1LatencyMs,
			trial.Tier1SnrDb, trial.Tier1SyllableEstimate,
		)
		if err != nil {
			s.log.WithError(err).WithField("trial_id", trial.TrialId).Error("failed to insert trial")
			errorCount++
			continue
		}

		syncedTrialIDs = append(syncedTrialIDs, trial.TrialId)

		// Set audio retention if audio_path provided
		if trial.AudioPath != "" {
			retentionExpires := time.Now().UTC().AddDate(0, 0, 90) // 90-day default
			_, err = tx.ExecContext(ctx,
				"UPDATE trial_events SET audio_path = $1, audio_retention_expires = $2 WHERE trial_id = $3",
				trial.AudioPath, retentionExpires, trial.TrialId,
			)
			if err != nil {
				s.log.WithError(err).WithField("trial_id", trial.TrialId).Error("failed to update audio path")
			}

			// Publish NATS message for audio processing
			msg := map[string]interface{}{
				"trial_id":             trial.TrialId,
				"audio_path":           trial.AudioPath,
				"retention_expires":    retentionExpires.Unix(),
			}
			if err := s.publishMessage(ctx, "audio.uploaded", msg); err != nil {
				s.log.WithError(err).WithField("trial_id", trial.TrialId).Warn("failed to publish audio message")
			}
		}

		s.log.WithField("trial_id", trial.TrialId).Debug("trial inserted")
	}

	// Commit transaction
	if err := tx.Commit(); err != nil {
		return nil, fmt.Errorf("failed to commit transaction: %w", err)
	}

	s.log.WithField("synced_count", len(syncedTrialIDs)).WithField("duplicate_count", len(duplicateTrialIDs)).
		WithField("error_count", errorCount).Info("upload complete")

	return &pb.UploadSessionResponse{
		SyncedCount:      int32(len(syncedTrialIDs)),
		SyncedTrialIds:   syncedTrialIDs,
		DuplicateCount:   int32(len(duplicateTrialIDs)),
		DuplicateTrialIds: duplicateTrialIDs,
		ErrorCount:       errorCount,
		Message:          fmt.Sprintf("Synced %d trials, %d duplicates, %d errors", len(syncedTrialIDs), len(duplicateTrialIDs), errorCount),
	}, nil
}

// GetSessionTrials retrieves all trials for a session
func (s *TrialService) GetSessionTrials(ctx context.Context, req *pb.GetSessionTrialsRequest) (*pb.GetSessionTrialsResponse, error) {
	s.log.WithField("session_id", req.SessionId).Info("getting session trials")

	if req.SessionId == "" || req.ChildId == "" {
		return nil, fmt.Errorf("session_id and child_id are required")
	}

	rows, err := s.db.Conn().QueryContext(ctx,
		`SELECT trial_id, session_id, child_id, device_id, device_timestamp, server_timestamp,
			    target_word, cue_level, score, tier1_vocalization_detected, tier1_latency_ms,
			    tier1_snr_db, tier1_syllable_estimate, audio_path, audio_retention_expires
		 FROM trial_events
		 WHERE session_id = $1 AND child_id = $2
		 ORDER BY device_timestamp ASC`,
		req.SessionId, req.ChildId,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to query trials: %w", err)
	}
	defer rows.Close()

	var trials []*pb.Trial
	for rows.Next() {
		trial, err := scanTrial(rows)
		if err != nil {
			s.log.WithError(err).Error("failed to scan trial")
			continue
		}
		trials = append(trials, trial)
	}

	if err = rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating trials: %w", err)
	}

	s.log.WithField("count", len(trials)).Debug("retrieved session trials")

	return &pb.GetSessionTrialsResponse{
		Trials:     trials,
		TotalCount: int32(len(trials)),
	}, nil
}

// GetChildProgress retrieves aggregated progress for a child
func (s *TrialService) GetChildProgress(ctx context.Context, req *pb.GetChildProgressRequest) (*pb.GetChildProgressResponse, error) {
	s.log.WithField("child_id", req.ChildId).Info("getting child progress")

	if req.ChildId == "" {
		return nil, fmt.Errorf("child_id is required")
	}

	// Determine time range
	var startTime time.Time
	timeRangeStr := "all_time"
	switch req.TimeRange {
	case pb.TimeRange_THIS_WEEK:
		startTime = time.Now().UTC().AddDate(0, 0, -7)
		timeRangeStr = "this_week"
	case pb.TimeRange_THIS_MONTH:
		startTime = time.Now().UTC().AddDate(0, -1, 0)
		timeRangeStr = "this_month"
	default:
		startTime = time.Time{}
	}

	var whereClause string
	if !startTime.IsZero() {
		whereClause = fmt.Sprintf(" AND server_timestamp >= '%s'", startTime.Format(time.RFC3339))
	}

	// Query cached progress first
	cacheKey := fmt.Sprintf("%s:%s", req.ChildId, timeRangeStr)
	progress, err := s.getCachedProgress(ctx, cacheKey)
	if err == nil && progress != nil {
		return &pb.GetChildProgressResponse{Progress: progress}, nil
	}

	// Query aggregated stats
	query := fmt.Sprintf(`
		SELECT
			COUNT(*) as attempt_count,
			SUM(CASE WHEN score = 'got_it' THEN 1 ELSE 0 END)::float / COUNT(*) * 100 as success_percentage,
			AVG(tier1_latency_ms) as avg_latency,
			AVG(tier1_snr_db) as avg_snr
		FROM trial_events
		WHERE child_id = $1%s
	`, whereClause)

	var attemptCount int32
	var successPercentage sql.NullFloat64
	var avgLatency sql.NullFloat64
	var avgSnr sql.NullFloat64

	err = s.db.Conn().QueryRowContext(ctx, query, req.ChildId).Scan(
		&attemptCount, &successPercentage, &avgLatency, &avgSnr,
	)
	if err != nil && err != sql.ErrNoRows {
		return nil, fmt.Errorf("failed to query progress: %w", err)
	}

	// Query cue level distribution
	distQuery := fmt.Sprintf(`
		SELECT cue_level, COUNT(*) as count
		FROM trial_events
		WHERE child_id = $1%s
		GROUP BY cue_level
		ORDER BY cue_level
	`, whereClause)

	distRows, err := s.db.Conn().QueryContext(ctx, distQuery, req.ChildId)
	if err != nil {
		return nil, fmt.Errorf("failed to query cue level distribution: %w", err)
	}
	defer distRows.Close()

	distribution := make(map[int32]int32)
	for distRows.Next() {
		var level int32
		var count int32
		if err := distRows.Scan(&level, &count); err != nil {
			s.log.WithError(err).Error("failed to scan distribution")
			continue
		}
		distribution[level] = count
	}

	successPct := float32(0)
	if successPercentage.Valid {
		successPct = float32(successPercentage.Float64)
	}

	progress = &pb.ChildProgress{
		AttemptCount:         attemptCount,
		SuccessPercentage:    successPct,
		CueLevelDistribution: distribution,
	}

	if avgLatency.Valid {
		latency := float32(avgLatency.Float64)
		progress.AverageLatencyMs = &latency
	}

	if avgSnr.Valid {
		snr := float32(avgSnr.Float64)
		progress.AverageSnrDb = &snr
	}

	// Cache the result for 1 hour
	_ = s.cacheProgress(ctx, cacheKey, progress, 1*time.Hour)

	return &pb.GetChildProgressResponse{Progress: progress}, nil
}

// QueryTrials performs filtered queries on trials
func (s *TrialService) QueryTrials(ctx context.Context, req *pb.QueryTrialsRequest) (*pb.QueryTrialsResponse, error) {
	s.log.WithField("child_id", req.ChildId).Info("querying trials")

	if req.ChildId == "" {
		return nil, fmt.Errorf("child_id is required")
	}

	// Build query
	query := `SELECT trial_id, session_id, child_id, device_id, device_timestamp, server_timestamp,
			target_word, cue_level, score, tier1_vocalization_detected, tier1_latency_ms,
			tier1_snr_db, tier1_syllable_estimate, audio_path, audio_retention_expires
		 FROM trial_events WHERE child_id = $1`

	args := []interface{}{req.ChildId}
	argIdx := 2

	// Add date range filter
	if req.StartDate != nil {
		query += fmt.Sprintf(` AND device_timestamp >= $%d`, argIdx)
		args = append(args, req.StartDate.AsTime())
		argIdx++
	}

	if req.EndDate != nil {
		query += fmt.Sprintf(` AND device_timestamp <= $%d`, argIdx)
		args = append(args, req.EndDate.AsTime())
		argIdx++
	}

	// Add target word filter
	if req.TargetWord != "" {
		query += fmt.Sprintf(` AND target_word = $%d`, argIdx)
		args = append(args, req.TargetWord)
		argIdx++
	}

	// Add cue level filter
	if req.CueLevel >= 0 && req.CueLevel <= 5 {
		query += fmt.Sprintf(` AND cue_level = $%d`, argIdx)
		args = append(args, req.CueLevel)
		argIdx++
	}

	// Get total count
	countQuery := "SELECT COUNT(*) FROM trial_events WHERE child_id = $1"
	countArgs := []interface{}{req.ChildId}
	if req.TargetWord != "" {
		countQuery += " AND target_word = $2"
		countArgs = append(countArgs, req.TargetWord)
	}

	var totalCount int32
	err := s.db.Conn().QueryRowContext(ctx, countQuery, countArgs...).Scan(&totalCount)
	if err != nil {
		return nil, fmt.Errorf("failed to count trials: %w", err)
	}

	// Add sorting and pagination
	query += ` ORDER BY device_timestamp DESC`

	limit := req.Limit
	if limit == 0 || limit > 1000 {
		limit = 100
	}

	query += fmt.Sprintf(` LIMIT $%d OFFSET $%d`, argIdx, argIdx+1)
	args = append(args, limit, req.Offset)

	rows, err := s.db.Conn().QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("failed to query trials: %w", err)
	}
	defer rows.Close()

	var trials []*pb.TrialDetail
	for rows.Next() {
		trial, err := scanTrial(rows)
		if err != nil {
			s.log.WithError(err).Error("failed to scan trial")
			continue
		}

		// Determine audio status
		audioStatus := "not_found"
		if trial.AudioPath != "" {
			if trial.AudioRetentionExpires != nil {
				if trial.AudioRetentionExpires.AsTime().Before(time.Now()) {
					audioStatus = "expired"
				} else {
					audioStatus = "available"
				}
			}
		}

		trials = append(trials, &pb.TrialDetail{
			Trial:       trial,
			AudioStatus: audioStatus,
		})
	}

	if err = rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating trials: %w", err)
	}

	return &pb.QueryTrialsResponse{
		Trials:     trials,
		TotalCount: totalCount,
		Offset:     req.Offset,
	}, nil
}

// Helper functions

func scanTrial(rows interface {
	Scan(...interface{}) error
}) (*pb.Trial, error) {
	var trial pb.Trial
	var deviceTs sql.NullTime
	var audioRetains sql.NullTime

	err := rows.Scan(
		&trial.TrialId, &trial.SessionId, &trial.ChildId, &trial.DeviceId, &deviceTs, &trial.ServerTimestamp,
		&trial.TargetWord, &trial.CueLevel, (*string)(&trial.Score), &trial.Tier1VocalizationDetected,
		&trial.Tier1LatencyMs, &trial.Tier1SnrDb, &trial.Tier1SyllableEstimate,
		&trial.AudioPath, &audioRetains,
	)
	if err != nil {
		return nil, err
	}

	if deviceTs.Valid {
		trial.DeviceTimestamp = timestamppb.New(deviceTs.Time)
	}

	if audioRetains.Valid {
		trial.AudioRetentionExpires = timestamppb.New(audioRetains.Time)
	}

	// Convert score string to enum
	scoreStr := trial.Score
	trial.Score = stringToScoreValue(scoreStr)

	return &trial, nil
}

func scoreToString(score pb.ScoreValue) string {
	switch score {
	case pb.ScoreValue_GOT_IT:
		return "got_it"
	case pb.ScoreValue_CLOSE:
		return "close"
	case pb.ScoreValue_NOT_YET:
		return "not_yet"
	default:
		return ""
	}
}

func stringToScoreValue(s string) pb.ScoreValue {
	switch s {
	case "got_it":
		return pb.ScoreValue_GOT_IT
	case "close":
		return pb.ScoreValue_CLOSE
	case "not_yet":
		return pb.ScoreValue_NOT_YET
	default:
		return pb.ScoreValue_SCORE_UNSPECIFIED
	}
}

func (s *TrialService) publishMessage(ctx context.Context, subject string, data map[string]interface{}) error {
	// For now, just log. In production, serialize to JSON and publish to NATS
	s.log.WithField("subject", subject).WithField("data", data).Debug("would publish NATS message")
	return nil
}

func (s *TrialService) getCachedProgress(ctx context.Context, key string) (*pb.ChildProgress, error) {
	// TODO: Implement Redis caching
	return nil, fmt.Errorf("not implemented")
}

func (s *TrialService) cacheProgress(ctx context.Context, key string, progress *pb.ChildProgress, ttl time.Duration) error {
	// TODO: Implement Redis caching
	return nil
}
