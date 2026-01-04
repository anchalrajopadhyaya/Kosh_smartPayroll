const { Client } = require('pg');

//Connecting to an existing DB on the server
const adminClient = new Client({
  host: 'localhost',
  port: 5432,
  user: 'postgres',      
  password: '4251606',
  database: 'postgres',
});

const DB_NAME = 'kosh_db'; 

async function createDatabase() {
  try {
    await adminClient.connect();
    
    await adminClient.query(`CREATE DATABASE ${DB_NAME};`);
    console.log(`Database "${DB_NAME}" created successfully`);
  } catch (err) {
    console.error('Error creating database:', err.message);
  } finally {
    await adminClient.end();
  }
}

createDatabase();
