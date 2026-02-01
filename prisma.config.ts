import { defineConfig } from '@prisma/client/runtime/config';

export default defineConfig({
  schema: './prisma/schema.prisma',
  datasourceUrl: process.env.DATABASE_URL || 'postgresql://postgres:4251606@localhost:5432/kosh_db?schema=public',
});
