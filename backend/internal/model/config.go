package model

import "time"

// Program represents a therapy program
type Program struct {
	ID          string
	Name        string
	Version     int32
	Description *string
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

// Target represents a target word or sound
type Target struct {
	ID                   string
	ProgramID            string
	Word                 string
	PhoneticFeatures     *string // IPA
	StimulabilityScore   *float32
	CreatedAt            time.Time
	UpdatedAt            time.Time
}

// CueHierarchy represents the cue levels for a target
type CueHierarchy struct {
	ID          string
	TargetID    string
	Version     int32
	Level       int32 // 0-5
	Description *string
	VisualCue   *string
	GesturalCue *string
	RhythmicCue *string
	FrameCue    *string
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

// AACBoard represents an Augmentative & Alternative Communication board
type AACBoard struct {
	ID        string
	ChildID   string
	Version   int32
	Cells     []*AACCell
	CreatedAt time.Time
	UpdatedAt time.Time
}

// AACCell represents a single cell on an AAC board (8-cell board)
type AACCell struct {
	ID         int64
	BoardID    string
	Position   int32 // 0-7
	Emoji      *string
	Text       string
	TargetWord *string
	Active     bool
	CreatedAt  time.Time
	UpdatedAt  time.Time
}
