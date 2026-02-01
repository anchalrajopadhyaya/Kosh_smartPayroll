// const { Client } = require('pg');
// const bcrypt = require('bcrypt');

// const client = new Client({
//   host: 'localhost',
//   port: 5432,
//   user: 'postgres',
//   password: '4251606',
//   database: 'kosh_db',
// });

// const HR_NAME = 'HR Admin';
// const HR_EMAIL = 'hr@gmail.com';
// const HR_PASSWORD = 'admin123'; // Change this to a secure password

// async function setupHR() {
//   try {
//     await client.connect();
//     console.log('Connected to database');

//     // Create hr_users table
//     await client.query(`
//       CREATE TABLE IF NOT EXISTS hr_users (
//         id SERIAL PRIMARY KEY,
//         name VARCHAR(100) NOT NULL,
//         email VARCHAR(100) UNIQUE NOT NULL,
//         password VARCHAR(255) NOT NULL,
//         role VARCHAR(50) DEFAULT 'hr',
//         created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
//       );
//     `);
//     console.log('✓ HR users table created/verified');

//     // Hash the password
//     const hashedPassword = await bcrypt.hash(HR_PASSWORD, 10);
//     console.log('✓ Password hashed');

//     // Insert HR user
//     const result = await client.query(
//       `
//       INSERT INTO hr_users (name, email, password, role)
//       VALUES ($1, $2, $3, $4)
//       ON CONFLICT (email) 
//       DO UPDATE SET 
//         password = EXCLUDED.password,
//         name = EXCLUDED.name
//       RETURNING id, name, email, role;
//       `,
//       [HR_NAME, HR_EMAIL, hashedPassword, 'hr']
//     );

//     console.log('✓ HR user created/updated successfully!');
//     console.log('\nLogin Credentials:');
//     console.log(`Email:    ${HR_EMAIL}`);
//     console.log(`Password: ${HR_PASSWORD}`);
//     console.log('\nIMPORTANT: Change this password after first login!\n');

//   } catch (err) {
//     console.error('Error:', err.message);
//   } finally {
//     await client.end();
//   }
// }

// setupHR();