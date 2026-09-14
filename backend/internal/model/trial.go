package model

import (
	"time"
)

// Trial represents a single speech therapy trial
type Trial struct {
	ID                          int64
	TrialID                     string
	SessionID                   string
	ChildID                     string
	DeviceID                    string
	DeviceTimestamp             *time.Time
	ServerTimestamp             time.Time
	TargetWord                  string
	CueLevel                    int32
	Score                       string // 'got_it' | 'close' | 'not_yet'
	Tier1VocalizationDetected   *bool
	Tier1LatencyMs              *int32
	Tier1SnrDb                  *float32
	Tier1SyllableEstimate       *int32
	AudioPath                   *string
	AudioRetentionExpires       *time.Time
	CreatedAt                   time.Time
}

// Session represents a practice session
type Session struct {
	ID              string
	ChildID         string
	StartTime       time.Time
	EndTime         *time.Time
	DurationSeconds *int32
	DeviceID        *string
	Setting         *string // 'home' | 'clinic' | 'tele'
	CreatedAt       time.Time
}

// TrialWithAudio represents a trial with its audio metadata
type TrialWithAudio struct {
	Trial              *Trial
	AudioRecording     *AudioRecording
	AudioStatus        string // 'available' | 'expired' | 'deleted' | 'not_found'
}

// ChildProgress represents aggregated child progress metrics
type ChildProgress struct {
	AttemptCount           int32
	SuccessPercentage      float32
	CueLevelDistribution   map[int32]int32 // cue_level -> count
	AverageLatencyMs       *float32
	AverageSnrDb           *float32
}
