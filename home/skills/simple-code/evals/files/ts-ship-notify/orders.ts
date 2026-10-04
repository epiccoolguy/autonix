export type Order = {
  readonly id: string;
  readonly email: string;
  readonly status: "pending" | "shipped";
};

export type OrderStore = {
  updateStatus(id: string, status: Order["status"]): Promise<void>;
};

export async function markShipped(store: OrderStore, order: Order): Promise<Order> {
  if (order.status === "shipped") {
    return order;
  }
  await store.updateStatus(order.id, "shipped");
  return { ...order, status: "shipped" };
}
