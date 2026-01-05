const { Client } = require('pg');

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

const insert_user = `
  INSERT INTO users (name, email, password)
  VALUES ($1, $2, $3)
  ON CONFLICT (email) DO NOTHING
  RETURNING id, name, email;
`;

async function init() {
  try {
    await client.connect();
    await client.query(createTable);
    console.log('Table created (or already exists)');

  const name = 'Admin';
  const email = 'admin@gmail.com';
  const password = 'admin123';

  const result = await client.query(insert_user, [name, email, password]);
  
  if (result.rows.length > 0) {
      console.log('Inserted user:', result.rows[0]);
    } else {
      console.log('Admin user already exists, no new row inserted');
    }

} catch (err) {
  console.error('Error inserting user:', err.message);
} finally {
  await client.end();
}
}

init();



