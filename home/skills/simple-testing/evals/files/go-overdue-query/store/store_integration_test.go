//go:build integration

package store

import (
	"context"
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"os"
	"testing"
	"time"

	_ "github.com/jackc/pgx/v5/stdlib"
)

func openStore(t *testing.T) *Store {
	t.Helper()
	db, err := sql.Open("pgx", os.Getenv("DATABASE_URL"))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { db.Close() })
	return New(db)
}

func uniqueID(t *testing.T) string {
	t.Helper()
	b := make([]byte, 6)
	if _, err := rand.Read(b); err != nil {
		t.Fatal(err)
	}
	return t.Name() + "-" + hex.EncodeToString(b)
}

func TestCreateGet(t *testing.T) {
	s := openStore(t)
	ctx := context.Background()
	inv := Invoice{ID: uniqueID(t), Customer: "acme", Cents: 1250, DueOn: time.Date(2026, 3, 1, 0, 0, 0, 0, time.UTC)}

	if err := s.Create(ctx, inv); err != nil {
		t.Fatal(err)
	}
	got, err := s.Get(ctx, inv.ID)
	if err != nil {
		t.Fatal(err)
	}
	if got.Customer != "acme" || got.Cents != 1250 || got.PaidAt != nil {
		t.Fatalf("got %+v", got)
	}
}
