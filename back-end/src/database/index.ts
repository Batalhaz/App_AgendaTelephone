import 'dotenv/config';
import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import pg from 'pg';

const databaseUrl = process.env.DATABASE_URL;

if (!databaseUrl) {
  throw new Error("A variável DATABASE_URL não foi encontrada no .env");
}

const pool = new pg.Pool({connectionString: databaseUrl});
const adapter = new PrismaPg(pool);

const prisma = new PrismaClient({
  adapter,
  log: ['query', 'error', 'info', 'warn'],
});

export default prisma;