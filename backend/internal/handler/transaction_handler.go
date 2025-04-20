package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	model "github.com/uyaaaaaa/personal-finance/internal/models"
	"github.com/uyaaaaaa/personal-finance/internal/repository"
)

// TransactionHandler handles HTTP requests related to transactions.
type TransactionHandler struct {
	repo repository.TransactionRepository
}

// NewTransactionHandler creates a new instance of TransactionHandler.
func NewTransactionHandler(repo repository.TransactionRepository) *TransactionHandler {
	return &TransactionHandler{repo: repo}
}

// GetTransactions handles the request to get transactions for the authenticated user.
func (h *TransactionHandler) GetTransactions(c *gin.Context) {
	// ミドルウェアが設定した userID をコンテキストから取得
	userIDAny, exists := c.Get("userID")
	if !exists {
		// userID がコンテキストに存在しない場合 (通常はミドルウェアで弾かれるはずだが念のため)
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	// 型アサーションで string に変換 (int から変更)
	userID, ok := userIDAny.(string)
	if !ok {
		// 型が string でない場合 (予期せぬエラー)
		// TODO: サーバーログに詳細を出力
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error processing user ID type"})
		return
	}

	// userID が取得できたので、これを使ってリポジトリを呼び出す
	transactions, err := h.repo.GetTransactionsByUserID(c.Request.Context(), userID)
	if err != nil {
		// TODO: サーバーログに詳細なエラー(err)を出力
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve transactions"})
		return
	}

	if transactions == nil {
		// Return empty list instead of null for JSON consistency
		transactions = []model.Transaction{}
	}

	c.JSON(http.StatusOK, transactions)
}
