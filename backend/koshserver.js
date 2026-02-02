// const { Client } = require('pg');
// const bcrypt = require('bcrypt');

// const client = new Client({
//   host: 'localhost',
//   port: 5432,
//   user: 'postgres',
//   password: '4251606',
//   database: 'kosh_db',
// });

// const createTable = `
// CREATE TABLE IF NOT EXISTS users (
//   id SERIAL PRIMARY KEY,
//   name VARCHAR(50),
//   email VARCHAR(100) UNIQUE,
//   password VARCHAR(100)
// );
// `;

// const insert_user = `
// INSERT INTO users (name, email, password)
// VALUES ($1, $2, $3)
// ON CONFLICT (email) DO UPDATE 
// SET password = EXCLUDED.password
// RETURNING id, name, email;
// `;

// async function init() {
//   try {
//     await client.connect();
//     await client.query(createTable);
//     console.log('Table created (or already exists)');

//     const name = 'Admin';
//     const email = 'admin@gmail.com';
//     const password = 'admin123';
    
//     // Hash the password before inserting
//     const hashedPassword = await bcrypt.hash(password, 10);

//     const result = await client.query(insert_user, [name, email, hashedPassword]);
    
//     if (result.rows.length > 0) {
//       console.log('Inserted/Updated user:', result.rows[0]);
//     }
//   } catch (err) {
//     console.error('Error:', err.message);
//   } finally {
//     await client.end();
//   }
// }

// init();
