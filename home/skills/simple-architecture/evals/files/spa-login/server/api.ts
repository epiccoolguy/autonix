import { Router } from "express";

export const apiRouter = Router();
apiRouter.get("/invoices", (_req, res) => {
  res.json([]);
});
