const express = require('express');
const cors = require('cors');
const pool = require("./db");//import pool

const app = express();
app.use(cors());
app.use(express.json());

app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  console.log('Login body:', req.body);

  try {
    const result = await pool.query(
      'SELECT * FROM users WHERE email = $1 AND password = $2',
      [email, password]
    );
    console.log('ROW COUNT:', result.rows.length);
    console.log('ROWS:', result.rows);
    
    if (result.rows.length === 0) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const user = result.rows[0];
    return res.json({
      message: 'Login successful',
      user: { id: user.id, name: user.name, email: user.email },
    });
  } catch (err) {
    console.error('Login error:', err);
    return res.status(500).json({ message: 'Server error' });
  }
});


const employeeRoutes = require("./routes/employees");
app.use("/api", employeeRoutes);


const PORT = 3000;
app.listen(PORT, () => {
  console.log(`API server running on http://localhost:${PORT}`);
});
