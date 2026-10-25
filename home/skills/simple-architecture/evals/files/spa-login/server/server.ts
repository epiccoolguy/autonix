import express from "express";
import { apiRouter } from "./api";

// Serves the built React app and the JSON API from one process.
const app = express();
app.use("/api", apiRouter);
app.use(express.static("web/dist"));
app.get("*", (_req, res) => res.sendFile("index.html", { root: "web/dist" }));
app.listen(8080);
