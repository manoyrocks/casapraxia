package service

import (
	"context"
	"database/sql"
	"fmt"

	"github.com/sirupsen/logrus"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/praxia-ai/backend/internal/db"
	pb "github.com/praxia-ai/backend/pkg/gen/config/v1"
)

// ConfigService implements the config service
type ConfigService struct {
	db  *db.DB
	log *logrus.Logger
	pb.UnimplementedConfigServiceServer
}

// NewConfigService creates a new config service
func NewConfigService(db *db.DB, log *logrus.Logger) *ConfigService {
	return &ConfigService{
		db:  db,
		log: log,
	}
}

// GetProgram retrieves the active therapy program for a child
func (s *ConfigService) GetProgram(ctx context.Context, req *pb.GetProgramRequest) (*pb.GetProgramResponse, error) {
	s.log.WithField("child_id", req.ChildId).Debug("getting program")

	if req.ChildId == "" {
		return nil, fmt.Errorf("child_id is required")
	}

	var programID sql.NullString
	err := s.db.Conn().QueryRowContext(ctx,
		"SELECT current_program_id FROM children WHERE id = $1",
		req.ChildId,
	).Scan(&programID)

	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("child not found: %s", req.ChildId)
	} else if err != nil {
		return nil, fmt.Errorf("failed to query child: %w", err)
	}

	if !programID.Valid || programID.String == "" {
		return nil, fmt.Errorf("no active program for child: %s", req.ChildId)
	}

	var id, name, description sql.NullString
	var version int32

	err = s.db.Conn().QueryRowContext(ctx,
		"SELECT id, name, version, description FROM programs WHERE id = $1",
		programID.String,
	).Scan(&id, &name, &version, &description)

	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("program not found: %s", programID.String)
	} else if err != nil {
		return nil, fmt.Errorf("failed to query program: %w", err)
	}

	program := &pb.Program{
		Id:      id.String,
		Name:    name.String,
		Version: version,
	}

	if description.Valid {
		program.Description = &description.String
	}

	return &pb.GetProgramResponse{Program: program}, nil
}

// GetTargets retrieves all active targets for a child's program
func (s *ConfigService) GetTargets(ctx context.Context, req *pb.GetTargetsRequest) (*pb.GetTargetsResponse, error) {
	s.log.WithField("child_id", req.ChildId).WithField("program_id", req.ProgramId).Debug("getting targets")

	if req.ChildId == "" || req.ProgramId == "" {
		return nil, fmt.Errorf("child_id and program_id are required")
	}

	rows, err := s.db.Conn().QueryContext(ctx,
		`SELECT id, program_id, word, phonetic_features, stimulability_score
		 FROM targets
		 WHERE program_id = $1
		 ORDER BY word ASC`,
		req.ProgramId,
	)

	if err != nil {
		return nil, fmt.Errorf("failed to query targets: %w", err)
	}
	defer rows.Close()

	var targets []*pb.Target
	for rows.Next() {
		var id, word string
		var programID string
		var phoneticFeatures sql.NullString
		var stimScore sql.NullFloat64

		err := rows.Scan(&id, &programID, &word, &phoneticFeatures, &stimScore)
		if err != nil {
			s.log.WithError(err).Error("failed to scan target")
			continue
		}

		target := &pb.Target{
			Id:       id,
			Word:     word,
		}

		if phoneticFeatures.Valid {
			target.PhoneticFeatures = &phoneticFeatures.String
		}

		if stimScore.Valid {
			score := float32(stimScore.Float64)
			target.StimulabilityScore = &score
		}

		targets = append(targets, target)
	}

	if err = rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating targets: %w", err)
	}

	return &pb.GetTargetsResponse{Targets: targets}, nil
}

