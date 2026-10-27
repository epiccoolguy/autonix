import { createServer } from "./server";
import { db } from "./db";
import { migrate } from "./migrate";

async function main() {
  await migrate(db, "migrations");
  createServer(db).listen(8080);
}

main();
