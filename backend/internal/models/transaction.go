package model

import "time"

// Transaction represents a user's financial transaction.
type Transaction struct {
	ID          int       `json:"id"`
	UserID      string    `json:"user_id"` // Changed from int to string
	Amount      float64   `json:"amount"`
	Description string    `json:"description"`
	Date        time.Time `json:"date"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}
