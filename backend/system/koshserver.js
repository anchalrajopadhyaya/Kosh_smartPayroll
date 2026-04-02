const { Client } = require('pg');
const bcrypt = require('bcrypt');

const client = new Client({
  host: 'localhost',
  port: 5432,
  user: 'postgres',
  password: '4251606',
  database: 'kosh_db',
});

const createTable = `
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50),
  email VARCHAR(100) UNIQUE,
  password VARCHAR(100)
);
`;

// Add role column if it doesn't exist
const addRoleColumn = `
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS role VARCHAR(50) DEFAULT 'hr';
`;

const insert_user = `
INSERT INTO users (name, email, password, role)
VALUES ($1, $2, $3, $4)
ON CONFLICT (email) DO UPDATE 
SET password = EXCLUDED.password,
role = EXCLUDED.role,
RETURNING id, name, email, role;
`;

async function init() {
  try {
    await client.connect();
    await client.query(createTable);
    console.log('Table created (or already exists)');
    await client.query(addRoleColumn);
    console.log("added role");

    const name = 'Admin';
    const email = 'admin@gmail.com';
    const password = 'admin123';
    const role = 'hr';
    
    // Hash the password before inserting
    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await client.query(insert_user, [name, email, hashedPassword, role]);
    
    if (result.rows.length > 0) {
      console.log('Inserted/Updated user:', result.rows[0]);
    }
  } catch (err) {
    console.error('Error:', err.message);
  } finally {
    await client.end();
  }
}

init();
