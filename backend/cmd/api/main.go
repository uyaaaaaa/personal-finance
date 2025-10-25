package main

import (
  "context"
  "log"
  "net/http"
  "os"

  "github.com/gin-gonic/gin"
  "github.com/jackc/pgx/v5/pgxpool"
)

func main() {
  // Database Connection
  dbURL := os.Getenv("DATABASE_URL")
  if dbURL == "" {
    log.Fatalf("DATABASE_URL is required")
  }

  pool, err := pgxpool.New(context.Background(), dbURL)
  if err != nil {
    log.Fatalf("Unable to connect to database: %v\n", err)
  }
  defer pool.Close()

  r := gin.Default()  // Create default gin router

  r.GET("/", func(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{
      "message": "Personal-finance API server is running.",
    })
  })

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
