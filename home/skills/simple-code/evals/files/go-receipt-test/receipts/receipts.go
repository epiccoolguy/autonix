package receipts

import (
	"context"
	"fmt"

	"example.com/shop/provider"
)

type Order struct {
	ID         string
	Email      string
	TotalCents int
}

func SendReceipt(ctx context.Context, client *provider.Client, o Order) error {
	body := fmt.Sprintf("Order %s total: %d.%02d EUR", o.ID, o.TotalCents/100, o.TotalCents%100)
	if err := client.Send(ctx, o.Email, "Your receipt", body); err != nil {
		return fmt.Errorf("send receipt %s: %w", o.ID, err)
	}
	return nil
}
