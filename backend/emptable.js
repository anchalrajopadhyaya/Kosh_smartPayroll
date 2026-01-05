const { Client } = require('pg');

const client1 = new Client({
  host: 'localhost',
  port: 5432,
  user: 'postgres',
  password: '4251606',
  database: 'kosh_db',
});

const createEmployeeTable = `
CREATE TABLE IF NOT EXISTS employees (
  id SERIAL PRIMARY KEY,
  employee_code VARCHAR(20) UNIQUE NOT NULL,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100) UNIQUE,
  phone VARCHAR(20),
  city VARCHAR(50),
  district VARCHAR(50),
  province VARCHAR(50),
  ward VARCHAR(10),
  job_title VARCHAR(100),
  department VARCHAR(50),
  dob DATE,
  start_date DATE,
  salary NUMERIC(10,2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
`;

async function emp() {
  try {
    await client1.connect();
    await client1.query(createEmployeeTable);
    console.log("Employees table ready");
  } catch (err) {
    console.error("Error:", err.message);
  } finally {
    await client1.end();
  }
}

emp();