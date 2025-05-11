package main

import (
	"context"
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/uyaaaaaa/personal-finance/internal/handler"
	"github.com/uyaaaaaa/personal-finance/internal/repository"
)

func main() {
	// Database Connection
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		log.Println("Warning: DATABASE_URL environment variable not set. Using default or potentially failing.")
		log.Fatalf("DATABASE_URL is required")
	}

	pool, err := pgxpool.New(context.Background(), dbURL)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v\n", err)
	}
	defer pool.Close()

	txnRepo := repository.NewTransactionRepository(pool)
	txnHandler := handler.NewTransactionHandler(txnRepo)

	// Create default gin router
	r := gin.Default()
	ua := ""

	r.Use(func(c *gin.Context) {
		ua = c.GetHeader("User-Agent")
		c.Next()
	})

	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message":    "Personal-finance API server is running.",
			"User-Agent": ua,
		})
	})

	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status": "healthy",
		})
	})

	// Group routes that require user authentication
	userRoutes := r.Group("/user")
	{
		userRoutes.GET("/transactions", txnHandler.GetTransactions)
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		log.Printf("PORT environment variable not set, using default port %s", port)
	}

	err = r.Run(":" + port)
	if err != nil {
		log.Fatalf("Failed to run server: %v", err)
	}
}
