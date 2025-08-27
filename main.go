package main

import (
	"log"
	"net/http"
	"os"
	"surrealdb-auth-example/pkg/handlers"
	"surrealdb-auth-example/pkg/surrealdb"

	"github.com/gin-gonic/gin"
)

func main() {
	// Initialize SurrealDB client
	surrealClient := surrealdb.NewClient()

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(surrealClient)
	oauthHandler := handlers.NewOAuthHandler(surrealClient)
	userHandler := handlers.NewUserHandler(surrealClient)

	// Initialize router
	r := gin.Default()

	// Health check endpoint
	r.GET("/ping", func(c *gin.Context) {
		c.String(http.StatusOK, "pong")
	})

	// Default route
	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"greeting": "Go / Backend Server is running 🚀",
		})
	})

	// SurrealDB version endpoint
	r.GET("/surrealdb/version", func(c *gin.Context) {
		version, err := surrealClient.GetVersion()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"error": "Failed to get SurrealDB version",
			})
			return
		}
		c.String(http.StatusOK, version)
	})

	// Authentication routes
	r.POST("/auth/signin", authHandler.Signin)
	r.POST("/auth/signup", authHandler.Signup)
	r.POST("/auth/signout", authHandler.Signout)

	// OAuth routes
	r.GET("/oauth/:provider", oauthHandler.Authorize)
	r.GET("/oauth/:provider/callback", oauthHandler.Callback)

	// User routes
	r.GET("/me", userHandler.Me)

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Starting server on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, r))
}