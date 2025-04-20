package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/uyaaaaaa/personal-finance/internal/repository"
)

// UserHandler handles user related HTTP requests.
type UserHandler struct {
	userRepo repository.UserRepository
}

// NewUserHandler creates a new instance of UserHandler.
func NewUserHandler(userRepo repository.UserRepository) *UserHandler {
	return &UserHandler{userRepo: userRepo}
}

// GetUserByID handles GET requests to retrieve a user name by ID.
func (h *UserHandler) GetUserByID(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "User ID is required"})
		return
	}

	user, err := h.userRepo.GetUserNameByID(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve user"})
		return
	}

	c.JSON(http.StatusOK, user)
}
