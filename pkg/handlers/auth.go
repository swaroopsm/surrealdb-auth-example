package handlers

import (
	"encoding/json"
	"net/http"
	"surrealdb-auth-example/pkg/surrealdb"

	"github.com/gin-gonic/gin"
)

// AuthHandler handles authentication routes
type AuthHandler struct {
	surrealClient *surrealdb.Client
}

// NewAuthHandler creates a new authentication handler
func NewAuthHandler(surrealClient *surrealdb.Client) *AuthHandler {
	return &AuthHandler{
		surrealClient: surrealClient,
	}
}

// SigninRequest represents a signin request
type SigninRequest struct {
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

// SignupRequest represents a signup request
type SignupRequest struct {
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

// ErrorResponse represents an error response
type ErrorResponse struct {
	Code    string `json:"code"`
	Message string `json:"message"`
}

// SuccessResponse represents a success response
type SuccessResponse struct {
	Success bool `json:"success"`
}

// SurrealDBResponse represents a response from SurrealDB
type SurrealDBResponse struct {
	Token string `json:"token"`
}

// Signin handles user signin
func (h *AuthHandler) Signin(c *gin.Context) {
	var req SigninRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{
			Code:    "err:signin",
			Message: "Invalid request body",
		})
		return
	}

	// Call SurrealDB signin
	response, err := h.surrealClient.Signin(surrealdb.SigninParams{
		Email:    req.Email,
		Password: req.Password,
	})

	if err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Code:    "err:signin",
			Message: "Signin failed",
		})
		return
	}

	if response.Status != 200 {
		c.JSON(response.Status, ErrorResponse{
			Code:    "err:signin",
			Message: "Signin failed",
		})
		return
	}

	// Parse response to get token
	var result SurrealDBResponse
	if err := json.Unmarshal(response.Body, &result); err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Code:    "err:signin",
			Message: "Failed to parse response",
		})
		return
	}

	// Set HTTP-only cookie
	c.SetCookie("__auth_token", result.Token, 0, "/", "", false, true)

	c.JSON(http.StatusOK, SuccessResponse{Success: true})
}

// Signup handles user signup
func (h *AuthHandler) Signup(c *gin.Context) {
	var req SignupRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{
			Code:    "err:signup",
			Message: "Invalid request body",
		})
		return
	}

	// Call SurrealDB signup
	response, err := h.surrealClient.Signup(surrealdb.SignupParams{
		Name:     req.Name,
		Email:    req.Email,
		Password: req.Password,
	})

	if err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Code:    "err:signup",
			Message: "Signup failed",
		})
		return
	}

	if response.Status != 200 {
		c.JSON(response.Status, ErrorResponse{
			Code:    "err:signup",
			Message: "Signup failed",
		})
		return
	}

	// Parse response to get token
	var result SurrealDBResponse
	if err := json.Unmarshal(response.Body, &result); err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Code:    "err:signup",
			Message: "Failed to parse response",
		})
		return
	}

	// Set HTTP-only cookie
	c.SetCookie("__auth_token", result.Token, 0, "/", "", false, true)

	c.JSON(http.StatusOK, SuccessResponse{Success: true})
}

// Signout handles user signout
func (h *AuthHandler) Signout(c *gin.Context) {
	// Clear the auth token cookie
	c.SetCookie("__auth_token", "", -1, "/", "", false, true)
	c.Status(http.StatusOK)
}