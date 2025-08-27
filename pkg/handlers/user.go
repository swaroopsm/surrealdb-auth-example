package handlers

import (
	"encoding/json"
	"net/http"
	"surrealdb-auth-example/pkg/surrealdb"

	"github.com/gin-gonic/gin"
)

// UserHandler handles user-related routes
type UserHandler struct {
	surrealClient *surrealdb.Client
}

// NewUserHandler creates a new user handler
func NewUserHandler(surrealClient *surrealdb.Client) *UserHandler {
	return &UserHandler{
		surrealClient: surrealClient,
	}
}

// Me returns current user information
func (h *UserHandler) Me(c *gin.Context) {
	// Get auth token from cookie
	authToken, err := c.Cookie("__auth_token")
	if err != nil {
		c.JSON(http.StatusUnauthorized, ErrorResponse{
			Code:    "err:unauthorized",
			Message: "No authentication token",
		})
		return
	}

	// Call SurrealDB whoami function with token
	response, err := h.surrealClient.SQL("fn::whoami()", authToken)
	if err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Code:    "err:me",
			Message: "Failed to get user info",
		})
		return
	}

	if response.Status != http.StatusOK {
		c.JSON(response.Status, ErrorResponse{
			Code:    "err:me",
			Message: "Failed to get user info",
		})
		return
	}

	var data []SurrealDBFunctionResponse
	if err := json.Unmarshal(response.Body, &data); err != nil || len(data) == 0 {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Code:    "err:me",
			Message: "Failed to parse user info response",
		})
		return
	}

	if data[0].Status == "ERR" {
		c.JSON(http.StatusUnauthorized, ErrorResponse{
			Code:    "err:unauthorized",
			Message: "Invalid or expired token",
		})
		return
	}

	// Return the user data
	c.JSON(http.StatusOK, data[0].Result)
}