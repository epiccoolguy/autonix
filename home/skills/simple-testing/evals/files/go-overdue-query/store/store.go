package store

import (
	"context"
	"database/sql"
	"time"
)

type Invoice struct {
	ID       string
	Customer string
	Cents    int64
	DueOn    time.Time
	PaidAt   *time.Time
}

type Store struct {
	db *sql.DB
}

func New(db *sql.DB) *Store {
	return &Store{db: db}
}

func (s *Store) Create(ctx context.Context, inv Invoice) error {
	_, err := s.db.ExecContext(ctx,
		`INSERT INTO invoices (id, customer, cents, due_on, paid_at) VALUES ($1, $2, $3, $4, $5)`,
		inv.ID, inv.Customer, inv.Cents, inv.DueOn, inv.PaidAt)
	return err
}

func (s *Store) Get(ctx context.Context, id string) (Invoice, error) {
	var inv Invoice
	err := s.db.QueryRowContext(ctx,
		`SELECT id, customer, cents, due_on, paid_at FROM invoices WHERE id = $1`, id).
		Scan(&inv.ID, &inv.Customer, &inv.Cents, &inv.DueOn, &inv.PaidAt)
	return inv, err
}
