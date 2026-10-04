package provider

import (
	"context"
	"net/http"
)

type Client struct {
	apiKey string
	http   *http.Client
}

func New(apiKey string) *Client {
	return &Client{apiKey: apiKey, http: http.DefaultClient}
}

func (c *Client) Send(ctx context.Context, to, subject, body string) error {
	// Calls the provider's HTTP API.
	return nil
}

func (c *Client) ListBounces(ctx context.Context) ([]string, error) {
	return nil, nil
}

func (c *Client) DeleteDomain(ctx context.Context, domain string) error {
	return nil
}

func (c *Client) Stats(ctx context.Context) (map[string]int, error) {
	return nil, nil
}
