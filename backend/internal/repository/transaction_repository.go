package repository

import (
	"context"
	"log"

	"github.com/jackc/pgx/v5/pgxpool"
	model "github.com/uyaaaaaa/personal-finance/internal/models"
)

// TransactionRepository defines the interface for transaction data operations.
type TransactionRepository interface {
	GetTransactionsByUserID(ctx context.Context, userID string) ([]model.Transaction, error)
}

type pgxTransactionRepository struct {
	pool *pgxpool.Pool
}

// NewTransactionRepository creates a new instance of TransactionRepository.
func NewTransactionRepository(pool *pgxpool.Pool) TransactionRepository {
	return &pgxTransactionRepository{pool: pool}
}

// GetTransactionsByUserID retrieves all transactions for a specific user.
func (r *pgxTransactionRepository) GetTransactionsByUserID(ctx context.Context, userID string) ([]model.Transaction, error) {
	query := `
		SELECT id, user_id, amount, description, date, created_at, updated_at
		FROM transactions
		WHERE user_id = $1 -- Assuming the DB column type is compatible with string UUID
		ORDER BY date DESC
	`
	// Pass userID as string. pgx should handle UUID type conversion if the DB column is UUID.
	rows, err := r.pool.Query(ctx, query, userID)
	if err != nil {
		// Log the string userID correctly
		log.Printf("Error querying transactions for user %s: %v", userID, err)
		return nil, err
	}
	defer rows.Close()

	var transactions []model.Transaction
	for rows.Next() {
		var t model.Transaction
		// Ensure model.Transaction.UserID is also string or compatible type
		if err := rows.Scan(&t.ID, &t.UserID, &t.Amount, &t.Description, &t.Date, &t.CreatedAt, &t.UpdatedAt); err != nil {
			log.Printf("Error scanning transaction row: %v", err)
			return nil, err // Return error to avoid processing incomplete data
		}
		transactions = append(transactions, t)
	}

	// Check for errors during row iteration
	if err := rows.Err(); err != nil {
		log.Printf("Error iterating transaction rows: %v", err)
		return nil, err
	}

	return transactions, nil
}
