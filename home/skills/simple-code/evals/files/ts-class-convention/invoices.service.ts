import { Injectable } from "@nestjs/common";
import { InvoicesRepository } from "./invoices.repository";
import { NotFoundError } from "./errors";

export type Invoice = {
  readonly id: string;
  readonly status: "draft" | "sent" | "paid" | "void";
  readonly totalCents: number;
};

@Injectable()
export class InvoicesService {
  constructor(private readonly invoices: InvoicesRepository) {}

  async send(id: string): Promise<Invoice> {
    const invoice = await this.invoices.findById(id);
    if (!invoice) {
      throw new NotFoundError(`invoice ${id}`);
    }
    return this.invoices.save({ ...invoice, status: "sent" });
  }
}
