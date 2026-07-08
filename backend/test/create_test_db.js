const { Client } = require('pg');

const adminClient = new Client({
  host: 'localhost',
  port: 5432,
  user: 'postgres',      
  password: '4251606',
  database: 'postgres',
});

const DB_NAME = 'kosh_test_db'; 

async function createDatabase() {
  try {
    await adminClient.connect();
    
    const res = await adminClient.query(`SELECT 1 FROM pg_database WHERE datname=$1`, [DB_NAME]);
    if (res.rows.length === 0) {
      await adminClient.query(`CREATE DATABASE ${DB_NAME};`);
      console.log(`Database "${DB_NAME}" created successfully.`);
    } else {
      console.log(`Database "${DB_NAME}" already exists.`);
    }
  } catch (err) {
    console.error('Error creating database:', err.message);
  } finally {
    await adminClient.end();
  }
}

createDatabase();
