const express = require("express");
const router = express.Router();
const { PrismaClient } = require("@prisma/client");
const { employeeSchema } = require("./employee_validator");

const prisma = new PrismaClient();

// Generate employee code
function generateEmployeeCode() {
  const year = new Date().getFullYear();
  const random = Math.floor(1000 + Math.random() * 9000);
  return `EMP-${year}-${random}`;
}

// Create new employee
router.post("/employees", async (req, res) => {
  const { error, value } = employeeSchema.validate(req.body, { abortEarly: true });
  if (error) return res.status(400).json({ message: error.details[0].message });

  const employeeCode = generateEmployeeCode();

  try {
    const employee = await prisma.employees.create({
      data: {
        employee_code: employeeCode,
        first_name: value.firstName,
        last_name: value.lastName,
        email: value.email,
        phone: value.phone,
        city: value.city,
        district: value.district,
        province: value.province,
        ward: value.ward,
        PAN: value.PAN,
        citizenship_no: value.citizenshipNo,
        job_title: value.jobTitle,
        department: value.department,
        dob: new Date(value.dob),
        start_date: new Date(value.startDate),
        salary: value.salary,
      },
    });

    res.status(201).json({
      message: "Employee created",
      employeeCode: employee.employee_code,
    });
  } catch (err) {
    if (err.code === "P2002") {
      // Prisma unique constraint error
      return res.status(409).json({ message: "Email already exists" });
    }

    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

// Get all employees
router.get("/employees", async (req, res) => {
  try {
    const employees = await prisma.employees.findMany({
      orderBy: { created_at: "desc" },
    });

    res.status(200).json({
      message: "Employees retrieved successfully",
      employees,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

module.exports = router;
