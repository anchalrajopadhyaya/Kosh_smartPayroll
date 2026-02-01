const express = require("express");
const router = express.Router();
const pool = require("../db");
const bcrypt = require("bcrypt");

// Universal Login (checks both users and employees tables)
router.post("/login", async (req, res) => {
  const { email, password } = req.body;

  // Validate input
  if (!email || !password) {
    return res.status(400).json({
      message: "Email and password are required",
    });
  }

  try {
    // First, check if user is an HR user (in users table)
    const hrResult = await pool.query(
      "SELECT id, name, email, password, role FROM users WHERE email = $1",
      [email]
    );

    if (hrResult.rows.length > 0) {
      // User found in users (HR) table
      const hrUser = hrResult.rows[0];
      const isPasswordValid = await bcrypt.compare(password, hrUser.password);

      if (!isPasswordValid) {
        return res.status(401).json({
          message: "Invalid email or password",
        });
      }

      // Return HR user data
      return res.status(200).json({
        message: "Login successful",
        userType: "hr", // Important: identifies user type
        user: {
          id: hrUser.id,
          name: hrUser.name,
          email: hrUser.email,
          role: hrUser.role || "hr",
        },
      });
    }

    // If not HR, check if user is an Employee
    const empResult = await pool.query(
      "SELECT id, employee_code, first_name, last_name, email, password, job_title, department, salary FROM employees WHERE email = $1",
      [email]
    );

    if (empResult.rows.length > 0) {
      // User found in Employee table
      const employee = empResult.rows[0];
      const isPasswordValid = await bcrypt.compare(password, employee.password);

      if (!isPasswordValid) {
        return res.status(401).json({
          message: "Invalid email or password",
        });
      }

      // Return Employee user data
      return res.status(200).json({
        message: "Login successful",
        userType: "employee", // Important: identifies user type
        user: {
          id: employee.id,
          employeeCode: employee.employee_code,
          name: `${employee.first_name} ${employee.last_name}`,
          firstName: employee.first_name,
          lastName: employee.last_name,
          email: employee.email,
          jobTitle: employee.job_title,
          department: employee.department,
          salary: employee.salary,
        },
      });
    }

    // User not found in either table
    return res.status(401).json({
      message: "Invalid email or password",
    });

  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

module.exports = router;