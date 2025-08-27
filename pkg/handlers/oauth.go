package handlers

import (
	"encoding/json"
	"net/http"
	"os"
	"surrealdb-auth-example/pkg/surrealdb"

	"github.com/gin-gonic/gin"
)

// OAuthHandler handles OAuth routes
type OAuthHandler struct {
	surrealClient *surrealdb.Client
}

// NewOAuthHandler creates a new OAuth handler
func NewOAuthHandler(surrealClient *surrealdb.Client) *OAuthHandler {
	return &OAuthHandler{
		surrealClient: surrealClient,
	}
}

// SurrealDBFunctionResponse represents a response from a SurrealDB function call
type SurrealDBFunctionResponse struct {
	Result interface{} `json:"result"`
	Status string      `json:"status"`
}

// OAuthUserInfo represents user info from OAuth provider
type OAuthUserInfo struct {
	Name  string      `json:"name"`
	Email string      `json:"email"`
	ID    string      `json:"id"`
	Meta  interface{} `json:"meta"`
}

// Authorize handles OAuth authorization redirect
func (h *OAuthHandler) Authorize(c *gin.Context) {
	provider := c.Param("provider")
	
	// Validate provider
	if provider != "github" && provider != "google" {
		c.JSON(http.StatusBadRequest, ErrorResponse{
			Code:    "err:oauth",
			Message: "Invalid OAuth provider",
		})
		return
	}

	// Call SurrealDB function to get OAuth URL
	response, err := h.surrealClient.Fn(provider + "__oauthUrl")
	if err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Code:    "err:oauth",
			Message: "Failed to get OAuth URL",
		})
		return
	}

	if response.Status == 200 {
		var data []SurrealDBFunctionResponse
		if err := json.Unmarshal(response.Body, &data); err != nil || len(data) == 0 {
			c.JSON(http.StatusInternalServerError, ErrorResponse{
				Code:    "err:oauth",
				Message: "Failed to parse OAuth URL response",
			})
			return
		}

		// Redirect to OAuth URL
		oauthURL, ok := data[0].Result.(string)
		if !ok {
			c.JSON(http.StatusInternalServerError, ErrorResponse{
				Code:    "err:oauth",
				Message: "Invalid OAuth URL format",
			})
			return
		}

		c.Redirect(http.StatusFound, oauthURL)
		return
	}

	// Check if authToken exists and is invalid, then reset cookie and retry
	authToken, err := c.Cookie("__auth_token")
	if err == nil && authToken != "" {
		c.SetCookie("__auth_token", "", -1, "/", "", false, true)
		
		frontendURL := os.Getenv("FRONTEND_URL")
		if frontendURL == "" {
			frontendURL = "http://localhost:5173"
		}
		
		c.Redirect(http.StatusFound, frontendURL+"/api/oauth/"+provider)
		return
	}

	c.JSON(http.StatusInternalServerError, ErrorResponse{
		Code:    "err:oauth",
		Message: "OAuth authorization failed",
	})
}

// Callback handles OAuth callback
func (h *OAuthHandler) Callback(c *gin.Context) {
	provider := c.Param("provider")
	code := c.Query("code")

	// Validate provider
	if provider != "github" && provider != "google" {
		c.JSON(http.StatusBadRequest, ErrorResponse{
			Code:    "err:oauth",
			Message: "Invalid OAuth provider",
		})
		return
	}

	if code == "" {
		c.JSON(http.StatusBadRequest, ErrorResponse{
			Code:    "err:oauth",
			Message: "Missing authorization code",
		})
		return
	}

	// Call SurrealDB function to authorize with OAuth code
	response, err := h.surrealClient.Fn(provider+"__oauthAuthorize", code)
	if err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Code:    "err:oauth",
			Message: "OAuth authorization failed",
		})
		return
	}

	var data []SurrealDBFunctionResponse
	if err := json.Unmarshal(response.Body, &data); err != nil || len(data) == 0 {
		c.JSON(http.StatusBadRequest, ErrorResponse{
			Code:    "err:oauth",
			Message: "Failed to parse OAuth response",
		})
		return
	}

	if data[0].Status == "ERR" {
		c.JSON(http.StatusBadRequest, ErrorResponse{
			Code:    "err:oauth",
			Message: "OAuth authorization failed",
		})
		return
	}

	// Parse user info from OAuth result
	resultBytes, err := json.Marshal(data[0].Result)
	if err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Code:    "err:oauth",
			Message: "Failed to process user info",
		})
		return
	}

	var userInfo OAuthUserInfo
	if err := json.Unmarshal(resultBytes, &userInfo); err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Code:    "err:oauth",
			Message: "Failed to parse user info",
		})
		return
	}

	// Sign up user with OAuth info
	signupResponse, err := h.surrealClient.Signup(surrealdb.SignupParams{
		Name:     userInfo.Name,
		Email:    userInfo.Email,
		Sub:      userInfo.ID,
		Meta:     userInfo.Meta,
		Provider: provider,
		Type:     "oauth",
	})

	if err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Code:    "err:oauth",
			Message: "User signup failed",
		})
		return
	}

	var signupResult SurrealDBResponse
	if err := json.Unmarshal(signupResponse.Body, &signupResult); err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{
			Code:    "err:oauth",
			Message: "Failed to parse signup response",
		})
		return
	}

	// Set HTTP-only cookie
	c.SetCookie("__auth_token", signupResult.Token, 0, "/", "", false, true)

	// Redirect to frontend
	frontendURL := os.Getenv("FRONTEND_URL")
	if frontendURL == "" {
		frontendURL = "http://localhost:5173"
	}

	c.Redirect(http.StatusFound, frontendURL)
}