package service

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/sirupsen/logrus"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/praxia-ai/backend/internal/db"
	pb "github.com/praxia-ai/backend/pkg/gen/audio/v1"
	s3pkg "github.com/praxia-ai/backend/pkg/s3"
)

// AudioService implements the audio service
type AudioService struct {
	db     *db.DB
	s3     *s3pkg.Client
	log    *logrus.Logger
	pb.UnimplementedAudioServiceServer
}

// NewAudioService creates a new audio service
func NewAudioService(db *db.DB, s3 *s3pkg.Client, log *logrus.Logger) *AudioService {
	return &AudioService{
		db:  db,
		s3:  s3,
		log: log,
	}
}

// UploadAudio uploads an audio blob and stores metadata
func (s *AudioService) UploadAudio(ctx context.Context, req *pb.UploadAudioRequest) (*pb.UploadAudioResponse, error) {
	s.log.WithField("trial_id", req.TrialId).Info("uploading audio")

	if req.TrialId == "" || len(req.AudioBlob) == 0 {
		return nil, fmt.Errorf("trial_id and audio_blob are required")
	}

	// Check that trial exists
	var trialExists bool
	err := s.db.Conn().QueryRowContext(ctx,
		"SELECT EXISTS(SELECT 1 FROM trial_events WHERE trial_id = $1)",
		req.TrialId,
	).Scan(&trialExists)
	if err != nil {
		return nil, fmt.Errorf("failed to check trial: %w", err)
	}

	if !trialExists {
		return nil, fmt.Errorf("trial not found: %s", req.TrialId)
	}

	// Generate S3 path
	s3Path := fmt.Sprintf("s3://audio/%s/%s.opus", req.SessionId, req.TrialId)

	// Upload to S3
	uploadedPath, err := s.s3.UploadAudio(s3Path, req.AudioBlob, req.ContentType)
	if err != nil {
		s.log.WithError(err).WithField("trial_id", req.TrialId).Error("failed to upload audio to S3")
		return nil, fmt.Errorf("failed to upload audio: %w", err)
	}

	// Store metadata in database
	uploadedAt := time.Now().UTC()
	_, err = s.db.Conn().ExecContext(ctx,
		`INSERT INTO attempt_recordings
			(trial_id, duration_seconds, sample_rate, channels, bit_depth, uploaded_at, s3_path, content_type)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
		req.TrialId, req.DurationSeconds, req.SampleRate, req.Channels, req.BitDepth,
		uploadedAt, uploadedPath, req.ContentType,
	)
	if err != nil {
		s.log.WithError(err).WithField("trial_id", req.TrialId).Error("failed to store audio metadata")
		// Try to delete from S3 on failure
		_ = s.s3.DeleteAudio(uploadedPath)
		return nil, fmt.Errorf("failed to store audio metadata: %w", err)
	}

	s.log.WithField("trial_id", req.TrialId).WithField("s3_path", uploadedPath).Info("audio uploaded successfully")

	return &pb.UploadAudioResponse{
		TrialId:   req.TrialId,
		S3Path:    uploadedPath,
		UploadedAt: timestamppb.New(uploadedAt),
		Message:   "Audio uploaded successfully",
	}, nil
}

// GetAudioStatus retrieves the status of audio for a trial
func (s *AudioService) GetAudioStatus(ctx context.Context, req *pb.GetAudioStatusRequest) (*pb.GetAudioStatusResponse, error) {
	s.log.WithField("trial_id", req.TrialId).Debug("getting audio status")

	if req.TrialId == "" {
		return nil, fmt.Errorf("trial_id is required")
	}

	var s3Path sql.NullString
	var retentionExpires sql.NullTime

	err := s.db.Conn().QueryRowContext(ctx,
		"SELECT audio_path, audio_retention_expires FROM trial_events WHERE trial_id = $1",
		req.TrialId,
	).Scan(&s3Path, &retentionExpires)

	if err == sql.ErrNoRows {
		return &pb.GetAudioStatusResponse{
			Status: pb.AudioStatus_NOT_FOUND,
		}, nil
	} else if err != nil {
		return nil, fmt.Errorf("failed to query audio status: %w", err)
	}

	status := pb.AudioStatus_NOT_FOUND

	if s3Path.Valid && s3Path.String != "" {
		if retentionExpires.Valid {
			if retentionExpires.Time.Before(time.Now()) {
				status = pb.AudioStatus_EXPIRED
			} else {
				// Check if actually exists in S3
				exists, err := s.s3.Exists(s3Path.String)
				if err != nil {
					s.log.WithError(err).WithField("s3_path", s3Path.String).Warn("failed to check S3 existence")
					status = pb.AudioStatus_DELETED
				} else if exists {
					status = pb.AudioStatus_AVAILABLE
				} else {
					status = pb.AudioStatus_DELETED
				}
			}
		}
	}

	resp := &pb.GetAudioStatusResponse{Status: status}

	if s3Path.Valid {
		resp.S3Path = s3Path.String
	}

	if retentionExpires.Valid {
		resp.RetentionExpires = timestamppb.New(retentionExpires.Time)
	}

	return resp, nil
}

// GetAudioMetadata retrieves full metadata for audio
func (s *AudioService) GetAudioMetadata(ctx context.Context, req *pb.GetAudioMetadataRequest) (*pb.GetAudioMetadataResponse, error) {
	s.log.WithField("trial_id", req.TrialId).Debug("getting audio metadata")

	if req.TrialId == "" {
		return nil, fmt.Errorf("trial_id is required")
	}

	var s3Path sql.NullString
	var duration sql.NullFloat64
	var sampleRate sql.NullInt32
	var channels sql.NullInt32
	var bitDepth sql.NullInt32
	var uploadedAt sql.NullTime
	var retentionExpires sql.NullTime

	err := s.db.Conn().QueryRowContext(ctx,
		`SELECT ar.s3_path, ar.duration_seconds, ar.sample_rate, ar.channels, ar.bit_depth,
			    ar.uploaded_at, t.audio_retention_expires
		 FROM attempt_recordings ar
		 JOIN trial_events t ON ar.trial_id = t.trial_id
		 WHERE ar.trial_id = $1`,
		req.TrialId,
	).Scan(&s3Path, &duration, &sampleRate, &channels, &bitDepth, &uploadedAt, &retentionExpires)

	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("audio not found for trial: %s", req.TrialId)
	} else if err != nil {
		return nil, fmt.Errorf("failed to query audio metadata: %w", err)
	}

	// Determine status
	status := pb.AudioStatus_NOT_FOUND
	if s3Path.Valid && s3Path.String != "" {
		if retentionExpires.Valid {
			if retentionExpires.Time.Before(time.Now()) {
				status = pb.AudioStatus_EXPIRED
			} else {
				exists, err := s.s3.Exists(s3Path.String)
				if err != nil {
					s.log.WithError(err).Warn("failed to check S3 existence")
					status = pb.AudioStatus_DELETED
				} else if exists {
					status = pb.AudioStatus_AVAILABLE
				} else {
					status = pb.AudioStatus_DELETED
				}
			}
		}
	}

	metadata := &pb.AudioMetadata{
		TrialId: req.TrialId,
		Status:  status,
	}

	if s3Path.Valid {
		metadata.S3Path = s3Path.String
	}

	if duration.Valid {
		d := float32(duration.Float64)
		metadata.DurationSeconds = d
	}

	if sampleRate.Valid {
		metadata.SampleRate = sampleRate.Int32
	}

	if channels.Valid {
		metadata.Channels = channels.Int32
	}

	if bitDepth.Valid {
		metadata.BitDepth = bitDepth.Int32
	}

	if uploadedAt.Valid {
		metadata.UploadedAt = timestamppb.New(uploadedAt.Time)
	}

	if retentionExpires.Valid {
		metadata.RetentionExpires = timestamppb.New(retentionExpires.Time)
	}

	return &pb.GetAudioMetadataResponse{Metadata: metadata}, nil
}
