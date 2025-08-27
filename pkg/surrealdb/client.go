package surrealdb

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
)

// Client represents a SurrealDB client
type Client struct {
	endpoint string
	ns       string
	db       string
	client   *http.Client
}

// NewClient creates a new SurrealDB client
func NewClient() *Client {
	endpoint := os.Getenv("SURREALDB_ENDPOINT")
	if endpoint == "" {
		endpoint = "http://surrealdb:8000"
	}

	ns := os.Getenv("SURREALDB_NS")
	db := os.Getenv("SURREALDB_DB")

	return &Client{
		endpoint: endpoint,
		ns:       ns,
		db:       db,
		client:   &http.Client{},
	}
}

// Response represents a SurrealDB HTTP response
type Response struct {
	Status int
	Body   []byte
}

// getHeaders creates common headers for SurrealDB requests
func (c *Client) getHeaders(token string) map[string]string {
	headers := map[string]string{
		"Content-Type": "application/json",
		"Accept":       "application/json",
		"NS":           c.ns,
		"DB":           c.db,
	}

	if token != "" {
		if strings.HasPrefix(token, "Bearer ") {
			headers["Authorization"] = token
		} else {
			headers["Authorization"] = "Bearer " + token
		}
	}

	return headers
}

// makeRequest makes an HTTP request to SurrealDB
func (c *Client) makeRequest(method, path string, body interface{}, headers map[string]string) (*Response, error) {
	var reqBody io.Reader

	if body != nil {
		jsonBody, err := json.Marshal(body)
		if err != nil {
			return nil, fmt.Errorf("failed to marshal request body: %w", err)
		}
		reqBody = bytes.NewReader(jsonBody)
	}

	req, err := http.NewRequest(method, c.endpoint+path, reqBody)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	// Set headers
	for key, value := range headers {
		req.Header.Set(key, value)
	}

	resp, err := c.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("HTTP request failed: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response body: %w", err)
	}

	return &Response{
		Status: resp.StatusCode,
		Body:   respBody,
	}, nil
}

// GetVersion returns the SurrealDB version
func (c *Client) GetVersion() (string, error) {
	resp, err := c.makeRequest("GET", "/version", nil, nil)
	if err != nil {
		return "", err
	}

	return string(resp.Body), nil
}

// SQL executes a SQL statement
func (c *Client) SQL(statement, token string) (*Response, error) {
	headers := c.getHeaders(token)
	
	req, err := http.NewRequest("POST", c.endpoint+"/sql", strings.NewReader(statement))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	for key, value := range headers {
		req.Header.Set(key, value)
	}

	resp, err := c.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("HTTP request failed: %w", err)
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response body: %w", err)
	}

	return &Response{
		Status: resp.StatusCode,
		Body:   respBody,
	}, nil
}

// Fn executes a SurrealDB function
func (c *Client) Fn(fn string, args ...interface{}) (*Response, error) {
	var expression strings.Builder
	expression.WriteString("fn::")
	expression.WriteString(fn)
	expression.WriteString("(")

	for i, arg := range args {
		switch v := arg.(type) {
		case string:
			expression.WriteString(`"`)
			expression.WriteString(v)
			expression.WriteString(`"`)
		case int, int64, float64:
			expression.WriteString(fmt.Sprintf("%v", v))
		default:
			// For other types, try to JSON encode
			jsonBytes, _ := json.Marshal(v)
			expression.Write(jsonBytes)
		}

		if i < len(args)-1 {
			expression.WriteString(",")
		}
	}

	expression.WriteString(")")

	return c.SQL(expression.String(), "")
}

// SignupParams represents parameters for user signup
type SignupParams struct {
	Name     string      `json:"name"`
	Email    string      `json:"email"`
	Password string      `json:"password,omitempty"`
	Type     string      `json:"type,omitempty"`
	Provider string      `json:"provider,omitempty"`
	Sub      string      `json:"sub,omitempty"`
	Meta     interface{} `json:"meta,omitempty"`
}

// Signup creates a new user account
func (c *Client) Signup(params SignupParams) (*Response, error) {
	body := map[string]interface{}{
		"NS": c.ns,
		"DB": c.db,
	}

	if params.Type == "oauth" {
		body["SC"] = "oauth"
		body["email"] = params.Email
		body["name"] = params.Name
		body["provider"] = params.Provider
		body["sub"] = params.Sub
		body["meta"] = params.Meta
	} else {
		body["email"] = params.Email
		body["name"] = params.Name
		body["password"] = params.Password
		body["SC"] = "credentials"
	}

	headers := map[string]string{
		"Content-Type": "application/json",
		"Accept":       "application/json",
	}

	return c.makeRequest("POST", "/signup", body, headers)
}

// SigninParams represents parameters for user signin
type SigninParams struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

// Signin authenticates a user
func (c *Client) Signin(params SigninParams) (*Response, error) {
	body := map[string]interface{}{
		"NS":       c.ns,
		"DB":       c.db,
		"SC":       "credentials",
		"email":    params.Email,
		"password": params.Password,
	}

	headers := map[string]string{
		"Content-Type": "application/json",
		"Accept":       "application/json",
	}

	return c.makeRequest("POST", "/signin", body, headers)
}