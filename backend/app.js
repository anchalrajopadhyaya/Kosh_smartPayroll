require("dotenv").config();
const express = require("express");
const cors = require("cors");
const bcrypt = require("bcrypt");
const prisma = require("./prismaClient");
const { loginSchema } = require("./routes/employee_validator");
const { validate } = require("./middleware/validation");

const app = express();

app.use(cors());
app.use(express.json());

// Universal Login (checks both users and employees tables) - Using middleware
app.post("/login", validate(loginSchema), async (req, res) => {
  const { email, password } = req.body; // Already validated by middleware

  try {
    // First, check if user is an HR user (in users table)
    const hrUser = await prisma.users.findUnique({
      where: { email },
    });

    if (hrUser) {
      // User found in users (HR) table
      const isPasswordValid = await bcrypt.compare(password, hrUser.password);

      if (!isPasswordValid) {
        return res.status(401).json({
          message: "Invalid email or password",
        });
      }

      // Return HR user data
      return res.status(200).json({
        message: "Login successful",
        userType: "hr", //usertype
        user: {
          id: hrUser.id,
          name: hrUser.name,
          email: hrUser.email,
          role: hrUser.role || "hr",
        },
      });
    }

    const employee = await prisma.employees.findUnique({
      where: { email },
    });

    if (employee) {
      //Employee table user
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
    res.status(500).json({ message: "Server error" });
  }
});

// Employees routes
const employeeRoutes = require("./routes/employees");
app.use("/api", employeeRoutes);

// Attendance routes
const attendanceRoutes = require("./routes/attendance");
app.use("/api/attendance", attendanceRoutes);

// Test route
app.get("/", (req, res) => {
  res.json({ message: "Kosh Payroll API is running" });
});

// Server
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`API server running on http://localhost:${PORT}`);
});