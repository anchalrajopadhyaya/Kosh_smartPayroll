require('dotenv').config();
const { PrismaClient } = require('./lib/generated/prisma');

const prisma = new PrismaClient({
  datasourceUrl: process.env.DATABASE_URL,
  log: ['query', 'error', 'warn'],
});

module.exports = prisma;
