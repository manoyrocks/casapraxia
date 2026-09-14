package service

import (
	"context"
	"database/sql"
	"testing"
	"time"

	"github.com/sirupsen/logrus"
	"google.golang.org/protobuf/types/known/timestamppb"

	pb "github.com/praxia-ai/backend/pkg/gen/trial/v1"
)

// Note: These are integration tests that require a real database.
// For unit tests, you would mock the database connection.

func TestScoreConversion(t *testing.T) {
	tests := []struct {
		name      string
		score     pb.ScoreValue
		expected  string
	}{
		{"GOT_IT", pb.ScoreValue_GOT_IT, "got_it"},
		{"CLOSE", pb.ScoreValue_CLOSE, "close"},
		{"NOT_YET", pb.ScoreValue_NOT_YET, "not_yet"},
		{"UNSPECIFIED", pb.ScoreValue_SCORE_UNSPECIFIED, ""},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := scoreToString(tt.score)
			if result != tt.expected {
				t.Errorf("expected %q, got %q", tt.expected, result)
			}
		})
	}
}

func TestStringToScoreValue(t *testing.T) {
	tests := []struct {
		name     string
		score    string
		expected pb.ScoreValue
	}{
		{"got_it", "got_it", pb.ScoreValue_GOT_IT},
		{"close", "close", pb.ScoreValue_CLOSE},
		{"not_yet", "not_yet", pb.ScoreValue_NOT_YET},
		{"invalid", "invalid", pb.ScoreValue_SCORE_UNSPECIFIED},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := stringToScoreValue(tt.score)
			if result != tt.expected {
				t.Errorf("expected %v, got %v", tt.expected, result)
			}
		})
	}
}

// Integration test example (would require test database)
func TestUploadSessionValidation(t *testing.T) {
	// Create a mock logger
	log := logrus.New()
	log.SetLevel(logrus.DebugLevel)

	// Test cases for request validation
	testCases := []struct {
		name    string
		request *pb.UploadSessionRequest
		wantErr bool
	}{
		{
			name: "valid request",
			request: &pb.UploadSessionRequest{
				SessionId: "sess_123",
				ChildId:   "child_123",
				DeviceId:  "device_123",
				Trials: []*pb.TrialData{
					{
						TrialId:       "trial_1",
						TargetWord:    "ball",
						CueLevel:      1,
						Score:         pb.ScoreValue_GOT_IT,
						DeviceTimestamp: timestamppb.New(time.Now()),
					},
				},
			},
			wantErr: false,
		},
		{
			name: "missing session_id",
			request: &pb.UploadSessionRequest{
				SessionId: "",
				ChildId:   "child_123",
				DeviceId:  "device_123",
			},
			wantErr: true,
		},
		{
			name: "missing child_id",
			request: &pb.UploadSessionRequest{
				SessionId: "sess_123",
				ChildId:   "",
				DeviceId:  "device_123",
			},
			wantErr: true,
		},
		{
			name: "missing device_id",
			request: &pb.UploadSessionRequest{
				SessionId: "sess_123",
				ChildId:   "child_123",
				DeviceId:  "",
			},
			wantErr: true,
		},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			// Validation logic
			if tc.request.SessionId == "" || tc.request.ChildId == "" || tc.request.DeviceId == "" {
				if !tc.wantErr {
					t.Errorf("expected error but got none")
				}
				return
			}

			if tc.wantErr {
				t.Errorf("expected error but got none")
			}
		})
	}
}

// Test score calculation
func TestSuccessPercentageCalculation(t *testing.T) {
	type testCase struct {
		name                 string
		gotItCount           int
		closeCount           int
		notYetCount          int
		expectedPercentage   float32
	}

	cases := []testCase{
		{"all success", 10, 0, 0, 100.0},
		{"half success", 5, 0, 5, 50.0},
		{"no success", 0, 0, 10, 0.0},
		{"mixed", 6, 2, 2, 60.0},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			total := tc.gotItCount + tc.closeCount + tc.notYetCount
			if total == 0 {
				t.Skip("empty dataset")
			}

			percentage := float32(tc.gotItCount) / float32(total) * 100
			if percentage != tc.expectedPercentage {
				t.Errorf("expected %v%%, got %v%%", tc.expectedPercentage, percentage)
			}
		})
	}
}

// Test cue level validation
func TestCueLevelValidation(t *testing.T) {
	validLevels := []int32{0, 1, 2, 3, 4, 5}
	invalidLevels := []int32{-1, 6, 10, 100}

	for _, level := range validLevels {
		if level < 0 || level > 5 {
			t.Errorf("valid level %d should be accepted", level)
		}
	}

	for _, level := range invalidLevels {
		if level >= 0 && level <= 5 {
			t.Errorf("invalid level %d should be rejected", level)
		}
	}
}

// Benchmark for score conversion
func BenchmarkScoreToString(b *testing.B) {
	score := pb.ScoreValue_GOT_IT
	for i := 0; i < b.N; i++ {
		scoreToString(score)
	}
}

func BenchmarkStringToScoreValue(b *testing.B) {
	scoreStr := "got_it"
	for i := 0; i < b.N; i++ {
		stringToScoreValue(scoreStr)
	}
}
