const { PrismaClient } = require('@prisma/client');
const { PrismaPg } = require('@prisma/adapter-pg');
const { Pool } = require('pg');
const url = require('url');  // Node's URL parser

const dbUrl = process.env.DATABASE_URL;
if (!dbUrl) throw new Error('DATABASE_URL not set');

const params = url.parse(dbUrl, true);
const pool = new Pool({
  host: params.hostname,
  port: params.port || 5432,
  database: params.pathname?.split('/')?.[1],
  user: params.auth?.split(':')?.[0],
  password: params.auth?.split(':')?.[1],  // Ensures string extraction
  ssl: params.query.sslmode === 'require' || false,
});

const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

module.exports = prisma;