// GetCueHierarchy retrieves cue levels for a target
func (s *ConfigService) GetCueHierarchy(ctx context.Context, req *pb.GetCueHierarchyRequest) (*pb.GetCueHierarchyResponse, error) {
	s.log.WithField("target_id", req.TargetId).WithField("program_id", req.ProgramId).Debug("getting cue hierarchy")

	if req.TargetId == "" || req.ProgramId == "" {
		return nil, fmt.Errorf("target_id and program_id are required")
	}

	rows, err := s.db.Conn().QueryContext(ctx,
		`SELECT id, target_id, version, level, description, visual_cue, gestural_cue, rhythmic_cue, frame_cue, created_at
		 FROM cue_hierarchies
		 WHERE target_id = $1
		 ORDER BY version DESC, level ASC
		 LIMIT 6`,
		req.TargetId,
	)

	if err != nil {
		return nil, fmt.Errorf("failed to query cue hierarchy: %w", err)
	}
	defer rows.Close()

	var hierarchy *pb.CueHierarchy
	var levels []*pb.CueLevel
	var version int32

	for rows.Next() {
		var id, targetID string
		var v, level int32
		var desc, visual, gestural, rhythmic, frame sql.NullString
		var createdAt sql.NullTime

		err := rows.Scan(&id, &targetID, &v, &level, &desc, &visual, &gestural, &rhythmic, &frame, &createdAt)
		if err != nil {
			s.log.WithError(err).Error("failed to scan cue level")
			continue
		}

		if hierarchy == nil {
			hierarchy = &pb.CueHierarchy{
				TargetId: targetID,
				Version:  v,
			}
			version = v
		}

		cueLevel := &pb.CueLevel{
			Level: level,
		}

		if desc.Valid {
			cueLevel.Description = &desc.String
		}
		if visual.Valid {
			cueLevel.VisualCue = &visual.String
		}
		if gestural.Valid {
			cueLevel.GesturalCue = &gestural.String
		}
		if rhythmic.Valid {
			cueLevel.RhythmicCue = &rhythmic.String
		}
		if frame.Valid {
			cueLevel.FrameCue = &frame.String
		}

		levels = append(levels, cueLevel)
	}

	if err = rows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating cue hierarchy: %w", err)
	}

	if hierarchy == nil {
		return nil, fmt.Errorf("no cue hierarchy found for target: %s", req.TargetId)
	}

	hierarchy.Levels = levels

	return &pb.GetCueHierarchyResponse{Hierarchy: hierarchy}, nil
}

// GetAAC retrieves AAC board configuration for a child
func (s *ConfigService) GetAAC(ctx context.Context, req *pb.GetAACRequest) (*pb.GetAACResponse, error) {
	s.log.WithField("child_id", req.ChildId).Debug("getting AAC board")

	if req.ChildId == "" {
		return nil, fmt.Errorf("child_id is required")
	}

	// Get the most recent AAC board
	var boardID string
	var version int32
	var createdAt sql.NullTime

	err := s.db.Conn().QueryRowContext(ctx,
		`SELECT id, version, created_at
		 FROM aac_boards
		 WHERE child_id = $1
		 ORDER BY version DESC
		 LIMIT 1`,
		req.ChildId,
	).Scan(&boardID, &version, &createdAt)

	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("no AAC board found for child: %s", req.ChildId)
	} else if err != nil {
		return nil, fmt.Errorf("failed to query AAC board: %w", err)
	}

	// Get board cells
	cellRows, err := s.db.Conn().QueryContext(ctx,
		`SELECT id, board_id, position, emoji, text, target_word, active, created_at
		 FROM aac_cells
		 WHERE board_id = $1
		 ORDER BY position ASC`,
		boardID,
	)

	if err != nil {
		return nil, fmt.Errorf("failed to query AAC cells: %w", err)
	}
	defer cellRows.Close()

	var cells []*pb.AACCell
	for cellRows.Next() {
		var id int64
		var boardIDRow, text string
		var position int32
		var emoji, targetWord sql.NullString
		var active bool
		var cellCreatedAt sql.NullTime

		err := cellRows.Scan(&id, &boardIDRow, &position, &emoji, &text, &targetWord, &active, &cellCreatedAt)
		if err != nil {
			s.log.WithError(err).Error("failed to scan AAC cell")
			continue
		}

		cell := &pb.AACCell{
			Position: position,
			Text:     text,
			Active:   active,
		}

		if emoji.Valid {
			cell.Emoji = &emoji.String
		}
		if targetWord.Valid {
			cell.TargetWord = &targetWord.String
		}

		cells = append(cells, cell)
	}

	if err = cellRows.Err(); err != nil {
		return nil, fmt.Errorf("error iterating AAC cells: %w", err)
	}

	board := &pb.AACBoard{
		ChildId: req.ChildId,
		Version: version,
		Cells:   cells,
	}

	if createdAt.Valid {
		board.CreatedAt = timestamppb.New(createdAt.Time)
	}

	return &pb.GetAACResponse{Board: board}, nil
}
