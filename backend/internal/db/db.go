package db

import (
	"database/sql"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"

	_ "github.com/lib/pq"
	"github.com/sirupsen/logrus"
)

// DB wraps the database connection
type DB struct {
	conn *sql.DB
	log  *logrus.Logger
}

// New creates a new database connection
func New(databaseURL string, log *logrus.Logger) (*DB, error) {
	conn, err := sql.Open("postgres", databaseURL)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}

	// Test connection
	if err := conn.Ping(); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	// Set connection pool limits
	conn.SetMaxOpenConns(25)
	conn.SetMaxIdleConns(5)

	log.Info("database connection established")

	return &DB{
		conn: conn,
		log:  log,
	}, nil
}

// Close closes the database connection
func (d *DB) Close() error {
	return d.conn.Close()
}

// Conn returns the underlying database connection
func (d *DB) Conn() *sql.DB {
	return d.conn
}

// Migrate runs all pending migrations
func (d *DB) Migrate(migrationsDir string) error {
	d.log.WithField("dir", migrationsDir).Info("running migrations")

	// Create migrations table if it doesn't exist
	if _, err := d.conn.Exec(`
		CREATE TABLE IF NOT EXISTS schema_migrations (
			version TEXT PRIMARY KEY,
			applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
		)
	`); err != nil {
		return fmt.Errorf("failed to create migrations table: %w", err)
	}

	// Get all migration files
	files, err := os.ReadDir(migrationsDir)
	if err != nil {
		return fmt.Errorf("failed to read migrations directory: %w", err)
	}

	// Sort and filter SQL files
	var migrations []string
	for _, f := range files {
		if f.IsDir() {
			continue
		}
		if !strings.HasSuffix(f.Name(), ".sql") {
			continue
		}
		migrations = append(migrations, f.Name())
	}
	sort.Strings(migrations)

	// Apply each migration
	for _, migrationFile := range migrations {
		version := strings.TrimSuffix(migrationFile, ".sql")

		// Check if already applied
		var count int
		err := d.conn.QueryRow(
			"SELECT COUNT(*) FROM schema_migrations WHERE version = $1",
			version,
		).Scan(&count)
		if err != nil {
			return fmt.Errorf("failed to check migration status: %w", err)
		}

		if count > 0 {
			d.log.WithField("migration", version).Debug("already applied")
			continue
		}

		// Read and execute migration
		content, err := os.ReadFile(filepath.Join(migrationsDir, migrationFile))
		if err != nil {
			return fmt.Errorf("failed to read migration file %s: %w", migrationFile, err)
		}

		if _, err := d.conn.Exec(string(content)); err != nil {
			return fmt.Errorf("failed to apply migration %s: %w", migrationFile, err)
		}

		// Record migration
		if _, err := d.conn.Exec(
			"INSERT INTO schema_migrations (version) VALUES ($1)",
			version,
		); err != nil {
			return fmt.Errorf("failed to record migration %s: %w", version, err)
		}

		d.log.WithField("migration", version).Info("applied")
	}

	return nil
}

// Health checks database connectivity
func (d *DB) Health() error {
	return d.conn.Ping()
}
