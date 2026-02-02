import { defineConfig, PrismaClient } from "@prisma/client";

export default defineConfig({
  client: new PrismaClient({
    adapter: {
      provider: "postgresql",
      url: "postgresql://postgres:4251606@localhost:5432/kosh_db"
    }
  })
});
