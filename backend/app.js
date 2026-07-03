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

// LOGIN ROUTE
app.post("/login", validate(loginSchema), async (req, res) => {
  const { email, password } = req.body;

  try {
    const hrUser = await prisma.users.findUnique({ where: { email } });

    if (hrUser) {
      const isPasswordValid = await bcrypt.compare(password, hrUser.password);
      if (!isPasswordValid) {
        return res.status(401).json({ message: "Invalid email or password" });
      }

      return res.status(200).json({
        message: "Login successful",
        userType: "hr",
        user: {
          id: hrUser.id,
          name: hrUser.name,
          email: hrUser.email,
          role: hrUser.role || "hr",
          mustChangePassword: hrUser.must_change_password,
        },
      });
    }

    const employee = await prisma.employees.findUnique({ where: { email } });

    if (employee) {
      const isPasswordValid = await bcrypt.compare(password, employee.password);
      if (!isPasswordValid) {
        return res.status(401).json({ message: "Invalid email or password" });
      }

      return res.status(200).json({
        message: "Login successful",
        userType: "employee",
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
          phone: employee.phone,
          mustChangePassword: employee.must_change_password,
        },
      });
    }

    return res.status(401).json({ message: "Invalid email or password" });

  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// Routes
const employeeRoutes = require("./routes/employees");
app.use("/api", employeeRoutes);

const attendanceRoutes = require("./routes/attendance");
app.use("/api/attendance", attendanceRoutes);

const leaveRoutes = require("./routes/leave");
app.use("/api/leave", leaveRoutes);

const timeRequestRoutes = require("./routes/timerequest");
app.use("/api/time-request", timeRequestRoutes);

const feedbackRoutes = require("./routes/feedback");
app.use("/api/feedback", feedbackRoutes);

const passwordResetRoutes = require("./routes/passwordReset");
app.use("/api/auth", passwordResetRoutes);

const payrollRoutes = require("./routes/payroll_route");
app.use("/api/payroll", payrollRoutes);

const notificationsRoutes = require("./routes/notifications");
app.use("/api/notifications", notificationsRoutes);

const profileUpdateRoutes = require("./routes/profile_update");
app.use("/api/profile-update", profileUpdateRoutes);

// Test route
app.get("/", (req, res) => {
  res.json({ message: "Kosh Payroll API is running" });
});

module.exports = app; 