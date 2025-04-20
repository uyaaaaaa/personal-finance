package repository

import (
	"context"
	"log"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/uyaaaaaa/personal-finance/internal/models"
)

type UserRepository interface {
	GetUserNameByID(ctx context.Context, id string) (models.User, error)
}

type userRepository struct {
	pool *pgxpool.Pool
}

func NewUserRepository(pool *pgxpool.Pool) UserRepository {
	return &userRepository{pool: pool}
}

func (r *userRepository) GetUserNameByID(ctx context.Context, id string) (models.User, error) {
	query := "SELECT name FROM users WHERE id = $1;" // Assuming 'id' is the primary key column name
	var user models.User
	err := r.pool.QueryRow(ctx, query, id).Scan(&user.Name)
	if err != nil {
		// Consider handling pgx.ErrNoRows specifically if needed
		log.Printf("Error querying user name by ID %s: %v", id, err)
		return models.User{}, err
	}
	return user, nil
}
