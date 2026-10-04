import { Injectable } from "@nestjs/common";
import type { Invoice } from "./invoices.service";

@Injectable()
export class InvoicesRepository {
  async findById(id: string): Promise<Invoice | undefined> {
    // Queries the database.
    return undefined;
  }

  async save(invoice: Invoice): Promise<Invoice> {
    // Persists the invoice.
    return invoice;
  }
}
