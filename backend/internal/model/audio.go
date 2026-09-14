package model

import "time"

// AudioRecording represents a stored audio file
type AudioRecording struct {
	ID                int64
	TrialID           string
	DurationSeconds   *float32
	SampleRate        *int32
	Channels          *int32
	BitDepth          *int32
	UploadedAt        *time.Time
	S3Path            string
	ContentType       string
	CreatedAt         time.Time
}

// AudioStatus represents the current status of audio
type AudioStatus string

const (
	AudioStatusAvailable AudioStatus = "available"
	AudioStatusExpired   AudioStatus = "expired"
	AudioStatusDeleted   AudioStatus = "deleted"
	AudioStatusNotFound  AudioStatus = "not_found"
)

// AudioRetentionLog records audio deletion/retention actions
type AudioRetentionLog struct {
	ID                int64
	TrialID           *string
	S3Path            *string
	Action            string // 'expired' | 'manually_deleted' | 'consent_revoked'
	RetentionReason   *string
	CreatedAt         time.Time
}
